import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: ROLE and NAV (docs/test-cases/03-roles-nav.md).
void main() {
  group('ROLE', () {
    testWidgets('TC-ROLE-001 Supervisor', (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      await expectRole(
        tester,
        history: true,
        lookupForm: true,
        tileNames: {'bulk', 'serials', 'report', 'myReports'},
      );
    });

    testWidgets('TC-ROLE-002 Field inspector', (tester) async {
      await startApp(tester, profile: Roles.fieldInspector);
      await expectRole(
        tester,
        history: true,
        lookupForm: true,
        tileNames: {'bulk', 'serials', 'report', 'myReports'},
      );
    });

    testWidgets('TC-ROLE-003 Head office auditor', (tester) async {
      await startApp(tester, profile: Roles.auditor);
      await expectRole(tester, history: true, lookupForm: true, tileNames: {});
      expect(find.text('MORE'), findsNothing);
    });

    testWidgets('TC-ROLE-004 Senior seller: bulk lookup and own history', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.seniorSeller);
      await expectRole(
        tester,
        history: true,
        lookupForm: true,
        tileNames: {'bulk', 'serials'},
      );
    });

    testWidgets('TC-ROLE-005 Retail seller: lookup and own history', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.retailSeller);
      await expectRole(tester, history: true, lookupForm: true, tileNames: {});
      expect(find.byKey(const Key('verify.camera')), findsOneWidget);
      expect(find.text('MORE'), findsNothing);
    });

    testWidgets('TC-ROLE-008 Retail seller with history turned off', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.retailSellerNoHistory);
      await expectRole(
        tester,
        history: false,
        lookupForm: true,
        tileNames: {},
      );
    });

    testWidgets('TC-ROLE-006 Incident reporter: no lookup, reports only', (
      tester,
    ) async {
      final app = await startApp(tester, profile: Roles.incidentReporter);
      await expectRole(
        tester,
        history: false,
        lookupForm: false,
        tileNames: {'report', 'myReports'},
      );
      // Without item:lookup the formats are never asked for.
      expect(app.backend.sent('GET', 'formats'), isEmpty);
    });

    testWidgets('TC-ROLE-007 Trainee: no features yet', (tester) async {
      await startApp(tester, profile: Roles.trainee);
      await expectRole(
        tester,
        history: false,
        lookupForm: false,
        tileNames: {},
        noFeatures: true,
      );
    });
  });

  group('NAV', () {
    testWidgets('TC-NAV-004 tabs keep their state; tapping the current tab '
        'stays', (tester) async {
      final app = await startApp(tester);
      await app.tap(tab('History'));
      await app.enter(const Key('history.search'), 'MA-2026');
      await app.settleAfter(const Duration(milliseconds: 500));

      await app.tap(tab('Check'));
      expect(find.text('Welcome back,'), findsOneWidget);
      await app.tap(tab('History'));
      final search = tester.widget<TextField>(
        find.byKey(const Key('history.search')),
      );
      expect(search.controller!.text, 'MA-2026');

      await app.tap(tab('History'));
      expect(find.byKey(const Key('history.search')), findsOneWidget);
    });

    testWidgets('TC-NAV-005 Android back on another tab returns to Verify', (
      tester,
    ) async {
      final app = await startApp(tester);
      await app.tap(tab('Profile'));
      expect(find.byKey(const Key('profile.logout')), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Welcome back,'), findsOneWidget);
    });

    testWidgets('TC-NAV-006 the header shortcut opens Profile', (
      tester,
    ) async {
      final app = await startApp(tester);
      await app.tap(find.byTooltip('Profile').first);
      expect(find.byKey(const Key('profile.logout')), findsOneWidget);
    });

    testWidgets('TC-ERR-006 an unknown route shows "Not available."', (
      tester,
    ) async {
      final app = await startApp(tester);
      GoRouter.of(tester.element(find.text('Welcome back,'))).go('/nowhere');
      await tester.pumpAndSettle();
      expect(find.text('Not available.'), findsOneWidget);

      await app.tapText('Try again');
      expect(find.text('Welcome back,'), findsOneWidget);
    });
  });
}
