import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: permission edge cases and navigation
/// (docs/test-cases/03-roles-nav.md, TC-ROLE-009 and TC-NAV-008 and later).
void main() {
  const loginTitle = 'Login to Track & Trace';
  final lookupForm = find.byKey(const Key('verify.input'));

  Future<void> go(WidgetTester tester, String location) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> addAndSend(FlowApp app) async {
    for (final serial in ['1000001', '1000002', '1000003']) {
      await app.enter(const Key('serials.input'), serial);
    }
    await app.tap(find.byKey(const Key('serials.submit')));
  }

  group('ROLE', () {
    testWidgets('TC-ROLE-009 an unknown permission is ignored', (
      tester,
    ) async {
      await startApp(
        tester,
        profile: Roles.only(['item:lookup', 'report:everything']),
      );
      await expectRole(tester, history: false, lookupForm: true, tileNames: {});
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-ROLE-010 duplicate permissions show each feature once', (
      tester,
    ) async {
      await startApp(
        tester,
        profile: Roles.only([
          'item:lookup',
          'item:lookup',
          'item:bulk_lookup',
          'item:bulk_lookup',
        ]),
      );
      await expectRole(
        tester,
        history: false,
        lookupForm: true,
        tileNames: {'bulk', 'serials'},
      );
    });

    testWidgets('TC-ROLE-011 a permission in capitals is unknown', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.only(['ITEM:LOOKUP']));
      await expectRole(
        tester,
        history: false,
        lookupForm: false,
        tileNames: {},
        noFeatures: true,
      );
    });

    for (final (name, profile) in [
      ('missing', {...Roles.fieldInspector}..remove('permissions')),
      ('null', {...Roles.fieldInspector, 'permissions': null}),
    ]) {
      testWidgets('TC-ROLE-012 permissions $name: nothing unlisted shown', (
        tester,
      ) async {
        await startApp(tester, profile: profile);
        expect(lookupForm, findsNothing);
        expect(tab('History'), findsNothing);
        for (final key in tiles.values) {
          expect(find.byKey(key), findsNothing);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('TC-ROLE-013 bulk lookup only', (tester) async {
      await startApp(tester, profile: Roles.only(['item:bulk_lookup']));
      await expectRole(
        tester,
        history: false,
        lookupForm: false,
        tileNames: {'bulk', 'serials'},
      );
      expect(find.byKey(const Key('verify.camera')), findsNothing);
    });

    testWidgets('TC-ROLE-014 history only', (tester) async {
      await startApp(tester, profile: Roles.only(['history:own']));
      await expectRole(
        tester,
        history: true,
        lookupForm: false,
        tileNames: {},
        noFeatures: true,
      );
    });

    testWidgets('TC-ROLE-016 retail users only', (tester) async {
      await startApp(tester, profile: Roles.only(['retail_user:add']));
      await expectRole(
        tester,
        history: false,
        lookupForm: false,
        tileNames: {},
        noFeatures: true,
      );
    });

    testWidgets('TC-ROLE-017 a reporter without lookup picks a retail '
        'user', (tester) async {
      final app = await startApp(tester, profile: Roles.incidentReporter);
      await app.tap(find.byKey(const Key('verify.tool.report')));
      await app.tap(find.byKey(const Key('report.retailUser')));
      expect(find.text('Rahim Store'), findsOneWidget);
      expect(app.backend.sent('GET', 'retail-users'), isNotEmpty);
    });

    testWidgets('TC-ROLE-018 a permission lost on its own screen moves the '
        'official Home', (tester) async {
      final app = await startApp(
        tester,
        overrides: {'POST lookups/serials': always(apiError(403, 'forbidden'))},
      );
      final mesBefore = app.backend.sent('GET', 'me').length;
      await app.tap(find.byKey(const Key('verify.tool.serials')));
      app.backend.profile = Roles.only([
        'history:own',
        'incident:report',
        'item:lookup',
      ]);
      await addAndSend(app);

      expect(app.backend.sent('GET', 'me').length, mesBefore + 1);
      expect(find.byKey(const Key('serials.input')), findsNothing);
      expect(lookupForm, findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify.tool.serials')), findsNothing);
    });

    testWidgets('TC-ROLE-020 a 403 while the profile still lists the '
        'permission: one reload, no loop', (tester) async {
      final app = await startApp(
        tester,
        overrides: {'POST lookups/serials': always(apiError(403, 'forbidden'))},
      );
      final mesBefore = app.backend.sent('GET', 'me').length;
      await app.tap(find.byKey(const Key('verify.tool.serials')));
      await addAndSend(app);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(app.backend.sent('GET', 'me').length, mesBefore + 1);
      expect(app.backend.sent('POST', 'lookups/serials'), hasLength(1));
      expect(find.textContaining('Reference'), findsWidgets);
    });
  });

  group('NAV', () {
    testWidgets('TC-NAV-008 a result without its data returns to Verify', (
      tester,
    ) async {
      await startApp(tester);
      await go(tester, '/home/result');
      expect(lookupForm, findsOneWidget);
    });

    testWidgets('TC-NAV-010 Android back on every nested screen', (
      tester,
    ) async {
      final app = await startApp(tester, profile: Roles.supervisor);

      Future<void> openAndBack(
        Future<void> Function() open,
        Finder home,
      ) async {
        await open();
        await back(tester);
        expect(home, findsOneWidget);
      }

      await openAndBack(() async {
        await app.enter(const Key('verify.input'), '1000001');
        await app.tap(find.byKey(const Key('verify.submit')));
      }, lookupForm);
      for (final key in tiles.values) {
        await openAndBack(() => app.tap(find.byKey(key)), lookupForm);
      }
      await app.tap(tab('Profile'));
      await openAndBack(
        () => app.tapText('Change password'),
        find.byKey(const Key('profile.logout')),
      );
    });

    testWidgets('TC-NAV-011 feature screens open above the bottom bar', (
      tester,
    ) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      for (final key in tiles.values) {
        await tester.scrollUntilVisible(
          find.byKey(key),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await app.tap(find.byKey(key));
        expect(find.byType(NavigationBar), findsNothing, reason: '$key');
        await back(tester);
        expect(find.byType(NavigationBar), findsOneWidget, reason: '$key');
        expect(lookupForm, findsOneWidget, reason: '$key');
      }
    });

    testWidgets('TC-NAV-012 Android back on Profile goes to Verify', (
      tester,
    ) async {
      final app = await startApp(tester);
      await app.tap(tab('Profile'));
      await back(tester);
      expect(lookupForm, findsOneWidget);
    });

    testWidgets('TC-NAV-013 pre-login routes after login go Home', (
      tester,
    ) async {
      await startApp(tester);
      for (final path in [
        '/login',
        '/forgot-password',
        '/request-access',
        '/splash',
      ]) {
        await go(tester, path);
        expect(lookupForm, findsOneWidget, reason: path);
      }
    });

    testWidgets('TC-NAV-014 feature routes while logged out go to Login', (
      tester,
    ) async {
      await startApp(tester, loggedIn: false);
      for (final path in ['/home/bulk-lookup', '/history']) {
        await go(tester, path);
        expect(find.text(loginTitle), findsOneWidget, reason: path);
      }
    });

    testWidgets('TC-NAV-015 the navigation log holds route names only', (
      tester,
    ) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await app.tap(find.byKey(const Key('result.report')));

      final log = app.logger.lines.join('\n');
      expect(log, isNot(contains('MA-2026')));
      expect(log, isNot(contains('1000001')));
      expect(log, isNot(contains('check_ref')));
    });
  });
}
