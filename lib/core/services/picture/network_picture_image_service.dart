import 'package:flutter/painting.dart';
import 'package:ziska_verify/core/services/picture/picture_image_service.dart';

/// Loads a product picture from the network, kept in Flutter's memory
/// image cache only (final.md §12).
class NetworkPictureImageService implements PictureImageService {
  const NetworkPictureImageService();

  @override
  ImageProvider of(Uri address) => NetworkImage(address.toString());
}
