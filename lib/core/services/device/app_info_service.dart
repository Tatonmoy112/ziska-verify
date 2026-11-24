/// The app's version and build number (final.md §5).
abstract interface class AppInfoService {
  Future<({String version, String build})> versionInfo();
}
