import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every English text has a Bangla text with the same placeholders
/// (docs/test-cases/09-profile.md TC-PROF-020, -021).
void main() {
  Map<String, dynamic> read(String file) =>
      jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;

  Map<String, String> texts(Map<String, dynamic> arb) => {
    for (final e in arb.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };

  final en = texts(read('lib/l10n/app_en.arb'));
  final bn = texts(read('lib/l10n/app_bn.arb'));

  /// `{name}` and the variable of `{count, plural, …}`.
  Set<String> placeholders(String text) => {
    for (final m in RegExp(r'\{(\w+)[,}]').allMatches(text)) m.group(1)!,
  };

  /// The ICU cases of a plural, for example `=0`, `=1`, `other`.
  Set<String> pluralCases(String text) => {
    for (final m in RegExp(
      r'(=\d+|zero|one|two|few|many|other)\{',
    ).allMatches(text))
      m.group(1)!,
  };

  test('TC-PROF-020 every English key has a non-empty Bangla text; no '
      'extra keys', () {
    expect(bn.keys.toSet().difference(en.keys.toSet()), isEmpty);
    final missing = [
      for (final key in en.keys)
        if ((bn[key] ?? '').trim().isEmpty) key,
    ];
    expect(missing, isEmpty);
  });

  test('TC-PROF-021 each Bangla text keeps the placeholders and plural '
      'cases of its English text', () {
    for (final key in en.keys) {
      expect(
        placeholders(bn[key]!),
        placeholders(en[key]!),
        reason: key,
      );
      expect(pluralCases(bn[key]!), pluralCases(en[key]!), reason: key);
    }
  });
}
