import 'package:flutter/painting.dart';

/// The product picture's address when it may be loaded: an `https://`
/// address with a host. Anything else (`null`, `http://`, a broken
/// address) is treated as no picture and never requested (final.md
/// §12, §13.1).
Uri? pictureAddress(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  return uri;
}

/// Loads product pictures (final.md §13.1). Never through the API
/// client, so the picture host never receives the access pass; kept only in
/// Flutter's memory image cache, never on the phone's storage (final.md
/// §12, backend D21).
abstract interface class PictureImages {
  /// The picture at [address] (an address [pictureAddress] accepted).
  ImageProvider of(Uri address);
}

class NetworkPictureImages implements PictureImages {
  const NetworkPictureImages();

  @override
  ImageProvider of(Uri address) => NetworkImage(address.toString());
}
