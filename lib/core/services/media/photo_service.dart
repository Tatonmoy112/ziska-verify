import 'dart:typed_data';

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

  /// At most 1 MB (app API guide §6.2).
  static const int maxBytes = 1024 * 1024;

  /// The file types the server takes (guide §6.2).
  static const types = {'image/jpeg', 'image/png'};

  final Uint8List bytes;
  String get contentType => 'image/jpeg';
}

/// Picks and prepares a report photo (final.md §5, §13.5):
/// 2048 px on the longer side, JPEG quality 85, HEIC converted, orientation
/// applied, all metadata (location, time, phone model) removed, at most
/// 1 MB.
abstract interface class PhotoService {
  /// `null` when the official cancels. Throws [PhotoException].
  Future<PreparedPhoto?> pick(PhotoSource source);
}
