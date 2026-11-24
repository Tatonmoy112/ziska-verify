import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';

class ImagePickerPhotoService implements PhotoService {
  ImagePickerPhotoService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const maxSide = 2048;
  static const int maxBytes = 1024 * 1024;

  /// Quality 85 first (backend D39); lower only if 1 MB is exceeded.
  static const List<int> qualities = [85, 75, 65];

  @override
  Future<PreparedPhoto?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    final original = await file.readAsBytes();
    return PreparedPhoto(await prepare(original));
  }

  /// Shrinks and re-encodes [original]; the output keeps no EXIF.
  static Future<Uint8List> prepare(Uint8List original) => shrink(
    original,
    compress: (bytes, width, height, quality) =>
        FlutterImageCompress.compressWithList(
          bytes,
          minWidth: width,
          minHeight: height,
          quality: quality,
          // The defaults apply the orientation to the pixels
          // (`autoCorrectionAngle`), write JPEG, and keep no EXIF
          // (`keepExif: false`).
        ),
    sizeOf: imageSize,
  );

  /// [prepare] with its encoder and size reader given, for tests. When the
  /// original's size cannot be read (HEIC on some phones), the encoder is
  /// asked for [maxSide] on both sides, which it treats as a minimum: the
  /// result is read again and, when its longer side is still over
  /// [maxSide], shrunk once more to it exactly (SRS FR-INC-04).
  static Future<Uint8List> shrink(
    Uint8List original, {
    required Future<Uint8List> Function(
      Uint8List bytes,
      int width,
      int height,
      int quality,
    )
    compress,
    required Future<(int, int)?> Function(Uint8List bytes) sizeOf,
  }) async {
    final size = await sizeOf(original);
    final (width, height) = size == null ? (maxSide, maxSide) : _fit(size);
    final first = await fitWithinLimit(
      (quality) => compress(original, width, height, quality),
    );
    if (size != null) return first;
    final made = await sizeOf(first);
    if (made == null || max(made.$1, made.$2) <= maxSide) return first;
    final (w, h) = _fit(made);
    return fitWithinLimit((quality) => compress(first, w, h, quality));
  }

  /// The size that brings the longer side to [maxSide], never enlarging.
  static (int, int) _fit((int, int) size) {
    final (w, h) = size;
    final scale = min(1, maxSide / max(w, h));
    return ((w * scale).round(), (h * scale).round());
  }

  /// Encodes at each of [qualities] until the photo is at most [maxBytes]
  /// (1 MB exactly is accepted). An encoder error or an empty result is
  /// [PhotoProblem.unreadable]; still too big at the lowest quality is
  /// [PhotoProblem.tooLarge].
  static Future<Uint8List> fitWithinLimit(
    Future<Uint8List> Function(int quality) encode,
  ) async {
    for (final quality in qualities) {
      final Uint8List out;
      try {
        out = await encode(quality);
      } on Exception {
        throw const PhotoException(PhotoProblem.unreadable);
      }
      if (out.isEmpty) throw const PhotoException(PhotoProblem.unreadable);
      if (out.lengthInBytes <= maxBytes) return out;
    }
    throw const PhotoException(PhotoProblem.tooLarge);
  }

  /// The width and height of an encoded image; `null` when the engine
  /// cannot read it (HEIC on some phones).
  static Future<(int, int)?> imageSize(Uint8List bytes) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final size = (descriptor.width, descriptor.height);
      descriptor.dispose();
      buffer.dispose();
      return size;
    } on Object {
      return null;
    }
  }
}
