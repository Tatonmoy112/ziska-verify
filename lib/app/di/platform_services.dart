import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/storage/preferences_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// The services that reach the phone's plugins. Each left out is the real
/// one; a test hands in its fakes here, never by replacing a registration
/// (production audit P-35).
class PlatformServices {
  const PlatformServices({
    this.storage,
    this.launcher,
    this.appInfo,
    this.connectivity,
    this.preferences,
    this.scanner,
    this.permission,
    this.photos,
    this.pictures,
  });

  final SecureStorageService? storage;
  final LauncherService? launcher;
  final AppInfoService? appInfo;
  final ConnectivityService? connectivity;
  final PreferencesService? preferences;
  final ScannerService? scanner;
  final PermissionService? permission;
  final PhotoService? photos;
  final PictureImages? pictures;
}
