import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'traceability.dart';

/// TC-ARCH-104 … -106 (docs/test-cases/18-architecture.md): every
/// automated test case is cited by the test it names, and every ID a test
/// cites is an automated case (production audit P-55).
void main() {
  group('TC-ARCH-104 normal: the real cases and tests', () {
    test('point at each other', () {
      final cases = [
        for (final f in Directory('docs/test-cases').listSync())
          if (f is File && f.path.endsWith('.md'))
            ...readCases(f.readAsStringSync()),
      ];
      expect(cases.length, greaterThan(1000));
      final sources = {
        for (final f in Directory('test').listSync(recursive: true))
          if (f is File &&
              f.path.endsWith('.dart') &&
              // The samples of the check itself.
              !f.path.endsWith('traceability_test.dart') &&
              !f.path.endsWith('traceability.dart'))
            f.path.replaceAll(r'\', '/'): f.readAsStringSync(),
        for (final f in Directory('.github/workflows').listSync())
          if (f is File) f.path.replaceAll(r'\', '/'): f.readAsStringSync(),
        // This file's header only: below it, the IDs are samples.
        'test/architecture/traceability_test.dart': File(
          'test/architecture/traceability_test.dart',
        ).readAsStringSync().split('void main(').first,
      };
      expect(traceProblems(cases, sources), isEmpty);
    });
  });

  group('TC-ARCH-105 edge: how a test cites a case', () {
    test('names, lists, ranges, wrapped comments and data tables', () {
      expect(
        citedIds(r'''
test('TC-AUTH-001 a name', () {});
/// TC-PROF-006, -019 … -021 and
/// -030 (docs/test-cases/09-profile.md)
for (final (id, email) in [('029', 'a@b'), ('031', 'x')]) {
  testWidgets('TC-AUTH-$id refused', (t) async {});
}
'''),
        {
          'TC-AUTH-001',
          'TC-PROF-006',
          'TC-PROF-019',
          'TC-PROF-020',
          'TC-PROF-021',
          'TC-PROF-030',
          'TC-AUTH-029',
          'TC-AUTH-031',
        },
      );
      expect(
        citedIds(r"for (final (id, w) in [('LOOK-024', 1)]) { 'TC-$id'; }"),
        {'TC-LOOK-024'},
      );
      // A bare number belongs to the last area named.
      expect(citedIds('/// TC-LOOK-023 … -025, TC-SEC-016, -017'), {
        'TC-LOOK-023',
        'TC-LOOK-024',
        'TC-LOOK-025',
        'TC-SEC-016',
        'TC-SEC-017',
      });
    });

    test('a case the Auto cell names in a CI workflow, or under a folder', () {
      final cases = readCases(
        '| TC-SEC-024 | x | SEC | P2 | AUTO | ✅ `ci.yml` (scan) | … |\n'
        '| TC-PROF-020 | x | L10N | P2 | AUTO | ✅ `l10n/arb_test` | … |\n',
      );
      expect(
        traceProblems(cases, {
          '.github/workflows/ci.yml': '# TC-SEC-024: fails on a flaw',
          'test/l10n/arb_test.dart': "test('TC-PROF-020 every key', () {});",
        }),
        isEmpty,
      );
    });
  });

  group('TC-ARCH-106 worst: what does not point where it should', () {
    test('each kind is reported', () {
      final cases = readCases(
        '| TC-AUTH-001 | a | POS | P1 | AUTO | ✅ `login_test` | … |\n'
        '| TC-AUTH-002 | b | POS | P1 | AUTO | ✅ `login_test` | … |\n'
        '| TC-AUTH-003 | c | POS | P1 | DEVICE | ✋ | … |\n'
        '| TC-AUTH-004 | d | POS | P1 | AUTO | ✅ | … |\n',
      );
      expect(
        traceProblems(cases, {
          'test/login_test.dart':
              "test('TC-AUTH-001 a', () {});\n"
              "test('TC-AUTH-003 c', () {});\n"
              "test('TC-AUTH-009 gone', () {});\n"
              "test('AUTH-002 b', () {});\n",
          'test/other_test.dart': "test('TC-AUTH-002 b', () {});",
        }),
        [
          'TC-AUTH-002: not cited by login_test',
          'TC-AUTH-004: ✅ but names no test',
          'test/login_test.dart: TC-AUTH-003 is not automated (✋)',
          'test/login_test.dart: TC-AUTH-009 is not a test case',
          'test/login_test.dart:4: AUTH-002 without TC-',
        ],
      );
    });
  });
}
