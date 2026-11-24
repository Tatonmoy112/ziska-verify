import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-PROF-036, -037, -039 and -046 … -050 (docs/test-cases/09-profile.md):
/// Profile's check counts, which come from History (final.md §13.7), and the
/// pull that asks for them again. Run in CI, which skips the screenshot
/// tests of the same cases (`ui/screens_reports_profile_test`).
void main() {
  Future<FlowApp> openProfile(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, profile: profile, overrides: overrides);
    await app.tap(tab('Profile'));
    return app;
  }

  /// The count shown in the card [label]; `null` while it loads.
  String? statCount(WidgetTester tester, String label) {
    final card = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label != null,
      ),
    );
    final text = tester.widget<Semantics>(card.first).properties.label!;
    return text == label ? null : text.substring(label.length + 2);
  }

  /// The counts requests: `GET checks?limit=1`.
  List<RequestOptions> countRequests(FlowApp app) => app.backend
      .sent('GET', 'checks')
      .where((r) => '${r.queryParameters['limit']}' == '1')
      .toList();

  Future<void> pull(WidgetTester tester) => tester.fling(
    find.byType(ListView).first,
    const Offset(0, 400),
    1000,
  );

  const stats = Key('profile.stats');
  const failed = Key('profile.stats.failed');

  testWidgets('TC-PROF-036 the counts come from one GET checks?limit=1', (
    tester,
  ) async {
    final app = await openProfile(tester);
    expect(find.byKey(stats), findsOneWidget);
    expect(statCount(tester, 'Checks'), '120');
    expect(statCount(tester, 'Valid'), '80');
    expect(statCount(tester, 'Needs attention'), '40');
    expect(countRequests(app), hasLength(1));
    expect(countRequests(app).single.queryParameters.keys.toSet(), {'limit'});
  });

  testWidgets('TC-PROF-039 asked again when the tab comes back', (
    tester,
  ) async {
    final app = await openProfile(tester);
    expect(countRequests(app), hasLength(1));
    await app.tap(tab('Check'));
    await app.tap(tab('Profile'));
    expect(countRequests(app), hasLength(2));
  });

  testWidgets('TC-PROF-046 asked again on a pull', (tester) async {
    final app = await openProfile(tester);
    expect(countRequests(app), hasLength(1));
    await pull(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(countRequests(app), hasLength(2));
    expect(statCount(tester, 'Checks'), '120');
  });

  testWidgets('TC-PROF-037 without History: no counts and no request', (
    tester,
  ) async {
    final app = await openProfile(
      tester,
      profile: Roles.retailSellerNoHistory,
    );
    expect(find.byKey(stats), findsNothing);
    expect(find.byKey(failed), findsNothing);
    expect(find.text('Checks'), findsNothing);
    expect(app.backend.sent('GET', 'checks'), isEmpty);
  });

  testWidgets('TC-PROF-047 without History a pull does nothing', (
    tester,
  ) async {
    final app = await openProfile(
      tester,
      profile: Roles.retailSellerNoHistory,
    );
    await pull(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
    expect(app.backend.sent('GET', 'checks'), isEmpty);
    expect(find.text('Change password'), findsOneWidget);
  });

  testWidgets('TC-PROF-048 a 429 on the counts: one line with Try again; '
      'the rest of Profile works', (tester) async {
    await openProfile(
      tester,
      overrides: {
        'GET checks': (_) async =>
            apiError(429, 'rate_limited', retryAfter: 30),
      },
    );
    expect(find.byKey(failed), findsOneWidget);
    expect(find.byKey(stats), findsNothing);
    expect(find.text("Your counts couldn't load."), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(failed), matching: find.text('Try again')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile.permissions')), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-PROF-049 a failure after counts keeps the counts', (
    tester,
  ) async {
    var calls = 0;
    final app = await openProfile(
      tester,
      overrides: {
        'GET checks': (_) async => calls++ == 0
            ? FakeBackend.example(200, 'History of checks', '200 First page')
            : apiError(500, 'internal_error'),
      },
    );
    expect(statCount(tester, 'Checks'), '120');
    await pull(tester);
    await tester.pumpAndSettle();
    expect(countRequests(app), hasLength(2));
    expect(statCount(tester, 'Checks'), '120');
    expect(find.byKey(failed), findsNothing);
  });

  testWidgets('TC-PROF-050 pulls and tab changes while the counts load '
      'send one request', (tester) async {
    final app = await openProfile(
      tester,
      overrides: {
        'GET checks': slow(
          (_) =>
              FakeBackend.example(200, 'History of checks', '200 First page'),
          const Duration(seconds: 3),
        ),
      },
    );
    expect(statCount(tester, 'Checks'), isNull);

    await pull(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await pull(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(tab('Check'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tab('Profile'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(countRequests(app), hasLength(1));

    await app.settleAfter(const Duration(seconds: 3));
    expect(statCount(tester, 'Checks'), '120');
    expect(countRequests(app), hasLength(1));
  });

  testWidgets('TC-PROF-051 a 429 is waited out: Try again is off, a pull '
      'sends nothing, the counts come once the wait ends', (tester) async {
    var calls = 0;
    final app = await openProfile(
      tester,
      overrides: {
        'GET checks': (_) async => calls++ == 0
            ? apiError(429, 'rate_limited', retryAfter: 30)
            : FakeBackend.example(200, 'History of checks', '200 First page'),
      },
    );
    final retry = find.descendant(
      of: find.byKey(failed),
      matching: find.byType(TextButton),
    );
    expect(tester.widget<TextButton>(retry).onPressed, isNull);

    await pull(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(countRequests(app), hasLength(1));

    await tester.pump(const Duration(seconds: 26));
    await tester.pumpAndSettle();
    expect(countRequests(app), hasLength(2));
    expect(statCount(tester, 'Checks'), '120');
  });

  testWidgets('TC-PROF-052 a 429 without Retry-After: Try again works at '
      'once', (tester) async {
    var calls = 0;
    final app = await openProfile(
      tester,
      overrides: {
        'GET checks': (_) async => calls++ == 0
            ? apiError(429, 'rate_limited')
            : FakeBackend.example(200, 'History of checks', '200 First page'),
      },
    );
    await app.tap(
      find.descendant(of: find.byKey(failed), matching: find.text('Try again')),
    );
    expect(countRequests(app), hasLength(2));
    expect(statCount(tester, 'Checks'), '120');
  });
}
