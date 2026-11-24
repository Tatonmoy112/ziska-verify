import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

/// The redirect decision of final.md Section 9.4, as a pure function.
class RouteGuard {
  const RouteGuard({this.permissionByPath = const {}});

  /// The permission each logged-in path needs. A path whose permission the
  /// profile lacks redirects to Home. Paths not listed need none.
  final Map<String, bool Function(Set<Permission> permissions)>
  permissionByPath;

  /// Returns where to go instead of [location], or `null` to stay.
  String? redirect({
    required SessionState? session,
    required bool profileLoaded,
    required Set<Permission> permissions,
    required String location,
  }) {
    final path = Uri.parse(location).path;
    switch (session) {
      case null:
        return _to(RoutePaths.splash, path);
      case SessionUnauthenticated():
        return RoutePaths.preLogin.contains(path)
            ? null
            : _to(RoutePaths.login, path);
      case SessionAwaitingCode():
        // "Back to login" cancels the code first (Section 6.7).
        return _to(RoutePaths.verifyCode, path);
      case SessionPasswordChangeRequired():
        return _to(RoutePaths.changePassword, path);
      case SessionAuthenticated():
        if (!profileLoaded) return _to(RoutePaths.splash, path);
        if (path == RoutePaths.splash ||
            RoutePaths.preLogin.contains(path) ||
            path == RoutePaths.verifyCode) {
          return RoutePaths.home;
        }
        final allowed =
            permissionByPath[path] ??
            (path.startsWith('/history/sessions/')
                ? permissionByPath['/history/sessions']
                : null);
        if (allowed != null && !allowed(permissions)) return RoutePaths.home;
        return null;
    }
  }

  static String? _to(String target, String path) =>
      target == path ? null : target;
}
