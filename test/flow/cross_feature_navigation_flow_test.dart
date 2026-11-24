import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/route_paths.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-NAV-019 … -021 (docs/test-cases/03-roles-nav.md): Check opens the
/// report pages of another feature through the router (final.md §9, the
/// navigation rule of production audit P-9). Pinned before Check's
/// screens gave up opening those routes themselves.
void main() {
  GoRouter routerOf(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first));

  /// The page on top: a pushed page is the last match, its own location.
  Uri at(WidgetTester tester) {
    final config = routerOf(tester).routerDelegate.currentConfiguration;
    final last = config.matches.last;
    return last is ImperativeRouteMatch ? last.matches.uri : config.uri;
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  group('TC-NAV-019 Check opens New report and My reports', () {
    for (final (tool, path) in [
      ('verify.tool.report', RoutePaths.reportIncident),
      ('verify.tool.myReports', RoutePaths.myReports),
    ]) {
      testWidgets('$tool: the page opens, the camera waits, Back resumes '
          'it', (tester) async {
        final app = await startApp(tester, profile: Roles.supervisor);
        expect(app.scanner.session!.running, isTrue);

        await app.tap(find.byKey(Key(tool)));
        expect(at(tester).path, path);
        expect(app.scanner.session!.running, isFalse);

        await back(tester);
        expect(at(tester).path, RoutePaths.home);
        expect(find.byKey(const Key('verify.input')), findsOneWidget);
        expect(app.scanner.session!.running, isTrue);
      });
    }
  });

  group('TC-NAV-020 a result opens New report with its check', () {
    testWidgets("the form carries the result's reference", (tester) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text('Genuine product'), findsOneWidget);

      await app.tap(find.byKey(const Key('result.report')));
      final ref = at(tester).queryParameters['check_ref'];
      expect(at(tester).path, RoutePaths.reportIncident);
      expect(ref, matches(RegExp(r'^MA-\d{4}-\d{6}$')));
      expect(find.text(ref!), findsOneWidget);
      // (Back asks before dropping a report with its check: TC-REP-067.)
    });
  });

  group('TC-NAV-021 edge and worst: no permission, and Back twice', () {
    testWidgets('without incident:report: no report tool, no report '
        'button on a result', (tester) async {
      final app = await startApp(tester, profile: Roles.auditor);
      expect(find.byKey(const Key('verify.tool.report')), findsNothing);
      expect(find.byKey(const Key('verify.tool.myReports')), findsNothing);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text('Genuine product'), findsOneWidget);
      expect(find.byKey(const Key('result.report')), findsNothing);
    });

    testWidgets('New report, then My reports, then Back twice: Check with '
        'its camera, once', (tester) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      await app.tap(find.byKey(const Key('verify.tool.report')));
      await back(tester);
      await app.tap(find.byKey(const Key('verify.tool.myReports')));
      await back(tester);
      expect(at(tester).path, RoutePaths.home);
      expect(app.scanner.session!.running, isTrue);
      // A Back on Check leaves the app, not a page left open behind it.
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
