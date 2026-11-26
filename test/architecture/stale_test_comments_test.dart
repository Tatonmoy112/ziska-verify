import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-ARCH-110 … -112 (docs/test-cases/18-architecture.md): the tests'
/// comments and labels say what the tests do (production audit P-57).
void main() {
  String read(String path) => File('test/$path').readAsStringSync();

  group('TC-ARCH-110 normal: each comment says what its test does', () {
    test('the security session, History rows, two headers', () {
      final security = read('flow/security_flow_test.dart');
      expect(security, contains('a serial lookup'));
      expect(
        read('flow/history_flow_test.dart'),
        contains('every row says who checked it'),
      );
      expect(
        read('flow/lookup_flow_test.dart'),
        contains('/// Flow tests: LOOK and ERR'),
      );
      expect(
        read('flow/reports_retail_flow_test.dart'),
        contains('/// Flow tests: REP'),
      );
    });

    test('the role profiles: no count to keep in step', () {
      expect(read('fakes/roles.dart'), isNot(contains('The 7 role')));
    });
  });

  group('TC-ARCH-111 edge: a label names the screen as it is now', () {
    test('the serial stack, not bulk lookup', () {
      expect(read('flow/device_a11y_flow_test.dart'), contains('Serial stack'));
      expect(
        read('ui/consistency_fit_test.dart'),
        contains("labels(['serials.input'], 'Serial stack')"),
      );
    });
  });

  group('TC-ARCH-112 worst: nothing stale is left in the tests', () {
    test('no retired area, feature or count', () {
      const stale = [
        '05-bulk.md',
        '08-retail-users.md',
        'a hidden-code lookup',
        'a retail user added',
        "the hidden code's tag",
        "the name on every row is the official's",
        "check('Bulk",
        "'Bulk lookup')",
        "Bulk lookup's empty-list",
        'The 7 role profiles',
      ];
      final left = [
        for (final f in Directory('test').listSync(recursive: true))
          if (f is File &&
              f.path.endsWith('.dart') &&
              !f.path.endsWith('stale_test_comments_test.dart'))
            for (final phrase in stale)
              if (f.readAsStringSync().contains(phrase)) '${f.path}: $phrase',
      ];
      expect(left, isEmpty);
    });
  });
}
