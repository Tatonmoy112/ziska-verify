import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-NAV-016 … -018 (docs/test-cases/03-roles-nav.md): the app's route
/// table and where a deep link lands (final.md §9). Pinned before the
/// router was split by area (production audit P-6).
void main() {
  GoRouter routerOf(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first));

  /// Where the app is now.
  String at(WidgetTester tester) =>
      routerOf(tester).routerDelegate.currentConfiguration.uri.toString();

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  /// Every named route with its full path, nested ones included.
  Map<String, String> table(List<RouteBase> routes, [String parent = '']) => {
    for (final route in routes)
      ...switch (route) {
        GoRoute(:final name, :final path, routes: final children) => {
          ?name: path.startsWith('/') ? path : '$parent/$path',
          ...table(
            children,
            path.startsWith('/') ? path : '$parent/$path',
          ),
        },
        ShellRouteBase(routes: final children) => table(children, parent),
        _ => const <String, String>{},
      },
  };

  group('TC-NAV-016 the route table', () {
    testWidgets('every name with its path, nothing more', (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      final routes = routerOf(tester).configuration.routes;
      expect(table(routes), {
        RouteNames.splash: RoutePaths.splash,
        RouteNames.login: RoutePaths.login,
        RouteNames.verifyCode: RoutePaths.verifyCode,
        RouteNames.forgotPassword: RoutePaths.forgotPassword,
        RouteNames.resetPassword: RoutePaths.resetPassword,
        RouteNames.requestAccess: RoutePaths.requestAccess,
        RouteNames.changePassword: RoutePaths.changePassword,
        RouteNames.lookupResult: RoutePaths.lookupResult,
        RouteNames.scannerMode: RoutePaths.scannerMode,
        RouteNames.serialStack: RoutePaths.serialStack,
        RouteNames.sessionChecks: RoutePaths.sessionChecks,
        RouteNames.myReports: RoutePaths.myReports,
        RouteNames.reportIncident: RoutePaths.reportIncident,
        RouteNames.home: RoutePaths.home,
        RouteNames.history: RoutePaths.history,
        RouteNames.profile: RoutePaths.profile,
      });
    });

    testWidgets('the top-level order: flows above the tabs, the tabs last', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.supervisor);
      final routes = routerOf(tester).configuration.routes;
      expect(
        [
          for (final r in routes)
            r is GoRoute ? r.path : (r is StatefulShellRoute ? 'tabs' : '?'),
        ],
        [
          '/splash',
          '/login',
          '/forgot-password',
          '/request-access',
          '/change-password',
          '/home/result',
          '/home/scanner-mode',
          '/home/serial-stack',
          '/history/sessions/:id',
          '/home/reports',
          '/home/reports/new',
          'tabs',
        ],
      );
      final shell = routes.last as StatefulShellRoute;
      expect(
        [
          for (final b in shell.branches) (b.routes.single as GoRoute).path,
        ],
        ['/home', '/history', '/profile'],
      );
    });
  });

  group('TC-NAV-017 edge: parameters and a missing extra', () {
    testWidgets("a session's path carries its ID, encoded", (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      final router = routerOf(tester);
      expect(
        router.namedLocation(
          RouteNames.sessionChecks,
          pathParameters: {'id': 'S-1'},
        ),
        '/history/sessions/S-1',
      );
      expect(
        router.namedLocation(
          RouteNames.sessionChecks,
          pathParameters: {'id': 'a b/c'},
        ),
        '/history/sessions/a%20b%2Fc',
      );
    });

    testWidgets('Reset password without its email goes back a step', (
      tester,
    ) async {
      await startApp(tester, loggedIn: false);
      await go(tester, RoutePaths.resetPassword);
      expect(at(tester), RoutePaths.forgotPassword);
    });

    testWidgets('a result without its result goes to Check', (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      await go(tester, RoutePaths.lookupResult);
      expect(at(tester), RoutePaths.home);
    });
  });

  group('TC-NAV-018 worst: links the role cannot open, or that are none', () {
    for (final (role, profile, location) in [
      ('auditor', Roles.auditor, RoutePaths.scannerMode),
      ('auditor', Roles.auditor, RoutePaths.serialStack),
      ('auditor', Roles.auditor, RoutePaths.reportIncident),
      ('auditor', Roles.auditor, RoutePaths.myReports),
      ('no history', Roles.retailSellerNoHistory, RoutePaths.history),
      ('no history', Roles.retailSellerNoHistory, '/history/sessions/S-1'),
    ]) {
      testWidgets('$role: $location goes to Check', (tester) async {
        await startApp(tester, profile: profile);
        await go(tester, location);
        expect(at(tester), RoutePaths.home);
      });
    }

    testWidgets('logged out: a logged-in page goes to Login', (tester) async {
      await startApp(tester, loggedIn: false);
      await go(tester, RoutePaths.profile);
      expect(at(tester), RoutePaths.login);
    });

    testWidgets('an address the app does not have: Not available, and Try '
        'again leads back in', (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      await go(tester, '/no-such-page');
      expect(find.text('Not available.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(at(tester), RoutePaths.home);
    });
  });
}
