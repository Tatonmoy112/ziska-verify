import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';

import '../fakes/fake_preferences_service.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: screen sizes, font sizes, accessibility guidelines, and
/// loading states on every main screen (docs/test-cases/
/// 12-device-a11y-perf.md: TC-NFR-011 … -019, TC-UI-011).
void main() {
  /// Visits every main screen; [check] runs on each, named.
  Future<void> tour(
    WidgetTester tester,
    Future<void> Function(String screen) check, {
    void Function()? setUp,

    /// The tour in Bangla (TC-PROF-031).
    bool bangla = false,
  }) async {
    FakePreferencesService language() =>
        FakePreferencesService(language: bangla ? 'bn' : null);
    String text(String english, String bn) => bangla ? bn : english;

    // Logged out: Login, Check your email.
    var app = await startApp(
      tester,
      loggedIn: false,
      preferences: language(),
    );
    setUp?.call();
    await tester.pumpAndSettle();
    await check('Login');
    await logInToCode(app);
    await check('Check your email');

    // Logged in as a supervisor (every feature).
    app = await startApp(
      tester,
      profile: Roles.supervisor,
      preferences: language(),
    );
    setUp?.call();
    await tester.pumpAndSettle();
    await check('Check');

    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    await check('Result');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    Future<void> openTile(String key) async {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await app.tap(find.byKey(Key(key)));
    }

    Future<void> back() async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    await openTile('verify.tool.serials');
    await app.enter(const Key('serials.input'), '1000001,1000002,1000003');
    await check('Bulk lookup list');
    await app.tap(find.byKey(const Key('serials.submit')));
    await check('Bulk results');
    await back();

    await openTile('verify.tool.report');
    await check('Report incident');
    await back();
    await openTile('verify.tool.myReports');
    await check('My reports');
    await back();
    await openTile('verify.tool.bulk');
    await check('Scanner mode');
    await back();
    await app.tap(tab(text('History', 'ইতিহাস')));
    await check('History');
    await app.tap(tab(text('Profile', 'প্রোফাইল')));
    await check('Profile');
    await app.tapText(text('Change password', 'পাসওয়ার্ড বদলান'));
    await check('Change password');
  }

  Future<void> noOverflow(WidgetTester tester, String screen) async {
    expect(tester.takeException(), isNull, reason: 'Layout error on $screen');
  }

  void size(WidgetTester tester, Size logical, {double ratio = 1}) {
    tester.view.physicalSize = logical * ratio;
    tester.view.devicePixelRatio = ratio;
  }

  testWidgets('TC-NFR-011 tablet width', (tester) async {
    await tour(
      tester,
      (s) => noOverflow(tester, s),
      setUp: () => size(tester, const Size(1280, 800)),
    );
  });

  testWidgets('TC-NFR-013 landscape on every main screen', (tester) async {
    await tour(
      tester,
      (s) => noOverflow(tester, s),
      setUp: () => size(tester, const Size(844, 390), ratio: 3),
    );
  });

  testWidgets('TC-NFR-015 the smallest phone width', (tester) async {
    await tour(
      tester,
      (s) => noOverflow(tester, s),
      setUp: () => size(tester, const Size(320, 568), ratio: 2),
    );
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets('TC-NFR-014 font size ${scale}x on every main screen', (
      tester,
    ) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tour(
        tester,
        (s) => noOverflow(tester, s),
        setUp: () => tester.platformDispatcher.textScaleFactorTestValue = scale,
      );
    });

    testWidgets('TC-PROF-031 Bangla at font size ${scale}x on every main '
        'screen', (tester) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tour(
        tester,
        (s) => noOverflow(tester, s),
        setUp: () => tester.platformDispatcher.textScaleFactorTestValue = scale,
        bangla: true,
      );
    });

    testWidgets('TC-PROF-031 Bangla at font size ${scale}x on the '
        'smallest phone', (tester) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tour(
        tester,
        (s) => noOverflow(tester, s),
        setUp: () {
          size(tester, const Size(320, 568), ratio: 2);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
        },
        bangla: true,
      );
    });
  }

  testWidgets('TC-NFR-016 contrast and tap targets; TC-NFR-017 every '
      'control labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tour(tester, (screen) async {
      await expectLater(
        tester,
        meetsGuideline(textContrastGuideline),
        reason: screen,
      );
      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
        reason: screen,
      );
      await expectLater(
        tester,
        meetsGuideline(labeledTapTargetGuideline),
        reason: screen,
      );
    });
    handle.dispose();
  });

  testWidgets('TC-NFR-019 results are not told by colour alone', (
    tester,
  ) async {
    final titles = <String>{};
    for (final (result, title) in [
      ('valid', 'Genuine product'),
      ('warning', 'Genuine, needs attention'),
      ('not_found', 'Not found'),
      ('unassigned', 'Not in a batch'),
    ]) {
      final app = await startApp(
        tester,
        overrides: {
          'POST lookups': always(
            FakeBackend.example(
              200,
              'Look up one item',
              '200 valid: genuine, first check',
            ).withResult(result),
          ),
        },
      );
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text(title), findsWidgets, reason: result);
      // A round icon and a badge in words in the top card, not only a
      // colour (final.md Section 13.1.4).
      final card = find.byType(VerificationResultCard);
      expect(
        find.descendant(of: card, matching: find.byType(Icon)),
        findsWidgets,
        reason: result,
      );
      expect(
        find.descendant(of: card, matching: find.byType(ResultBadge)),
        findsOneWidget,
        reason: result,
      );
      titles.add(title);
    }
    expect(titles, hasLength(4));
  });

  testWidgets('TC-UI-011 a loading state on every data screen', (
    tester,
  ) async {
    Answer late(String request, String example) => slow(
      (_) => FakeBackend.example(200, request, example),
      const Duration(seconds: 3),
    );
    await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'GET checks': late('History of checks', '200 First page'),
        'GET incidents': late('My own reports', '200 The reports'),
        'GET retail-users': late('Pick a retail user', '200 The retail users'),
      },
    );

    Future<void> expectLoading(String screen) async {
      // Several frames: the route is built over a few of them.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final loading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
          find
              .byWidgetPredicate(
                (w) => w.runtimeType.toString().startsWith('Skeleton'),
              )
              .evaluate()
              .isNotEmpty;
      expect(loading, isTrue, reason: screen);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    }

    // Centred first: at the bottom edge a tile sits under the tab bar.
    Future<void> open(String key) async {
      final tile = find.byKey(Key(key));
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      unawaited(Scrollable.ensureVisible(tester.element(tile), alignment: 0.5));
      await tester.pumpAndSettle();
      await tester.tap(tile);
    }

    // Verify-tab screens first: once History is open, its list is also in
    // the tree.
    await open('verify.tool.myReports');
    await expectLoading('My reports');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(tab('History'));
    await expectLoading('History');
    // History's next pages are slow too: let them all arrive.
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
  });
}

extension on ScriptedAnswer {
  /// The same lookup answer with another [result]; the item stays only for
  /// `valid` and `warning`.
  ScriptedAnswer withResult(String result) {
    final data = Map<String, Object?>.of(body['data']! as Map<String, Object?>);
    data['result'] = result;
    if (result == 'warning') data['reasons'] = ['expired'];
    if (result == 'not_found' || result == 'unassigned') {
      data
        ..remove('item')
        ..remove('count');
    }
    return ScriptedAnswer(status, {...body, 'data': data});
  }
}
