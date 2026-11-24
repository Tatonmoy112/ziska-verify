/// Camera and photo permissions (final.md Section 5.6). The scanner asks
/// for the camera itself; this service opens the settings after a refusal.
abstract interface class PermissionService {
  Future<bool> openSettings();
}
