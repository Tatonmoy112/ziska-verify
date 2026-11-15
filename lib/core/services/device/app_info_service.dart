import 'package:package_info_plus/package_info_plus.dart';

/// The app's version and build number (final.md Section 5.6).
abstract interface class AppInfoService {
  Future<({String version, String build})> versionInfo();
}

class PackageInfoAppInfoService implements AppInfoService {
  PackageInfoAppInfoService();

  ({String version, String build})? _cached;

  @override
  Future<({String version, String build})> versionInfo() async {
    final cached = _cached;
    if (cached != null) return cached;
    final info = await PackageInfo.fromPlatform();
    return _cached = (version: info.version, build: info.buildNumber);
  }
}
