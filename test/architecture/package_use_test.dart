import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package_use.dart';

/// TC-ARCH-077 … -079 (docs/test-cases/18-architecture.md): every package
/// in `pubspec.yaml` is used (production audit P-46).
void main() {
  /// Every Dart file of [dirs], keyed by its path from the project root.
  Map<String, String> read(List<String> dirs) => {
    for (final dir in dirs)
      for (final f in Directory(dir).listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          f.path.replaceAll(r'\', '/'): f.readAsStringSync(),
  };

  group('TC-ARCH-077 normal: the real project', () {
    test('every package in pubspec.yaml is used', () {
      expect(
        unusedPackages(
          pubspec: File('pubspec.yaml').readAsStringSync(),
          analysisOptions: File('analysis_options.yaml').readAsStringSync(),
          sources: read(['lib', 'test', 'tool']),
        ),
        isEmpty,
        reason: 'Remove the package, or use it.',
      );
    });

    test('the packages P-46 removed stay out', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final p in [
        'flutter_animate',
        'path_provider',
        'http_mock_adapter',
        'integration_test',
      ]) {
        expect(pubspec, isNot(contains('  $p:')), reason: p);
      }
    });
  });

  group('TC-ARCH-078 edge: a tool used through its trace', () {
    const pubspec = '''
name: app
dependencies:
  dio: ^5.0.0
dev_dependencies:
  build_runner: ^2.0.0
  freezed: ^3.0.0
  json_serializable: ^6.0.0
  very_good_analysis: ^10.0.0
  # A comment between packages.
  flutter_launcher_icons: ^0.14.0
  mocktail: ^1.0.0

flutter_launcher_icons:
  android: true
''';
    const analysis =
        'include: package:very_good_analysis/analysis_options.yaml';
    final sources = {
      'lib/a.dart':
          "import 'package:dio/dio.dart';\n"
          "part 'a.freezed.dart';\npart 'a.g.dart';",
      'tool/t.dart': "import 'package:mocktail/mocktail.dart';",
    };

    test('generators, the lint package and a configured tool', () {
      expect(
        unusedPackages(
          pubspec: pubspec,
          analysisOptions: analysis,
          sources: sources,
        ),
        isEmpty,
      );
    });

    test('generators with nothing generated are unused', () {
      expect(
        unusedPackages(
          pubspec: pubspec,
          analysisOptions: analysis,
          sources: {
            'lib/a.dart': "import 'package:dio/dio.dart';",
            'tool/t.dart': "import 'package:mocktail/mocktail.dart';",
          },
        ),
        ['build_runner', 'freezed', 'json_serializable'],
      );
    });
  });

  group('TC-ARCH-079 worst: a package nothing uses', () {
    test('added and never imported, at runtime or for development', () {
      expect(
        unusedPackages(
          pubspec: '''
dependencies:
  dio: ^5.0.0
  path_provider: ^2.0.0
dev_dependencies:
  http_mock_adapter: ^0.6.0
''',
          analysisOptions: '',
          sources: {'lib/a.dart': "import 'package:dio/dio.dart';"},
        ),
        ['path_provider', 'http_mock_adapter'],
      );
    });

    test('a runtime package only tests import is unused at runtime', () {
      expect(
        unusedPackages(
          pubspec: 'dependencies:\n  clock: ^1.0.0\n',
          analysisOptions: '',
          sources: {'test/a_test.dart': "import 'package:clock/clock.dart';"},
        ),
        ['clock'],
      );
    });

    test('a name in a comment or a string is not an import', () {
      expect(
        unusedPackages(
          pubspec: 'dependencies:\n  logger: ^2.0.0\n',
          analysisOptions: '',
          sources: {'lib/a.dart': '// The logger package.\nvar x = "logger";'},
        ),
        ['logger'],
      );
    });
  });
}
