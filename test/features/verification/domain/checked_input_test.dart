import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/picture/network_picture_image_service.dart';
import 'package:ziska_verify/core/services/picture/picture_image_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// What the result screen shows of the input, and which picture addresses
/// may be loaded (final.md §12, §13.1; TC-LOOK-095, -112).
void main() {
  test('submission ways exclude hidden codes', () {
    expect(LookupWay.values.map((w) => w.wire), ['serial', 'qr']);
  });
  // A lookup shows its value as sent: TC-ARCH-089.

  group('pictureAddress', () {
    test('an https address with a host is accepted', () {
      expect(
        pictureAddress('https://pictures.example.com/53/9f2c.jpg'),
        Uri.parse('https://pictures.example.com/53/9f2c.jpg'),
      );
      expect(
        pictureAddress('  https://pictures.example.com/1.png '),
        Uri.parse('https://pictures.example.com/1.png'),
      );
    });

    for (final url in [
      null,
      '',
      'http://pictures.example.com/1.jpg',
      'ftp://pictures.example.com/1.jpg',
      'https:///1.jpg',
      '/53/9f2c.jpg',
      'not an address',
    ]) {
      test('${url ?? 'null'} is no picture', () {
        expect(pictureAddress(url), isNull);
      });
    }
  });

  test('the real service loads with no extra headers (no access pass)', () {
    final image = const NetworkPictureImageService().of(
      Uri.parse('https://pictures.example.com/53/9f2c.jpg'),
    );
    expect(image, isA<NetworkImage>());
    final network = image as NetworkImage;
    expect(network.url, 'https://pictures.example.com/53/9f2c.jpg');
    expect(network.headers, isNull);
  });
}
