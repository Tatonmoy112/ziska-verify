import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-ARCH-116 … -118 (docs/test-cases/18-architecture.md): the small notes
/// say what is there, and none repeats the line below it (production audit
/// P-59).
void main() {
  String read(String path) => File(path).readAsStringSync();

  /// The doc comment right above the first line containing [declaration].
  String docAbove(String path, String declaration) {
    final lines = read(path).split('\n');
    final at = lines.indexWhere((l) => l.contains(declaration));
    expect(at, isNot(-1), reason: '$path: $declaration');
    final doc = <String>[];
    for (var i = at - 1; i >= 0 && lines[i].trim().startsWith('///'); i--) {
      doc.insert(0, lines[i].trim());
    }
    return doc.join(' ');
  }

  const photo = 'lib/core/services/media/image_picker_photo_service.dart';

  group('TC-ARCH-116 normal: each note says what is there', () {
    test('the image pin, the scan exceptions, the interceptors', () {
      final pubspec = read('pubspec.yaml');
      expect(pubspec, contains('tool/staging_check'));
      expect(pubspec, isNot(contains('QR-sheet generator')));
      expect(
        read('.github/workflows/ci.yml'),
        contains('create one at the root'),
      );
      expect(
        docAbove('lib/app/di/network_module.dart', 'NetworkStack buildNetwork'),
        contains('the refresh client'),
      );
    });

    test('Retry-After, the app bar, the loader', () {
      expect(
        docAbove('lib/core/errors/app_exception.dart', 'Duration? retryAfter'),
        contains('cannot be read'),
      );
      expect(
        docAbove('lib/shared/widgets/navy_app_bar.dart', 'class NavyAppBar'),
        contains('Scanner mode'),
      );
      expect(
        docAbove(
          'lib/features/verification/presentation/screens/verifying_view.dart',
          'void start(',
        ),
        contains('[delay]'),
      );
    });
  });

  group('TC-ARCH-117 edge: what the app uses is not said to be for tests', () {
    test('the app uses fromValues and shrink, the tests the adapter', () {
      expect(
        docAbove('lib/app/config/app_config.dart', 'AppConfig.fromValues('),
        isNot(contains('for tests')),
      );
      expect(
        docAbove(photo, 'static Future<Uint8List> shrink('),
        allOf(isNot(contains('for tests')), contains('[prepare]')),
      );
      // Only the automated tests replace the transport: said so.
      expect(
        docAbove('lib/app/di/network_module.dart', 'NetworkStack buildNetwork'),
        contains('for automated flow tests'),
      );
    });
  });

  group('TC-ARCH-118 worst: no note repeats the line below it', () {
    test('the four are gone', () {
      for (final (path, note) in [
        (
          'lib/features/verification/presentation/screens/verifying_view.dart',
          '/// A lookup started.',
        ),
        ('lib/shared/widgets/gradient_header.dart', '/// Shows the back'),
        (
          'lib/shared/design_system/tokens/app_radius.dart',
          '/// Corner radius tokens.',
        ),
        ('lib/core/network/api_routes.dart', '/// The HTTP methods the app'),
      ]) {
        expect(read(path), isNot(contains(note)), reason: path);
      }
    });
  });
}
