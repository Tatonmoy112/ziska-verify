import 'package:flutter_test/flutter_test.dart';

import 'layer_rules.dart';
import 'layer_rules_test.dart' show routeOwners;

/// TC-ARCH-062 … -064 (docs/test-cases/18-architecture.md): navigation is
/// wired one way (final.md §9; production audit P-41). A screen opens its
/// own feature's routes and Home itself (R18); the router hands it only
/// the routes of other features, as callbacks (R22).
void main() {
  List<Violation> check(Map<String, String> files) =>
      const LayerRules(plugins: {}, routeOwners: routeOwners).check(files);

  String imp(String path) => "import 'package:ziska_verify/$path';\n";

  const verify = 'features/verification/presentation/screens/verify.dart';
  const stack = 'features/verification/presentation/screens/stack.dart';
  const history = 'features/history/presentation/screens/history.dart';
  const sessions = 'features/verification/presentation/widgets/sessions.dart';

  /// The screens the sample routes build, each in its feature.
  final screens = {
    verify: 'class VerifyScreen extends StatefulWidget {}',
    stack: 'class StackScreen extends StatelessWidget {}',
    history: 'class HistoryScreen extends StatelessWidget {}',
    sessions: 'class SessionsView extends StatelessWidget {}',
  };

  List<String> r22(Map<String, String> files) => [
    for (final v in check({...screens, ...files}))
      if (v.rule.id == 'R22') v.detail,
  ];

  group('TC-ARCH-062 normal: each route reached one way', () {
    test("the router hands a screen another feature's routes", () {
      expect(
        r22({
          'app/router/routes/check_routes.dart':
              '${imp(verify)}'
              'Widget b() => VerifyScreen(\n'
              '  onNewReport: () => push(RouteNames.reportIncident),\n'
              '  onOpenProfile: () => go(RouteNames.profile),\n'
              ');',
        }),
        isEmpty,
      );
    });

    test('a screen opens its own routes itself', () {
      final found = check({
        ...screens,
        stack:
            '${screens[stack]}\n'
            'void open() => push(RouteNames.lookupResult);',
      });
      expect(found, isEmpty);
    });

    test('the real router: no screen is handed a route it opens itself', () {
      final found = const LayerRules(
        plugins: {},
        routeOwners: routeOwners,
      ).check(readLib('lib')).where((v) => v.rule.id == 'R22');
      expect(found.map((v) => '$v'), isEmpty);
    });
  });

  group('TC-ARCH-063 edge: whose callback it is', () {
    test('a widget inside another: the innermost one is handed it', () {
      // The sessions view (verification) sits in History's screen; the
      // session's checks (history) are another feature's to it.
      expect(
        r22({
          'app/router/routes/history_routes.dart':
              '${imp(history)}${imp(sessions)}'
              'Widget b() => HistoryScreen(\n'
              '  sessions: SessionsView(\n'
              '    onOpenChecks: (id) => push(RouteNames.sessionChecks),\n'
              '  ),\n'
              ');',
        }),
        isEmpty,
      );
    });

    test('Home handed in is the second way too', () {
      expect(
        r22({
          'app/router/routes/history_routes.dart':
              '${imp(history)}'
              'Widget b() => HistoryScreen(onDone: () => go(RouteNames.home));',
        }),
        ['HistoryScreen -> RouteNames.home'],
      );
    });

    test('in a comment, or outside any screen: not handed in', () {
      expect(
        r22({
          'app/router/routes/check_routes.dart':
              '${imp(stack)}'
              'final route = GoRoute(name: RouteNames.lookupResult);\n'
              'Widget b() => StackScreen(\n'
              '  // Not RouteNames.lookupResult: the screen opens it.\n'
              ');',
        }),
        isEmpty,
      );
    });

    test('a class of the same name the route file does not import', () {
      expect(
        r22({
          'app/router/routes/check_routes.dart':
              'Widget b() => StackScreen(onOpen: () => '
              'push(RouteNames.lookupResult));',
        }),
        isEmpty,
      );
    });
  });

  group('TC-ARCH-064 worst: its own route handed in', () {
    test('directly in the callback', () {
      expect(
        r22({
          'app/router/routes/check_routes.dart':
              '${imp(stack)}'
              'Widget b() => StackScreen(\n'
              '  onOpenResult: (r) => push(RouteNames.lookupResult, r),\n'
              ');',
        }),
        ['StackScreen -> RouteNames.lookupResult'],
      );
    });

    test('through a helper of the route file, called or torn off', () {
      expect(
        r22({
          'app/router/routes/check_routes.dart':
              '${imp(stack)}${imp(verify)}'
              'List<RouteBase> checkRoutes() {\n'
              '  Future<void> openMany(BuildContext c, Object r) async {\n'
              '    await c.pushNamed(RouteNames.lookupResult, extra: r);\n'
              '  }\n'
              '  void openStack() => push(RouteNames.serialStack);\n'
              '  return [\n'
              '    StackScreen(onOpenResult: (r) => openMany(context, r)),\n'
              '    VerifyScreen(onStack: openStack),\n'
              '  ];\n'
              '}',
        }),
        [
          'StackScreen -> RouteNames.lookupResult',
          'VerifyScreen -> RouteNames.serialStack',
        ],
      );
    });

    test('the scanner session and the stack open the result themselves', () {
      final lib = readLib('lib');
      for (final file in [
        'features/verification/presentation/screens/scan_session_screen.dart',
        'features/verification/presentation/screens/serial_stack_screen.dart',
      ]) {
        expect(lib[file], isNot(contains('onOpenResult')), reason: file);
      }
      expect(lib.values.join(), isNot(contains('OpenLookupResult')));
    });
  });
}
