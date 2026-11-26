import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-ARCH-107 … -109 (docs/test-cases/18-architecture.md): the comments
/// in `lib/` say what the code does now (production audit P-56).
void main() {
  /// The comments of every hand-written Dart file in `lib/`, by path.
  final comments = {
    for (final f in Directory('lib').listSync(recursive: true))
      if (f is File &&
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.freezed.dart') &&
          !f.path.contains('generated'))
        f.path.replaceAll(r'\', '/'): [
          for (final line in f.readAsLinesSync())
            if (line.trimLeft().startsWith('//'))
              line.trimLeft().replaceFirst(RegExp('^/+ ?'), ''),
        ].join('\n'),
  };
  String of(String path) => comments['lib/$path']!;

  group('TC-ARCH-107 normal: the corrected comments match the code', () {
    test('each names what is there now', () {
      expect(of('app/router/route_paths.dart'), contains('app/shell/'));
      expect(of('core/navigation/route_names.dart'), contains('app/shell/'));
      expect(
        of('core/services/storage/secure_storage_service.dart'),
        contains('scanner session'),
      );
      expect(
        of('features/verification/domain/entities/scan_session.dart'),
        contains('GET lookups/sessions'),
      );
      expect(
        of('features/profile/presentation/bloc/profile_cubit.dart'),
        contains('the shell'),
      );
      expect(
        of('core/services/logging/console_logger_service.dart'),
        contains('startMonitoring'),
      );
      expect(of('core/network/api_data.dart'), contains('answerShape'));
      expect(of('core/network/api_client.dart'), contains('options'));
    });
  });

  group('TC-ARCH-108 edge: words that stay', () {
    test('the masked hidden code, and the retail users feature', () {
      expect(
        of('features/verification/domain/entities/lookup.dart'),
        contains('The hidden code as the API sends it'),
      );
      expect(of('app/di/register.dart'), contains('Retail users'));
    });
  });

  group('TC-ARCH-109 worst: nothing stale is left', () {
    test('no comment describes what is gone', () {
      const stale = [
        'PermissionGate',
        'Enter manually',
        'hidden code stays masked',
        'History, Retail users',
        'Scan card',
        'scan-sessions',
        'answer_shape',
        'Checking 3 items',
        'Used only inside `app/router/`',
        'live in `app/router/` only',
        'Builds the two Dio instances',
        '`bootstrap` sets',
        'debounce 400 ms + restartable',
        'for the phone ID and the two passes',
        'an app defect, logged',
        'and so is\nNo scope',
        'length, and\nscanning',
      ];
      final left = [
        for (final MapEntry(key: path, value: text) in comments.entries)
          for (final phrase in stale)
            if (text.contains(phrase)) '$path: $phrase',
      ];
      expect(left, isEmpty);
    });
  });
}
