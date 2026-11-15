import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Why a photo could not be prepared.
enum PhotoProblem {
  /// Still over 1 MB at the lowest quality used.
  tooLarge,

  /// The file could not be read or converted.
  unreadable,
}

class PhotoException implements Exception {
  const PhotoException(this.problem);
  final PhotoProblem problem;

  @override
  String toString() => 'PhotoException($problem)';
}

/// A photo ready to upload: JPEG bytes with no metadata.
class PreparedPhoto {
  const PreparedPhoto(this.bytes);

  final Uint8List bytes;
  String get contentType => 'image/jpeg';
}

/// Picks and prepares a report photo (final.md Sections 5.6, 13.5.2):
/// 2048 px on the longer side, JPEG quality 85, HEIC converted, orientation
/// applied, all metadata (location, time, phone model) removed, at most
/// 1 MB.
abstract interface class PhotoService {
  /// `null` when the official cancels. Throws [PhotoException].
  Future<PreparedPhoto?> pick(PhotoSource source);
}

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
  static Future<Uint8List> prepare(Uint8List original) async {
    final (width, height) = await _targetSize(original);
    return fitWithinLimit(
      (quality) => FlutterImageCompress.compressWithList(
        original,
        minWidth: width,
        minHeight: height,
        quality: quality,
        // The defaults apply the orientation to the pixels
        // (`autoCorrectionAngle`), write JPEG, and keep no EXIF
        // (`keepExif: false`).
      ),
    );
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

  /// The size that brings the longer side to [maxSide], never enlarging.
  static Future<(int, int)> _targetSize(Uint8List bytes) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final w = descriptor.width;
      final h = descriptor.height;
      descriptor.dispose();
      buffer.dispose();
      final scale = min(1, maxSide / max(w, h));
      return ((w * scale).round(), (h * scale).round());
    } on Object {
      // A format the engine cannot read (HEIC on some phones): the
      // compressor still converts it; both sides are capped.
      return (maxSide, maxSide);
    }
  }
}
