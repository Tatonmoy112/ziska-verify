import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';

/// The test product picture (a drawing of a pack, 400 × 300), read once.
final Uint8List testProductPicture = File(
  'test/fixtures/product_picture.png',
).readAsBytesSync();

/// The product pictures in tests: no network (AGENTS.md). Records every
/// address it is asked for. A picture is handed out already decoded, so it
/// shows at once on the test clock; [delay] makes it arrive later and
/// [failures] makes the next loads fail.
class FakePictureImages implements PictureImages {
  static ui.Image? _decoded;

  /// Decodes the test picture once. Needs real time: call it in `setUpAll`
  /// or inside `tester.runAsync`.
  static Future<void> prepare() async {
    _decoded ??= await decodeImageFromList(testProductPicture);
  }

  final asked = <Uri>[];

  /// How many of the next loads fail.
  int failures = 0;

  /// When set, a picture arrives this long after it is asked for.
  Duration? delay;

  @override
  ImageProvider of(Uri address) {
    asked.add(address);
    final fail = failures > 0;
    if (fail) failures--;
    return _TestPicture(fail: fail, delay: delay);
  }
}

/// One load of the test picture; every load is its own cache entry.
class _TestPicture extends ImageProvider<_TestPicture> {
  _TestPicture({required this.fail, this.delay});

  final bool fail;
  final Duration? delay;

  @override
  Future<_TestPicture> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _TestPicture key,
    ImageDecoderCallback decode,
  ) {
    if (fail) return _Failed();
    ImageInfo info() {
      final image = FakePictureImages._decoded;
      if (image == null) {
        throw StateError('Call FakePictureImages.prepare() first.');
      }
      return ImageInfo(image: image.clone());
    }

    final wait = delay;
    return OneFrameImageStreamCompleter(
      wait == null ? SynchronousFuture(info()) : Future.delayed(wait, info),
    );
  }
}

/// A load that fails at once, as a picture the phone cannot fetch or read.
class _Failed extends ImageStreamCompleter {
  bool _reported = false;

  /// Fails once someone listens, as a real request does: the image's own
  /// error builder then handles it.
  @override
  void addListener(ImageStreamListener listener) {
    super.addListener(listener);
    if (_reported) return;
    _reported = true;
    reportError(
      exception: const HttpExceptionWithStatus(404, 'Not found'),
      silent: true,
    );
  }
}

/// The error a failed picture reports (no `dart:io` request is made).
class HttpExceptionWithStatus implements Exception {
  const HttpExceptionWithStatus(this.status, this.message);

  final int status;
  final String message;

  @override
  String toString() => 'HTTP $status: $message';
}
