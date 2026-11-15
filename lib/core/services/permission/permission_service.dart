import 'package:permission_handler/permission_handler.dart';

/// Camera and photo permissions (final.md Section 5.6). The scanner asks
/// for the camera itself; this service opens the settings after a refusal.
abstract interface class PermissionService {
  Future<bool> openSettings();
}

class PermissionHandlerService implements PermissionService {
  const PermissionHandlerService();

  @override
  Future<bool> openSettings() => openAppSettings();
}
