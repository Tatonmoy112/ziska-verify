/// The app's version and build number (final.md Section 5.6).
abstract interface class AppInfoService {
  Future<({String version, String build})> versionInfo();
}
