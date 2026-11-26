import 'package:flutter/foundation.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// The build flavors (final.md §17).
/// `staging` builds connect to the backend's test server.
enum AppFlavor { mock, staging, live }

/// Values fixed per build, read from `--dart-define-from-file`
/// (`config/<flavor>.json`). Nothing else is hard-coded: formats and limits
/// come from the API (final.md §11).
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.clientSlug,
    required this.officeEmail,
    required this.officePhone,
    this.postmanMockRouting = false,
    this.crashReporting,
  });

  /// Reads the values passed with `--dart-define-from-file`.
  ///
  /// Throws [StateError] when a value is missing or the base URL is not
  /// HTTPS, so a wrongly built app fails at start, never at the first call.
  factory AppConfig.fromEnvironment() => AppConfig.fromValues(
    flavorName: const String.fromEnvironment('FLAVOR'),
    baseUrl: const String.fromEnvironment('API_BASE_URL'),
    clientSlug: const String.fromEnvironment('CLIENT_SLUG'),
    officeEmail: const String.fromEnvironment('OFFICE_EMAIL'),
    officePhone: const String.fromEnvironment('OFFICE_PHONE'),
    // Read at build time: true in the mock build (config/mock.json), though
    // the analyzer sees the default.
    // ignore: avoid_redundant_argument_values
    postmanMockRouting: const bool.fromEnvironment('POSTMAN_MOCK_ROUTING'),
    firebaseProjectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    firebaseSenderId: const String.fromEnvironment('FIREBASE_SENDER_ID'),
    firebaseAndroidApiKey: const String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
    ),
    firebaseAndroidAppId: const String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
    ),
    firebaseIosApiKey: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    firebaseIosAppId: const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
  );

  /// The configuration from given values: [AppConfig.fromEnvironment]
  /// passes the build's, a test its own.
  factory AppConfig.fromValues({
    required String flavorName,
    required String baseUrl,
    required String clientSlug,
    required String officeEmail,
    required String officePhone,
    bool postmanMockRouting = false,
    String? firebaseProjectId,
    String? firebaseSenderId,
    String? firebaseAndroidApiKey,
    String? firebaseAndroidAppId,
    String? firebaseIosApiKey,
    String? firebaseIosAppId,
  }) {
    final flavor = AppFlavor.values.where((f) => f.name == flavorName);
    if (flavor.isEmpty) {
      throw StateError(
        'FLAVOR must be one of mock, staging, live. '
        'Run with --dart-define-from-file=config/<flavor>.json',
      );
    }
    if (postmanMockRouting && flavor.single != AppFlavor.mock) {
      throw StateError('POSTMAN_MOCK_ROUTING is for the mock build only.');
    }
    return AppConfig(
      flavor: flavor.single,
      baseUrl: validateBaseUrl(baseUrl),
      clientSlug: validateClientSlug(clientSlug),
      officeEmail: officeEmail,
      officePhone: officePhone,
      postmanMockRouting: postmanMockRouting,
      crashReporting: crashReportingFrom(
        flavor.single,
        projectId: firebaseProjectId ?? '',
        senderId: firebaseSenderId ?? '',
        androidApiKey: firebaseAndroidApiKey ?? '',
        androidAppId: firebaseAndroidAppId ?? '',
        iosApiKey: firebaseIosApiKey ?? '',
        iosAppId: firebaseIosAppId ?? '',
      ),
    );
  }

  final AppFlavor flavor;

  /// The API host, for example `https://api.example.com` (no trailing `/`).
  final String baseUrl;

  /// The client's short name in every path (`/v1/clients/{slug}/…`).
  final String clientSlug;

  /// The client office's contact for Request access, when no role can be
  /// asked for (final.md §13.8).
  final String officeEmail;
  final String officePhone;

  /// Mock build only: lets the Postman mock tell apart the flows it cannot
  /// by itself (`PostmanMockRouting`, docs/postman-mock-setup.md).
  final bool postmanMockRouting;

  /// The Firebase app crash reports go to; `null` (no `FIREBASE_*` value):
  /// crash reporting stays off (production audit P-10).
  final CrashReportingConfig? crashReporting;

  /// The base of every app route: `{base}/v1/clients/{slug}/`.
  String get apiRoot => '$baseUrl/v1/clients/$clientSlug/';

  /// Where this phone reports crashes, or `null`: no Firebase app for
  /// [platform], or a [debug] build (a developer's crashes are not the
  /// officials').
  CrashTarget? crashTargetFor(TargetPlatform platform, {required bool debug}) {
    final config = crashReporting;
    if (config == null || debug) return null;
    final app = switch (platform) {
      TargetPlatform.android => config.android,
      TargetPlatform.iOS => config.ios,
      _ => null,
    };
    if (app == null) return null;
    return CrashTarget(
      projectId: config.projectId,
      senderId: config.senderId,
      apiKey: app.apiKey,
      appId: app.appId,
    );
  }

  /// The `FIREBASE_*` values as a [CrashReportingConfig]: `null` when all
  /// are empty. Throws [StateError] for a half-filled set, naming the
  /// missing keys (never a value), or for any value in the mock build,
  /// which never sends anything off the phone.
  static CrashReportingConfig? crashReportingFrom(
    AppFlavor flavor, {
    required String projectId,
    required String senderId,
    required String androidApiKey,
    required String androidAppId,
    required String iosApiKey,
    required String iosAppId,
  }) {
    final values = {
      'FIREBASE_PROJECT_ID': projectId.trim(),
      'FIREBASE_SENDER_ID': senderId.trim(),
      'FIREBASE_ANDROID_API_KEY': androidApiKey.trim(),
      'FIREBASE_ANDROID_APP_ID': androidAppId.trim(),
      'FIREBASE_IOS_API_KEY': iosApiKey.trim(),
      'FIREBASE_IOS_APP_ID': iosAppId.trim(),
    };
    if (values.values.every((v) => v.isEmpty)) return null;
    if (flavor == AppFlavor.mock) {
      throw StateError(
        'FIREBASE_* values are for the staging and live builds only.',
      );
    }
    bool given(String key) => values[key]!.isNotEmpty;
    final android =
        given('FIREBASE_ANDROID_API_KEY') || given('FIREBASE_ANDROID_APP_ID');
    final ios = given('FIREBASE_IOS_API_KEY') || given('FIREBASE_IOS_APP_ID');
    final missing = [
      for (final key in ['FIREBASE_PROJECT_ID', 'FIREBASE_SENDER_ID'])
        if (!given(key)) key,
      if (android)
        for (final key in [
          'FIREBASE_ANDROID_API_KEY',
          'FIREBASE_ANDROID_APP_ID',
        ])
          if (!given(key)) key,
      if (ios)
        for (final key in ['FIREBASE_IOS_API_KEY', 'FIREBASE_IOS_APP_ID'])
          if (!given(key)) key,
      if (!android && !ios) ...[
        'FIREBASE_ANDROID_APP_ID',
        'FIREBASE_IOS_APP_ID',
      ],
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Crash reporting needs every Firebase value of its app; missing: '
        '${missing.join(', ')}.',
      );
    }
    return CrashReportingConfig(
      projectId: values['FIREBASE_PROJECT_ID']!,
      senderId: values['FIREBASE_SENDER_ID']!,
      android: android
          ? (
              apiKey: values['FIREBASE_ANDROID_API_KEY']!,
              appId: values['FIREBASE_ANDROID_APP_ID']!,
            )
          : null,
      ios: ios
          ? (
              apiKey: values['FIREBASE_IOS_API_KEY']!,
              appId: values['FIREBASE_IOS_APP_ID']!,
            )
          : null,
    );
  }

  /// Returns the host part of [url] (`https://host[:port]`, lower case, no
  /// trailing `/`); throws unless it is an HTTPS host alone (final.md
  /// §12). A whole API address (`…/v1/clients/<slug>`) is refused
  /// with the host to use, as every request would otherwise miss.
  static String validateBaseUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw StateError('API_BASE_URL must be an https:// address.');
    }
    final host = 'https://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    if (uri.path.replaceAll('/', '').isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw StateError(
        'API_BASE_URL is the host alone, for example $host; the client '
        'name goes in CLIENT_SLUG.',
      );
    }
    if (_isPlaceholder(uri.host)) {
      throw StateError('API_BASE_URL is still a placeholder.');
    }
    return host;
  }

  /// Returns [slug] without surrounding spaces; throws unless it is lower
  /// case letters, digits and `-`, starting with a letter or a digit (the
  /// server answers 404 for any other client name).
  static String validateClientSlug(String slug) {
    final value = slug.trim();
    if (!_slug.hasMatch(value)) {
      throw StateError(
        'CLIENT_SLUG must be lower case letters, digits and "-": '
        '"$value" is not.',
      );
    }
    if (_isPlaceholder(value)) {
      throw StateError('CLIENT_SLUG is still a placeholder.');
    }
    return value;
  }

  static final _slug = RegExp(r'^[a-z0-9][a-z0-9-]*$');

  static bool _isPlaceholder(String value) => value.contains('replace-with');
}
