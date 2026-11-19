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

  group('DEMO_PASSWORD_LATER (TC-AUTH-096)', () {
    AppConfig build(String flavor, {bool demo = false}) => AppConfig.fromValues(
      flavorName: flavor,
      baseUrl: 'https://api.example.com',
      clientSlug: 'demo-pharma',
      officeEmail: '',
      officePhone: '',
      demoPasswordLater: demo,
    );

    test('off unless set', () {
      expect(build('mock').demoPasswordLater, isFalse);
      expect(build('live').demoPasswordLater, isFalse);
    });

    test('on in the mock build', () {
      expect(build('mock', demo: true).demoPasswordLater, isTrue);
    });

    test('a staging or live build with it fails at start', () {
      expect(() => build('staging', demo: true), throwsStateError);
      expect(() => build('live', demo: true), throwsStateError);
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
