import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-ARCH-113 … -115 (docs/test-cases/18-architecture.md): the README,
/// AGENTS.md and the test cases describe the app as it is (production
/// audit P-58).
void main() {
  String read(String path) => File(path).readAsStringSync();

  /// The rows that describe the app: every current case (a retired one is
  /// named in a note, not a row), the request matrix, the component table
  /// and the test plan's roles.
  Map<String, String> rows() {
    final rows = <String, String>{};
    final files = Directory('docs/test-cases').listSync().whereType<File>();
    for (final file in files.where((f) => f.path.endsWith('.md'))) {
      final name = file.uri.pathSegments.last;
      for (final line in file.readAsLinesSync()) {
        final cells = line.split('|');
        if (line.startsWith('| TC-')) {
          rows[cells[1].trim()] = line;
        } else if (name == '10-errors-network.md' &&
            RegExp(r'^\| \d+ \|').hasMatch(line)) {
          rows['$name request ${cells[1].trim()}'] = line;
        } else if (name == '15-ui.md' && line.startsWith('| `')) {
          rows['$name ${cells[1].trim()}'] = line;
        }
      }
    }
    for (final line in File('docs/test-plan.md').readAsLinesSync()) {
      if (RegExp(r'^\| R\d ').hasMatch(line)) {
        rows['test plan ${line.split('|')[1].trim()}'] = line;
      }
    }
    return rows;
  }

  /// What the app no longer has: the 500-item list sent at once, the
  /// retail users screens, everyone's checks, a hidden code typed.
  final retired = {
    'bulk': RegExp(r'\bbulk\b(?![- ]only)', caseSensitive: false),
    'the retail users screen': RegExp('Retail users'),
    'adding a retail user': RegExp(
      'add(s|ed)? (a |one )?retail user|was added|retail-roles|'
      'POST retail-users',
      caseSensitive: false,
    ),
    "everyone's checks": RegExp(
      "everyone's checks|history:all",
      caseSensitive: false,
    ),
    'a hidden code': RegExp('hidden[ -]code', caseSensitive: false),
  };

  /// Rows that name a retired feature to say it is gone, or that the app
  /// still meets it from the backend.
  const allowed = {
    'TC-ROLE-022': {"everyone's checks"}, // history:all grants nothing.
    'TC-LOOK-096': {'a hidden code'}, // Its formats are sent, not hinted.
    'TC-SEC-014': {'a hidden code'}, // The field is gone.
    'TC-UI-068': {'a hidden code'}, // A check made by one before.
    '15-ui.md `BulkSummaryCard`': {'bulk'}, // Removed with it.
    'TC-MIG-002': {'bulk', 'a hidden code'}, // No old request appears.
    'TC-STG-024': {'a hidden code'}, // The server refuses that way.
    'TC-ARCH-108': {'a hidden code'}, // The masked code of an item.
    'TC-ARCH-111': {'bulk'}, // A label: not bulk lookup.
    // This check's own cases, which name what it looks for.
    'TC-ARCH-114': {'a hidden code'},
    'TC-ARCH-115': {'bulk', "everyone's checks", 'a hidden code'},
  };

  group('TC-ARCH-113 normal: the setup docs and the cases say what is', () {
    test('the README and AGENTS.md', () {
      final readme = read('README.md');
      expect(readme, contains('`ziska-test`'));
      expect(readme, isNot(contains('demo-pharma')));
      expect(readme, contains('iOS has one scheme and no flavors'));
      expect(read('AGENTS.md'), isNot(contains('No commits exist yet')));
      expect(read('docs/test-plan.md'), isNot(contains('demo-pharma')));
    });

    test('the rewritten cases follow their tests', () {
      final all = rows();
      expect(all['TC-E2E-001'], contains('a serial search'));
      expect(all['TC-E2E-005'], contains('serial kept in the field'));
      expect(all['TC-LOOK-089'], contains('a serial stack row'));
      expect(all['TC-LOOK-100'], contains('`not_found` from a typed serial'));
      expect(all['TC-NAV-014'], contains('`/home/serial-stack`'));
      expect(all['TC-NFR-011'], contains('Serial stack with results'));
      expect(all['test plan R1 Supervisor'], contains('Scanner mode'));
    });
  });

  group('TC-ARCH-114 edge: a retired name that is meant stays', () {
    test('each allowed row still names it', () {
      final all = rows();
      for (final MapEntry(key: id, value: features) in allowed.entries) {
        expect(all[id], isNotNull, reason: id);
        for (final feature in features) {
          expect(retired[feature]!.hasMatch(all[id]!), isTrue, reason: id);
        }
      }
    });

    test('a role with the many-items permission only is no feature', () {
      expect(retired['bulk']!.hasMatch('a bulk-only role'), isFalse);
      expect(retired['bulk']!.hasMatch('`item:bulk_lookup`'), isFalse);
      expect(retired['bulk']!.hasMatch('bulk only'), isFalse);
    });
  });

  group('TC-ARCH-115 worst: nothing retired is described as there', () {
    test('no row names a retired screen, field or request', () {
      final left = [
        for (final MapEntry(key: id, value: row) in rows().entries)
          for (final MapEntry(key: feature, value: pattern) in retired.entries)
            if (!(allowed[id]?.contains(feature) ?? false) &&
                pattern.hasMatch(row))
              '$id: $feature',
      ];
      expect(left, isEmpty);
    });

    test('no test is named after a retired screen or goes to its route', () {
      final left = [
        for (final f in Directory('test').listSync(recursive: true))
          if (f is File &&
              f.path.endsWith('.dart') &&
              !f.path.endsWith('stale_test_cases_test.dart') &&
              !f.path.endsWith('stale_test_comments_test.dart'))
            for (final phrase in [
              'bulk lookup',
              'retail users only',
              '/home/bulk-lookup',
              "'bulk':",
            ])
              if (f.readAsStringSync().toLowerCase().contains(phrase))
                '${f.path}: $phrase',
      ];
      expect(left, isEmpty);
    });
  });
}
