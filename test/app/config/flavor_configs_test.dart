import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/config/app_config.dart';

/// TC-SEC-037 … -039 (docs/test-cases/11-security.md): the flavors' real
/// config files turn Crashlytics on for the staging Android app only, and
/// Firebase stays crash reporting alone (production audit P-10).
void main() {
  Map<String, Object?> read(String flavor) =>
      jsonDecode(File('config/$flavor.json').readAsStringSync())
          as Map<String, Object?>;

  String value(Map<String, Object?> c, String key) => '${c[key] ?? ''}';

  AppConfig build(String flavor) {
    final c = read(flavor);
    return AppConfig.fromValues(
      flavorName: value(c, 'FLAVOR'),
      baseUrl: value(c, 'API_BASE_URL'),
      clientSlug: value(c, 'CLIENT_SLUG'),
      officeEmail: value(c, 'OFFICE_EMAIL'),
      officePhone: value(c, 'OFFICE_PHONE'),
      postmanMockRouting: c['POSTMAN_MOCK_ROUTING'] == true,
      firebaseProjectId: value(c, 'FIREBASE_PROJECT_ID'),
      firebaseSenderId: value(c, 'FIREBASE_SENDER_ID'),
      firebaseAndroidApiKey: value(c, 'FIREBASE_ANDROID_API_KEY'),
      firebaseAndroidAppId: value(c, 'FIREBASE_ANDROID_APP_ID'),
      firebaseIosApiKey: value(c, 'FIREBASE_IOS_API_KEY'),
      firebaseIosAppId: value(c, 'FIREBASE_IOS_APP_ID'),
    );
  }

  const firebaseKeys = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_SENDER_ID',
    'FIREBASE_ANDROID_API_KEY',
    'FIREBASE_ANDROID_APP_ID',
    'FIREBASE_IOS_API_KEY',
    'FIREBASE_IOS_APP_ID',
  ];

  group('TC-SEC-037 normal: staging reports Android crashes', () {
    test('a release build of the staging Android app has its target', () {
      final target = build(
        'staging',
      ).crashTargetFor(TargetPlatform.android, debug: false);
      expect(target, isNotNull);
      expect(target!.projectId, matches(RegExp(r'^[a-z][a-z0-9-]{4,}$')));
      expect(target.senderId, matches(RegExp(r'^\d{12}$')));
      expect(
        target.appId,
        matches(RegExp('^1:${target.senderId}:android:[0-9a-f]+\$')),
        reason: "the app ID belongs to the project's number",
      );
      expect(target.apiKey, matches(RegExp(r'^AIza[0-9A-Za-z_-]{35}$')));
    });

    test('no iOS app yet, and none in a debug build', () {
      final staging = build('staging');
      expect(staging.crashTargetFor(TargetPlatform.iOS, debug: false), isNull);
      expect(
        staging.crashTargetFor(TargetPlatform.android, debug: true),
        isNull,
      );
    });
  });

  group('TC-SEC-038 edge: mock and live report nothing', () {
    test('mock: no Firebase value, no target', () {
      expect(read('mock').keys.where(firebaseKeys.contains), isEmpty);
      expect(build('mock').crashReporting, isNull);
    });

    test('live: no Firebase value until its own production project', () {
      final live = read('live');
      expect(live.keys.where(firebaseKeys.contains), isEmpty);
      expect(
        AppConfig.crashReportingFrom(
          AppFlavor.live,
          projectId: value(live, 'FIREBASE_PROJECT_ID'),
          senderId: value(live, 'FIREBASE_SENDER_ID'),
          androidApiKey: value(live, 'FIREBASE_ANDROID_API_KEY'),
          androidAppId: value(live, 'FIREBASE_ANDROID_APP_ID'),
          iosApiKey: value(live, 'FIREBASE_IOS_API_KEY'),
          iosAppId: value(live, 'FIREBASE_IOS_APP_ID'),
        ),
        isNull,
      );
    });
  });

  group('TC-SEC-039 worst: Firebase is crash reporting only', () {
    test('no Firebase package but core and Crashlytics', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final firebase = RegExp(
        r'^  (firebase_\w+):',
        multiLine: true,
      ).allMatches(pubspec).map((m) => m.group(1)).toSet();
      expect(firebase, {'firebase_core', 'firebase_crashlytics'});
      for (final banned in [
        'firebase_analytics',
        'firebase_messaging',
        'firebase_performance',
        'firebase_in_app_messaging',
      ]) {
        expect(pubspec, isNot(contains(banned)), reason: banned);
      }
    });

    test('no Google Services plugin or file in the Android build', () {
      expect(File('android/app/google-services.json').existsSync(), isFalse);
      for (final gradle in [
        'android/settings.gradle.kts',
        'android/app/build.gradle.kts',
      ]) {
        expect(
          File(gradle).readAsStringSync(),
          isNot(contains('com.google.gms.google-services')),
          reason: gradle,
        );
      }
    });

    test('the file downloaded from Firebase is never committed', () {
      final ignore = File('.gitignore').readAsStringSync();
      expect(ignore, contains('/firebase/'));
    });
  });
}
