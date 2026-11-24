import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// TC-SEC-029 … -031 (docs/test-cases/11-security.md): crash reporting
/// (Firebase Crashlytics) is on only for a staging or live build given a
/// complete Firebase app in `config/<flavor>.json`, and only in a release
/// build (production audit P-10).
void main() {
  const project = 'ziska-track-trace';
  const sender = '123456789012';
  const androidKey = 'AIzaSy-android-key-for-tests';
  const androidApp = '1:123456789012:android:abc123';
  const iosKey = 'AIzaSy-ios-key-for-tests';
  const iosApp = '1:123456789012:ios:def456';

  AppConfig config({
    String flavor = 'staging',
    String projectId = project,
    String senderId = sender,
    String androidApiKey = androidKey,
    String androidAppId = androidApp,
    String iosApiKey = iosKey,
    String iosAppId = iosApp,
  }) => AppConfig.fromValues(
    flavorName: flavor,
    baseUrl: 'https://testapp.example.com',
    clientSlug: 'ziska-test',
    officeEmail: '',
    officePhone: '',
    firebaseProjectId: projectId,
    firebaseSenderId: senderId,
    firebaseAndroidApiKey: androidApiKey,
    firebaseAndroidAppId: androidAppId,
    firebaseIosApiKey: iosApiKey,
    firebaseIosAppId: iosAppId,
  );

  AppConfig none({String flavor = 'staging'}) => config(
    flavor: flavor,
    projectId: '',
    senderId: '',
    androidApiKey: '',
    androidAppId: '',
    iosApiKey: '',
    iosAppId: '',
  );

  group('TC-SEC-029 normal: a complete Firebase app turns it on', () {
    for (final flavor in ['staging', 'live']) {
      test('$flavor: each phone gets its own Firebase app', () {
        final c = config(flavor: flavor);
        final android = c.crashTargetFor(TargetPlatform.android, debug: false);
        expect(android, isNotNull);
        expect(android!.projectId, project);
        expect(android.senderId, sender);
        expect(android.apiKey, androidKey);
        expect(android.appId, androidApp);
        final ios = c.crashTargetFor(TargetPlatform.iOS, debug: false);
        expect(ios!.apiKey, iosKey);
        expect(ios.appId, iosApp);
        expect(ios.projectId, project);
      });
    }
  });

  group('TC-SEC-030 edge: off unless every condition holds', () {
    for (final flavor in ['mock', 'staging', 'live']) {
      test('$flavor without any Firebase value: off', () {
        final c = none(flavor: flavor);
        expect(c.crashReporting, isNull);
        expect(c.crashTargetFor(TargetPlatform.android, debug: false), isNull);
        expect(c.crashTargetFor(TargetPlatform.iOS, debug: false), isNull);
      });
    }

    test('a debug build: off, even when configured', () {
      final c = config();
      expect(c.crashTargetFor(TargetPlatform.android, debug: true), isNull);
      expect(c.crashTargetFor(TargetPlatform.iOS, debug: true), isNull);
    });

    test('Android only: on for Android, off for iOS', () {
      final c = config(iosApiKey: '', iosAppId: '');
      expect(c.crashTargetFor(TargetPlatform.android, debug: false), isNotNull);
      expect(c.crashTargetFor(TargetPlatform.iOS, debug: false), isNull);
    });

    test('a platform the app is not built for: off', () {
      final c = config();
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.fuchsia,
      ]) {
        expect(c.crashTargetFor(platform, debug: false), isNull);
      }
    });

    test('values with spaces around them are trimmed; spaces alone are '
        'empty', () {
      final c = config(projectId: '  $project ', androidAppId: ' $androidApp');
      final target = c.crashTargetFor(TargetPlatform.android, debug: false);
      expect(target!.projectId, project);
      expect(target.appId, androidApp);
      expect(
        none().crashReporting,
        isNull,
        reason: 'empty strings are no configuration',
      );
      expect(
        config(
          projectId: '   ',
          senderId: ' ',
          androidApiKey: '',
          androidAppId: '',
          iosApiKey: '',
          iosAppId: '',
        ).crashReporting,
        isNull,
      );
    });
  });

  group('TC-SEC-031 worst: a half-filled or misplaced set stops the build '
      'at start', () {
    Matcher refused(List<String> keys) => throwsA(
      isA<StateError>().having((e) => e.message, 'message', (String m) {
        // Names every missing key, and never a value given.
        for (final k in keys) {
          if (!m.contains(k)) return false;
        }
        for (final v in [project, sender, androidKey, androidApp, iosKey]) {
          if (m.contains(v)) return false;
        }
        return true;
      }),
    );

    test('a project without its sender', () {
      expect(() => config(senderId: ''), refused(['FIREBASE_SENDER_ID']));
    });

    test('an Android key without its app ID, and the reverse', () {
      expect(
        () => config(androidAppId: ''),
        refused(['FIREBASE_ANDROID_APP_ID']),
      );
      expect(
        () => config(androidApiKey: ''),
        refused(['FIREBASE_ANDROID_API_KEY']),
      );
    });

    test('a platform app without the project', () {
      expect(
        () => config(projectId: '', senderId: '', iosApiKey: '', iosAppId: ''),
        refused(['FIREBASE_PROJECT_ID', 'FIREBASE_SENDER_ID']),
      );
    });

    test('a project with no platform app at all', () {
      expect(
        () => config(
          androidApiKey: '',
          androidAppId: '',
          iosApiKey: '',
          iosAppId: '',
        ),
        refused(['FIREBASE_ANDROID_APP_ID', 'FIREBASE_IOS_APP_ID']),
      );
    });

    test('any Firebase value in the mock build', () {
      expect(
        () => config(flavor: 'mock'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('staging and live builds only'),
          ),
        ),
      );
    });
  });

  test('the config type holds no plugin type', () {
    // CrashReportingConfig lives in the core interface file (rule R16).
    const c = CrashReportingConfig(
      projectId: project,
      senderId: sender,
      android: (apiKey: androidKey, appId: androidApp),
    );
    expect(c.ios, isNull);
  });
}
