import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/media/image_picker_photo_service.dart';
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

  group('TC-REP-060 never over 2,048 px (SRS FR-INC-04)', () {
    /// A fake encoder: each call gives a new "image" whose size is noted.
    final sizes = <Uint8List, (int, int)>{};
    final calls = <(int, int)>[];
    Uint8List made((int, int) size) {
      final out = bytes(10 + sizes.length);
      sizes[out] = size;
      return out;
    }

    setUp(() {
      sizes.clear();
      calls.clear();
    });

    test(
      'a size the phone can read: one pass to 2048 on the longer side',
      () async {
        final original = made((4000, 3000));
        await ImagePickerPhotoService.shrink(
          original,
          compress: (b, w, h, q) async {
            calls.add((w, h));
            return made((w, h));
          },
          sizeOf: (b) async => sizes[b],
        );
        expect(calls, [(2048, 1536)]);
      },
    );

    test('a size it cannot read (HEIC): a second pass when the result is '
        'still too large', () async {
      final original = bytes(5);
      // The compressor keeps both sides at least 2048: a 4:3 photo comes
      // out 2731 x 2048.
      await ImagePickerPhotoService.shrink(
        original,
        compress: (b, w, h, q) async {
          calls.add((w, h));
          return made(b == original ? (2731, 2048) : (w, h));
        },
        sizeOf: (b) async => sizes[b],
      );
      expect(calls, [(2048, 2048), (2048, 1536)]);
    });

    test('a size it cannot read, already within 2048: one pass', () async {
      final original = bytes(5);
      await ImagePickerPhotoService.shrink(
        original,
        compress: (b, w, h, q) async {
          calls.add((w, h));
          return made((1600, 1200));
        },
        sizeOf: (b) async => sizes[b],
      );
      expect(calls, [(2048, 2048)]);
    });

    test('a small photo is never enlarged', () async {
      final original = made((800, 600));
      await ImagePickerPhotoService.shrink(
        original,
        compress: (b, w, h, q) async {
          calls.add((w, h));
          return made((w, h));
        },
        sizeOf: (b) async => sizes[b],
      );
      expect(calls, [(800, 600)]);
    });
  });
}
