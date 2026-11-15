import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../ui/source_scan.dart';

/// TC-SEC-028: the product picture is never written to the phone's
/// storage (final.md Sections 12.1, 13.1.4; backend D21). Pictures load
/// through `PictureImages` into Flutter's memory image cache only.
void main() {
  test('no disk image cache package is in the app', () {
    final lock = File('pubspec.lock').readAsStringSync();
    for (final package in [
      'cached_network_image',
      'flutter_cache_manager',
      'extended_image',
      'octo_image',
    ]) {
      expect(lock, isNot(contains('\n  $package:')), reason: package);
    }
  });

  test('the app writes no file and asks for no app folder', () {
    expect(
      scan(
        RegExp(
          r'writeAsBytes|writeAsString|openWrite\(|getTemporaryDirectory|'
          'getApplicationDocumentsDirectory|getApplicationSupportDirectory|'
          'CacheManager',
        ),
      ),
      isEmpty,
    );
  });
}
