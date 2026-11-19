/// Route paths (final.md Section 9.2). Used only inside `app/router/`;
/// features navigate by `RouteNames`.
abstract final class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const verifyCode = '/login/verify-code';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/forgot-password/reset';
  static const requestAccess = '/request-access';
  static const changePassword = '/change-password';
  static const home = '/home';
  static const history = '/history';
  static const profile = '/profile';

  // Full-screen flows above the bottom bar (final.md Section 9.2).
  static const lookupResult = '/home/result';
  static const scannerMode = '/home/scanner-mode';
  static const serialStack = '/home/serial-stack';
  static const sessionChecks = '/history/sessions/:id';
  static const myReports = '/home/reports';
  static const reportIncident = '/home/reports/new';

  /// Open without login (final.md Section 9.4).
  static const Set<String> preLogin = {
    login,
    forgotPassword,
    resetPassword,
    requestAccess,
  };
}
