import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-UI-183: the app never says "verify" (backend SRS v1.2: an official's
/// look-up is a "check"; "verification" is the consumer's public website,
/// which the app never touches).
void main() {
  final forbidden = RegExp('verif|যাচাইকরণ|ভেরিফাই', caseSensitive: false);

  for (final file in ['lib/l10n/app_en.arb', 'lib/l10n/app_bn.arb']) {
    test('TC-UI-183 no "verify" in any text of $file', () {
      final texts = jsonDecode(File(file).readAsStringSync()) as Map;
      final found = [
        for (final MapEntry(:key, :value) in texts.entries)
          if (!(key as String).startsWith('@') &&
              value is String &&
              forbidden.hasMatch(value))
            '$key: $value',
      ];
      expect(found, isEmpty);
    });
  }
}
