import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// What the result screen shows of the input, and which picture addresses
/// may be loaded (final.md Sections 12.1, 13.1.4; TC-LOOK-095, -112).
void main() {
  test('submission ways exclude hidden codes', () {
    expect(LookupWay.values.map((w) => w.wire), ['serial', 'qr']);
  });
  group('CheckedInput.of', () {
    final at = DateTime.utc(2026, 11, 15, 4);

    test('a serial and a QR value are shown as sent', () {
      expect(CheckedInput.of(LookupWay.serial, '1000001', at).shown, '1000001');
      expect(
        CheckedInput.of(LookupWay.qr, 'Q8F2KD91XA7M', at).shown,
        'Q8F2KD91XA7M',
      );
    });
  });

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
    final image = const NetworkPictureImages().of(
      Uri.parse('https://pictures.example.com/53/9f2c.jpg'),
    );
    expect(image, isA<NetworkImage>());
    final network = image as NetworkImage;
    expect(network.url, 'https://pictures.example.com/53/9f2c.jpg');
    expect(network.headers, isNull);
  });
}
