import 'package:package_info_plus/package_info_plus.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';

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
