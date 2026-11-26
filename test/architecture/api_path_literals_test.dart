import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_routes.dart';

import 'api_path_literals.dart';

/// TC-ARCH-095 … -097 (docs/test-cases/18-architecture.md): the staging
/// tool and the app write no API path by hand, and the tool's steps are
/// listed where it says they are (production audit P-52).
void main() {
  final templates = [for (final r in ApiRoutes.all) r.template];
  const tool = 'tool/staging_check/staging_check.dart';

  group('TC-ARCH-095 normal: no API path written as text', () {
    test('in tool/ and in lib/ (but ApiRoutes and generated parts)', () {
      final found = [
        for (final dir in ['tool', 'lib'])
          for (final f in Directory(dir).listSync(recursive: true))
            if (f is File &&
                f.path.endsWith('.dart') &&
                // Generated parts: their texts are JSON keys.
                !f.path.endsWith('.g.dart') &&
                !f.path.endsWith('.freezed.dart') &&
                !f.path
                    .replaceAll(r'\', '/')
                    .endsWith('core/network/api_routes.dart'))
              for (final hit in apiPathLiterals(
                f.readAsStringSync(),
                templates,
              ))
                '${f.path}:$hit',
      ];
      expect(found, isEmpty, reason: 'Use ApiRoutes.');
    });
  });

  group('TC-ARCH-096 edge: what is and is not a path', () {
    test('a template, one with its ID interpolated, an exact match only', () {
      const code = r"""
dio.post('auth/refresh');
emptyJson('lookups/sessions/$id/end');
emptyJson('lookups/sessions/${session.id}/end');
final line = '${await emptyJson('auth/logout')}';
stdout.writeln('INFO  POST auth/logout, empty JSON body');
// dio.post('auth/logout');
api.post(ApiRoutes.logout);
final note = 'checks are kept';
""";
      expect(apiPathLiterals(code, templates), [
        '1: auth/refresh',
        r'2: lookups/sessions/$id/end',
        r'3: lookups/sessions/${session.id}/end',
        '4: auth/logout',
      ]);
    });
  });

  group("TC-ARCH-097 worst: the tool's steps, listed alike", () {
    test('the header, the usage text and the steps it runs', () {
      final source = File(tool).readAsStringSync();
      final run = {
        for (final m in RegExp("case '([a-z-]+)'").allMatches(source))
          m.group(1)!,
      };
      final usage = RegExp(
        r'const _steps =([\s\S]*?);',
      ).firstMatch(source)!.group(1)!.replaceAll(RegExp(r"'\s*'|'|\n"), '');
      final listed = {
        for (final s in usage.split(',')) s.trim().split(' ').first,
      };
      final header = RegExp(
        r'// Steps: ([\s\S]*?)\.\n',
      ).firstMatch(source)!.group(1)!.replaceAll(RegExp(r'\n//\s*'), ' ');
      final described = {
        for (final s in header.split(';')) s.trim().split(' ').first,
      };
      expect(run, hasLength(18));
      expect(listed, run, reason: 'the usage text');
      expect(described, run, reason: 'the header');
    });
  });
}
