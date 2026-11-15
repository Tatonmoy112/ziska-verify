import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/config/app_config.dart';

void main() {
  group('AppConfig.validateBaseUrl', () {
    test('accepts https and removes a trailing slash', () {
      expect(
        AppConfig.validateBaseUrl('https://api.example.com/'),
        'https://api.example.com',
      );
    });

    test('refuses http', () {
      expect(
        () => AppConfig.validateBaseUrl('http://api.example.com'),
        throwsStateError,
      );
    });

    test('refuses an empty value', () {
      expect(() => AppConfig.validateBaseUrl(''), throwsStateError);
    });
  });

  test('apiRoot is {base}/v1/clients/{slug}/', () {
    const config = AppConfig(
      flavor: AppFlavor.staging,
      baseUrl: 'https://api.example.com',
      clientSlug: 'demo-pharma',
      officeEmail: '',
      officePhone: '',
    );
    expect(config.apiRoot, 'https://api.example.com/v1/clients/demo-pharma/');
  });
}
