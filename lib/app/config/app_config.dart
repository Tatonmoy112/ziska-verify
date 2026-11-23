/// The build flavors (final.md Section 17).
/// `staging` builds connect to the backend's test server.
enum AppFlavor { mock, staging, live }

/// Values fixed per build, read from `--dart-define-from-file`
/// (`config/<flavor>.json`). Nothing else is hard-coded: formats and limits
/// come from the API (final.md Section 11.1).
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.clientSlug,
    required this.officeEmail,
    required this.officePhone,
    this.postmanMockRouting = false,
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
  );

  /// [AppConfig.fromEnvironment] on given values (for tests).
  factory AppConfig.fromValues({
    required String flavorName,
    required String baseUrl,
    required String clientSlug,
    required String officeEmail,
    required String officePhone,
    bool postmanMockRouting = false,
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
    );
  }

  final AppFlavor flavor;

  /// The API host, for example `https://api.example.com` (no trailing `/`).
  final String baseUrl;

  /// The client's short name in every path (`/v1/clients/{slug}/…`).
  final String clientSlug;

  /// The client office's contact for Sign up (final.md Section 13.9).
  final String officeEmail;
  final String officePhone;

  /// Mock build only: lets the Postman mock tell apart the flows it cannot
  /// by itself (`PostmanMockRouting`, docs/postman-mock-setup.md).
  final bool postmanMockRouting;

  /// The base of every app route: `{base}/v1/clients/{slug}/`.
  String get apiRoot => '$baseUrl/v1/clients/$clientSlug/';

  /// Returns the host part of [url] (`https://host[:port]`, lower case, no
  /// trailing `/`); throws unless it is an HTTPS host alone (final.md
  /// Section 12.1). A whole API address (`…/v1/clients/<slug>`) is refused
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
