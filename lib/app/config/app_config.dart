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
  });

  /// Reads the values passed with `--dart-define-from-file`.
  ///
  /// Throws [StateError] when a value is missing or the base URL is not
  /// HTTPS, so a wrongly built app fails at start, never at the first call.
  factory AppConfig.fromEnvironment() {
    const flavorName = String.fromEnvironment('FLAVOR');
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    const clientSlug = String.fromEnvironment('CLIENT_SLUG');
    const officeEmail = String.fromEnvironment('OFFICE_EMAIL');
    const officePhone = String.fromEnvironment('OFFICE_PHONE');

    final flavor = AppFlavor.values.where((f) => f.name == flavorName);
    if (flavor.isEmpty) {
      throw StateError(
        'FLAVOR must be one of mock, staging, live. '
        'Run with --dart-define-from-file=config/<flavor>.json',
      );
    }
    if (clientSlug.isEmpty) {
      throw StateError('CLIENT_SLUG is missing.');
    }
    return AppConfig(
      flavor: flavor.single,
      baseUrl: validateBaseUrl(baseUrl),
      clientSlug: clientSlug,
      officeEmail: officeEmail,
      officePhone: officePhone,
    );
  }

  final AppFlavor flavor;

  /// The API host, for example `https://api.example.com` (no trailing `/`).
  final String baseUrl;

  /// The client's short name in every path (`/v1/clients/{slug}/…`).
  final String clientSlug;

  /// The client office's contact for Request access (final.md Section 13.9).
  final String officeEmail;
  final String officePhone;

  /// The base of every app route: `{base}/v1/clients/{slug}/`.
  String get apiRoot => '$baseUrl/v1/clients/$clientSlug/';

  /// Returns [url] without a trailing `/`; throws unless it is HTTPS
  /// (final.md Section 12.1).
  static String validateBaseUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw StateError('API_BASE_URL must be an https:// address.');
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
