import 'package:permission_handler/permission_handler.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';

class PermissionHandlerService implements PermissionService {
  const PermissionHandlerService();

  @override
  Future<bool> openSettings() => openAppSettings();
}
