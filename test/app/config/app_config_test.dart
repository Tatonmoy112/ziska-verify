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

  // The test server (2026-11-22): its address is given as the whole API
  // root, https://testapp.protecb.com/v1/clients/ziska-test; the build
  // takes the host and the client name apart.
  group('Step 1: the address and the client name', () {
    test('the test server', () {
      final config = AppConfig.fromValues(
        flavorName: 'staging',
        baseUrl: 'https://testapp.protecb.com',
        clientSlug: 'ziska-test',
        officeEmail: '',
        officePhone: '',
      );
      expect(
        config.apiRoot,
        'https://testapp.protecb.com/v1/clients/ziska-test/',
      );
    });

    test('the whole API address as the base is refused, naming the host', () {
      expect(
        () => AppConfig.validateBaseUrl(
          'https://testapp.protecb.com/v1/clients/ziska-test',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('https://testapp.protecb.com'),
              contains('CLIENT_SLUG'),
            ),
          ),
        ),
      );
    });

    for (final bad in [
      'https://api.example.com/api',
      'https://api.example.com?x=1',
      'https://api.example.com#top',
      'https://user:secret@api.example.com',
      'https://replace-with-test-server-address.example',
      'https://',
      'testapp.protecb.com',
    ]) {
      test('refuses $bad', () {
        expect(() => AppConfig.validateBaseUrl(bad), throwsStateError);
      });
    }

    for (final (given, kept) in [
      ('  https://api.example.com/  ', 'https://api.example.com'),
      ('https://api.example.com//', 'https://api.example.com'),
      ('HTTPS://API.Example.com', 'https://api.example.com'),
      ('https://api.example.com:8443', 'https://api.example.com:8443'),
    ]) {
      test('reads "$given" as $kept', () {
        expect(AppConfig.validateBaseUrl(given), kept);
      });
    }

    for (final slug in ['ziska-test', 'ziska', 'demo-pharma', 'a1']) {
      test('the client name $slug is accepted', () {
        expect(AppConfig.validateClientSlug(slug), slug);
      });
    }

    test('the client name is read without surrounding spaces', () {
      expect(AppConfig.validateClientSlug(' ziska-test '), 'ziska-test');
    });

    // The server answers 404 for a client name in capitals (backend review
    // of 2026-11-18): refused at start rather than failing every request.
    for (final slug in [
      'Ziska-Test',
      'ziska test',
      'ziska/test',
      '-ziska',
      'ziska_test',
      '',
      'replace-with-client-slug',
    ]) {
      test('the client name "$slug" is refused', () {
        expect(() => AppConfig.validateClientSlug(slug), throwsStateError);
      });
    }

    test('a build with a bad client name fails at start', () {
      expect(
        () => AppConfig.fromValues(
          flavorName: 'staging',
          baseUrl: 'https://testapp.protecb.com',
          clientSlug: 'Ziska-Test',
          officeEmail: '',
          officePhone: '',
        ),
        throwsStateError,
      );
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
