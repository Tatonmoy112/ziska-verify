import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';

/// The 1 MB photo limit (docs/test-cases/07-reports.md, final.md 13.5.2).
void main() {
  const limit = ImagePickerPhotoService.maxBytes;
  Uint8List bytes(int n) => Uint8List(n)..fillRange(0, n, 1);

  test('TC-REP-029 exactly 1 MB is accepted at the first quality', () async {
    final qualities = <int>[];
    final out = await ImagePickerPhotoService.fitWithinLimit((q) async {
      qualities.add(q);
      return bytes(limit);
    });
    expect(out.lengthInBytes, limit);
    expect(qualities, [85]);
  });

  test('TC-REP-029 1 MB + 1 byte at every quality is too large', () async {
    final qualities = <int>[];
    await expectLater(
      ImagePickerPhotoService.fitWithinLimit((q) async {
        qualities.add(q);
        return bytes(limit + 1);
      }),
      throwsA(
        isA<PhotoException>().having(
          (e) => e.problem,
          'problem',
          PhotoProblem.tooLarge,
        ),
      ),
    );
    expect(qualities, [85, 75, 65]);
  });

  test('a lower quality is tried when 85 is over the limit', () async {
    final out = await ImagePickerPhotoService.fitWithinLimit(
      (q) async => bytes(q == 85 ? limit + 1 : limit - 1),
    );
    expect(out.lengthInBytes, limit - 1);
  });

  test(
    'TC-REP-031 an empty result or an encoder error is unreadable',
    () async {
      for (final encode in <Future<Uint8List> Function(int)>[
        (_) async => Uint8List(0),
        (_) async => throw Exception('corrupt'),
      ]) {
        await expectLater(
          ImagePickerPhotoService.fitWithinLimit(encode),
          throwsA(
            isA<PhotoException>().having(
              (e) => e.problem,
              'problem',
              PhotoProblem.unreadable,
            ),
          ),
        );
      }
    },
  );
}
