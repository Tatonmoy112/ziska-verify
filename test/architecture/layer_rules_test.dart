import 'package:flutter_test/flutter_test.dart';

import 'layer_rules.dart';

/// TC-ARCH-001 … -011 (docs/test-cases/18-architecture.md): the layer rules
/// of final.md §3, §4 and §11 hold for every hand-written file in `lib/`.
///
/// A break that is known and planned is listed in [knownBreaks] with the
/// finding that fixes it (docs/production-audit.md); a fixed one must be
/// taken off the list.
void main() {
  group('lib/ (the real code)', () {
    late Map<String, String> sources;
    late Set<String> plugins;

    setUpAll(() {
      sources = readLib('lib');
      plugins = pluginPackages('.dart_tool/package_config.json');
    });

    List<Violation> check() =>
        LayerRules(plugins: plugins, routeOwners: routeOwners).check(sources);

    test('TC-ARCH-001 keeps every layer rule (only known breaks)', () {
      final unknown = check().where((v) => !knownBreaks.containsKey(v.key));
      expect(
        unknown.map((v) => '$v'),
        isEmpty,
        reason:
            'Fix the import, or (only with a planned fix) list it in '
            'knownBreaks with its finding.',
      );
    });

    test('TC-ARCH-002 every known break still exists', () {
      final found = check().map((v) => v.key).toSet();
      final fixed = knownBreaks.keys.where((k) => !found.contains(k));
      expect(
        fixed,
        isEmpty,
        reason: 'Fixed: take these off knownBreaks.',
      );
    });

    test('TC-ARCH-018 the route table names every route once', () {
      final names = RegExp(r'static const (\w+) =')
          .allMatches(sources['core/navigation/route_names.dart']!)
          .map((m) => m.group(1))
          .toSet();
      expect(names, isNotEmpty);
      expect(routeOwners.keys.toSet(), names);
      expect(
        routeOwners.values.toSet(),
        everyElement(
          isIn({
            'authentication',
            'verification',
            'history',
            'incidents',
            'profile',
          }),
        ),
      );
    });

    test('TC-ARCH-015 a permission key is written in one place only', () {
      // The keys of `GET me`, the withdrawn ones too (final.md §7). Code
      // reads `Permission` and `Profile.canLookup`…; a key typed anywhere
      // else could be mistyped and silently hide a feature (P-4).
      final key = RegExp(
        '[\'"](item:lookup|item:bulk_lookup|history:own|incident:report|'
        'history:all|retail_user:add)[\'"]',
      );
      final comment = RegExp(r'//[^\n]*');
      final found = [
        for (final MapEntry(key: file, value: source) in sources.entries)
          if (!isGenerated(file) && file != permissionsHome)
            for (final m in key.allMatches(source.replaceAll(comment, '')))
              '$file: ${m.group(0)}',
      ];
      expect(found, isEmpty, reason: 'Use Permission / Profile.can…');
      expect(
        key.allMatches(sources[permissionsHome]!).map((m) => m.group(1)),
        containsAll([
          'item:lookup',
          'item:bulk_lookup',
          'history:own',
          'incident:report',
        ]),
        reason: 'the keys are defined in $permissionsHome',
      );
    });

    test('TC-ARCH-003 reads the code and finds the plugins', () {
      expect(sources.length, greaterThan(150));
      expect(sources.keys, contains('main.dart'));
      expect(
        sources.keys.where((p) => p.endsWith('.g.dart')),
        isEmpty,
      );
      expect(
        sources.keys.where((p) => p.endsWith('.freezed.dart')),
        isEmpty,
      );
      // Read for what it imports, never reported.
      expect(
        sources.keys,
        contains('l10n/generated/app_localizations.dart'),
      );
      expect(
        plugins,
        containsAll([
          'mobile_scanner',
          'image_picker',
          'url_launcher',
          'flutter_secure_storage',
          'shared_preferences',
          'permission_handler',
          'connectivity_plus',
          'package_info_plus',
          'flutter_image_compress',
        ]),
      );
      for (final pure in ['dio', 'logger', 'intl', 'get_it', 'flutter_bloc']) {
        expect(plugins, isNot(contains(pure)), reason: pure);
      }
    });
  });

  group('edge cases', () {
    List<Violation> check(Map<String, String> files) => const LayerRules(
      plugins: {'mobile_scanner'},
      routeOwners: {
        'home': 'verification',
        'scannerMode': 'verification',
        'reportIncident': 'incidents',
      },
    ).check(files);

    test('TC-ARCH-004 generated code: not reported itself, but Flutter '
        'reached through it is', () {
      final found = check({
        // Breaks R1, but generated: not reported.
        'l10n/generated/app_localizations.dart':
            "import 'package:flutter/widgets.dart';\n"
            "import 'package:ziska_verify/features/a/data/x.dart';",
        'features/a/data/x.dart': '',
        'features/a/domain/entities/e.dart':
            "import 'package:ziska_verify/l10n/generated/app_localizations.dart';",
      });
      expect(found.map((v) => v.rule), [Rule.domainReachesFlutter]);
      expect(found.single.file, 'features/a/domain/entities/e.dart');
      expect(
        found.single.detail,
        'l10n/generated/app_localizations.dart -> package:flutter',
      );
    });

    test('TC-ARCH-005 an export and a relative import count as imports', () {
      final found = check({
        'features/a/data/x.dart': '',
        'features/a/presentation/screens/s.dart':
            "export 'package:ziska_verify/features/a/data/x.dart';",
        'features/a/presentation/widgets/w.dart': "import '../../data/x.dart';",
      });
      expect(found.map((v) => '${v.rule.id} ${v.file} -> ${v.detail}'), [
        'R5 features/a/presentation/screens/s.dart -> features/a/data/x.dart',
        'R5 features/a/presentation/widgets/w.dart -> features/a/data/x.dart',
      ]);
    });

    test('TC-ARCH-006 comments, quotes and show / as / hide clauses', () {
      final found = check({
        'features/a/data/x.dart': '',
        'features/a/domain/y.dart': '',
        'features/a/presentation/s.dart':
            "// import 'package:ziska_verify/features/a/data/x.dart';\n"
            '/* an old one:\n'
            "import 'package:ziska_verify/features/a/data/x.dart';\n"
            '*/\n'
            'import "package:ziska_verify/features/a/domain/y.dart"\n'
            '    show Y,\n'
            '        Z;\n'
            "import 'package:ziska_verify/features/a/domain/y.dart' as y;\n"
            "import 'package:ziska_verify/features/a/data/x.dart' hide X;",
      });
      expect(found.map((v) => '${v.rule.id} ${v.detail}'), [
        'R5 features/a/data/x.dart',
      ]);
    });

    test('TC-ARCH-007 allowed links are not reported', () {
      final found = check({
        'main.dart': "import 'package:ziska_verify/app/app.dart';",
        'app/app.dart':
            "import 'package:get_it/get_it.dart';\n"
            "import 'package:dio/dio.dart';\n"
            "import 'package:ziska_verify/features/a/data/x.dart';\n"
            "import 'package:ziska_verify/features/a/presentation/s.dart';",
        'core/services/scanner.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';\n"
            "import 'package:ziska_verify/core/errors/result.dart';",
        'core/errors/result.dart': "import 'dart:async';",
        'shared/widgets/w.dart':
            "import 'package:flutter/widgets.dart';\n"
            "import 'package:ziska_verify/core/errors/result.dart';",
        // The app-wide profile entity and Cubit (final.md §4).
        'features/profile/domain/entities/profile.dart': '',
        'features/profile/presentation/bloc/profile_cubit.dart': '',
        'features/a/presentation/s.dart':
            "import 'package:ziska_verify/features/profile/domain/entities/profile.dart';\n"
            "import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';\n"
            "import 'package:ziska_verify/features/a/domain/u.dart';\n"
            "import 'package:ziska_verify/shared/widgets/w.dart';",
        'features/a/domain/u.dart':
            "import 'dart:async';\n"
            "import 'package:meta/meta.dart';\n"
            "import 'package:collection/collection.dart';\n"
            "import 'package:ziska_verify/core/errors/result.dart';",
        'features/a/data/x.dart':
            "import 'package:dio/dio.dart';\n"
            "import 'package:ziska_verify/features/a/domain/u.dart';\n"
            "import 'package:ziska_verify/features/a/domain/repositories/r.dart';",
        // A use case and the composition root use repositories (R14 is
        // about presentation only).
        'features/a/domain/repositories/r.dart': '',
        'features/a/domain/usecases/get_x.dart':
            "import 'package:ziska_verify/features/a/domain/repositories/r.dart';",
        'app/router.dart':
            "import 'package:ziska_verify/features/a/domain/repositories/r.dart';",
        // A plugin wrapper as P-7 splits it: the interface alone, the
        // plugin in its own file, which only the composition root imports.
        'core/services/camera/camera_service.dart':
            "import 'package:flutter/widgets.dart';\n"
            'abstract interface class CameraService {}',
        'core/services/camera/plugin_camera_service.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';\n"
            "import 'package:ziska_verify/core/services/camera/camera_service.dart';\n"
            'class PluginCameraService implements CameraService {}',
        'app/bootstrap.dart':
            "import 'package:ziska_verify/core/services/camera/plugin_camera_service.dart';",
        'features/a/presentation/camera_screen.dart':
            "import 'package:ziska_verify/core/services/camera/camera_service.dart';",
        // core folders depending one way only (P-8): the network's session
        // implementation uses the session interface, never the reverse.
        'core/network/dio_session.dart':
            "import 'package:ziska_verify/core/services/session/session.dart';\n"
            "import 'package:ziska_verify/core/network/envelope.dart';",
        'core/network/envelope.dart': '',
        'core/services/session/session.dart':
            "import 'package:ziska_verify/core/services/session/state.dart';",
        'core/services/session/state.dart': '',
      });
      expect(found, isEmpty);
    });
  });

  group('worst cases', () {
    List<Violation> check(Map<String, String> files) => const LayerRules(
      plugins: {'mobile_scanner'},
      routeOwners: {
        'home': 'verification',
        'scannerMode': 'verification',
        'reportIncident': 'incidents',
      },
    ).check(files);

    /// One file breaking one rule, and the rule it must be reported under.
    final cases = <Rule, Map<String, String>>{
      Rule.coreImportsFeature: {
        'core/x.dart':
            "import 'package:ziska_verify/features/a/domain/u.dart';",
        'features/a/domain/u.dart': '',
      },
      Rule.sharedImportsFeature: {
        'shared/x.dart': "import 'package:ziska_verify/app/app.dart';",
        'app/app.dart': '',
      },
      Rule.featureImportsApp: {
        'features/a/presentation/x.dart':
            "import 'package:ziska_verify/app/app.dart';",
        'app/app.dart': '',
      },
      Rule.crossFeature: {
        'features/a/presentation/x.dart':
            "import 'package:ziska_verify/features/b/presentation/y.dart';",
        'features/b/presentation/y.dart': '',
      },
      Rule.presentationImportsData: {
        'features/a/presentation/x.dart':
            "import 'package:ziska_verify/features/a/data/y.dart';",
        'features/a/data/y.dart': '',
      },
      Rule.domainImportsOuterLayer: {
        'features/a/domain/x.dart':
            "import 'package:ziska_verify/features/a/presentation/y.dart';",
        'features/a/presentation/y.dart': '',
      },
      Rule.dataImportsPresentation: {
        'features/a/data/x.dart':
            "import 'package:ziska_verify/features/a/presentation/y.dart';",
        'features/a/presentation/y.dart': '',
      },
      Rule.domainReachesFlutter: {
        'features/a/domain/x.dart': "import 'package:flutter/foundation.dart';",
      },
      Rule.domainReachesImpure: {
        'features/a/domain/x.dart': "import 'dart:io';",
      },
      Rule.pluginOutsideCore: {
        'features/a/presentation/x.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';",
      },
      Rule.getItOutsideApp: {
        'core/x.dart': "import 'package:get_it/get_it.dart';",
      },
      Rule.dioOutsideNetwork: {
        'features/a/presentation/x.dart': "import 'package:dio/dio.dart';",
      },
      Rule.outsideLayers: {
        'features/a/helpers.dart': '',
      },
      Rule.pluginReachedOutsideCore: {
        'features/a/presentation/x.dart':
            "import 'package:ziska_verify/core/services/s.dart';",
        'core/services/s.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';",
      },
      Rule.interfaceWithPlugin: {
        'core/services/x.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';\n"
            'abstract interface class X {}',
      },
      Rule.foreignRoute: {
        'features/verification/presentation/x.dart':
            'void open() => go(RouteNames.reportIncident);',
      },
      Rule.coreFolderCycle: {
        'core/a/x.dart': "import 'package:ziska_verify/core/b/y.dart';",
        'core/b/y.dart': "import 'package:ziska_verify/core/a/z.dart';",
        'core/a/z.dart': '',
      },
      Rule.presentationImportsRepository: {
        'features/a/presentation/bloc/x_cubit.dart':
            "import 'package:ziska_verify/features/a/domain/repositories/r.dart';",
        'features/a/domain/repositories/r.dart': '',
      },
    };

    test('TC-ARCH-008 each rule R1 … R18 is reported, with its file', () {
      expect(cases.keys, unorderedEquals(Rule.values));
      for (final MapEntry(key: rule, value: files) in cases.entries) {
        final found = check(files);
        expect(found.map((v) => v.rule), [rule], reason: rule.id);
        expect(found.single.file, files.keys.first, reason: rule.id);
        expect('${found.single}', startsWith('${rule.id} '), reason: rule.id);
      }
    });

    test('TC-ARCH-016 plugins stay behind core interfaces', () {
      final found = check({
        // shared reaches a plugin through two core files: R15, with the
        // chain.
        'shared/widgets/w.dart': "import 'package:ziska_verify/core/a.dart';",
        'core/a.dart': "import 'package:ziska_verify/core/b.dart';",
        'core/b.dart': "import 'package:mobile_scanner/mobile_scanner.dart';",
        // data too.
        'features/a/data/d.dart': "import 'package:ziska_verify/core/b.dart';",
        // The domain is R9's (not pure Dart), never twice.
        'features/a/domain/u.dart':
            "import 'package:ziska_verify/core/b.dart';",
        // main and app may reach plugins: they compose the app.
        'main.dart': "import 'package:ziska_verify/app/app.dart';",
        'app/app.dart': "import 'package:ziska_verify/core/b.dart';",
        // An interface named only in a comment is not one.
        'core/c.dart':
            "import 'package:mobile_scanner/mobile_scanner.dart';\n"
            '// Not an abstract interface class.\n'
            '/* abstract interface class Old {} */\n'
            'class Plain {}',
      });
      const plugin = 'package:mobile_scanner';
      expect(found.map((v) => '${v.rule.id} ${v.file} -> ${v.detail}'), [
        'R15 features/a/data/d.dart -> core/b.dart -> $plugin',
        'R9 features/a/domain/u.dart -> core/b.dart -> $plugin',
        'R15 shared/widgets/w.dart -> core/a.dart -> core/b.dart -> $plugin',
      ]);
    });

    test('TC-ARCH-018 a screen opens only its own routes, and Home', () {
      final found = check({
        // Its own route, and Home from anywhere: allowed.
        'features/verification/presentation/a.dart':
            'void a() => go(RouteNames.scannerMode);',
        'features/incidents/presentation/b.dart':
            'void b() => go(RouteNames.home);',
        // Another feature's route, in code: R18, once per name.
        'features/verification/presentation/c.dart':
            'void c() => go(RouteNames.reportIncident);\n'
            'void d() => push(RouteNames.reportIncident);',
        // In a comment or a doc comment: not navigation.
        'features/verification/presentation/e.dart':
            '// Opens RouteNames.reportIncident through the router.\n'
            '/// See [RouteNames.reportIncident].\n'
            'void e() {}',
        // A name the table does not know: R18 too, so nothing slips by.
        'features/verification/presentation/f.dart':
            'void f() => go(RouteNames.somewhereNew);',
        // app (the router) opens every route.
        'app/router.dart': 'void r() => go(RouteNames.reportIncident);',
      });
      const screens = 'features/verification/presentation';
      expect(found.map((v) => '${v.rule.id} ${v.file} -> ${v.detail}'), [
        'R18 $screens/c.dart -> RouteNames.reportIncident (incidents)',
        'R18 $screens/f.dart -> RouteNames.somewhereNew (no owner)',
      ]);
    });

    test('TC-ARCH-017 core folders never depend on each other in a circle', () {
      String imp(String path) => "import 'package:ziska_verify/$path';\n";
      final found = check({
        // Three folders in a circle: one break, the whole circle shown.
        'core/a/x.dart': imp('core/b/y.dart'),
        'core/b/y.dart': imp('core/c/z.dart'),
        'core/c/z.dart': imp('core/a/w.dart'),
        'core/a/w.dart': '',
        // A file of the same folder is no circle; one way is no circle.
        'core/d/one.dart': imp('core/d/two.dart') + imp('core/e/three.dart'),
        'core/d/two.dart': imp('core/d/one.dart'),
        'core/e/three.dart': '',
        // A folder and its subfolder count as two folders.
        'core/net/client.dart': imp('core/net/demo/mock.dart'),
        'core/net/demo/mock.dart': imp('core/net/client.dart'),
        // Outside core, folders may depend on each other (screens and
        // their widgets).
        'features/f/presentation/screens/s.dart': imp(
          'features/f/presentation/widgets/w.dart',
        ),
        'features/f/presentation/widgets/w.dart': imp(
          'features/f/presentation/screens/s.dart',
        ),
      });
      expect(found.map((v) => '${v.rule.id} ${v.file} -> ${v.detail}'), [
        'R17 core/a/x.dart -> core/b -> core/c -> core/a',
        'R17 core/net/client.dart -> core/net/demo -> core/net',
      ]);
    });

    test('TC-ARCH-009 one file breaking several rules: every break', () {
      final found = check({
        'features/a/domain/x.dart':
            "import 'package:get_it/get_it.dart';\n"
            "import 'package:dio/dio.dart';\n"
            "import 'package:mobile_scanner/mobile_scanner.dart';\n"
            "import 'package:ziska_verify/features/a/data/y.dart';\n"
            "import 'package:ziska_verify/features/b/domain/z.dart';",
        'features/a/data/y.dart': '',
        'features/b/domain/z.dart': '',
      });
      expect(
        found.map((v) => v.rule),
        unorderedEquals([
          Rule.crossFeature,
          Rule.domainImportsOuterLayer,
          Rule.domainReachesImpure, // get_it
          Rule.domainReachesImpure, // dio
          Rule.domainReachesImpure, // mobile_scanner
          Rule.pluginOutsideCore,
          Rule.getItOutsideApp,
          Rule.dioOutsideNetwork,
        ]),
      );
    });

    test('TC-ARCH-010 Flutter reached through core is shown with its '
        'chain; an import cycle ends', () {
      final found = check({
        'features/a/domain/x.dart':
            "import 'package:ziska_verify/core/a.dart';",
        'core/a.dart': "import 'package:ziska_verify/core/b.dart';",
        'core/b.dart':
            "import 'package:ziska_verify/core/a.dart';\n"
            "import 'package:flutter/widgets.dart';",
      });
      const chain =
          'R8 (domain reaches Flutter): features/a/domain/x.dart -> '
          'core/a.dart -> core/b.dart -> package:flutter';
      expect(found.map((v) => '$v'), [chain]);
    });

    test('TC-ARCH-011 missing code or package list: a clear error', () {
      expect(
        () => readLib('no-such-folder'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('no-such-folder'),
          ),
        ),
      );
      expect(
        () => pluginPackages('no-such-folder/package_config.json'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('flutter pub get'),
          ),
        ),
      );
    });
  });
}

/// The feature that owns each route of `RouteNames` (final.md §9). A
/// screen opens only its own feature's routes and Home; any other route is
/// reached through a callback the router passes in (P-9).
const routeOwners = <String, String>{
  'splash': 'authentication',
  'login': 'authentication',
  'verifyCode': 'authentication',
  'forgotPassword': 'authentication',
  'resetPassword': 'authentication',
  'requestAccess': 'authentication',
  'changePassword': 'authentication',
  'home': 'verification',
  'lookupResult': 'verification',
  'scannerMode': 'verification',
  'serialStack': 'verification',
  'history': 'history',
  'sessionChecks': 'history',
  'myReports': 'incidents',
  'reportIncident': 'incidents',
  'profile': 'profile',
};

/// The one file that writes the permission keys of `GET me`.
const permissionsHome = 'features/profile/domain/entities/profile.dart';

/// Breaks that are known and planned, each with the finding that fixes it,
/// as `'<rule> <file> -> <import>': '<finding>'`. Empty: P-2 (Profile →
/// History's `CheckTotalsCubit`) was fixed on 2026-11-24.
const knownBreaks = <String, String>{};
