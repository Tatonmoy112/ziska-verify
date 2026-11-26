/// Route paths (final.md §9). Used only by `app/router/` and the tabs of
/// `app/shell/`; features navigate by `RouteNames`.
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

  // Full-screen flows above the bottom bar (final.md §9).
  static const lookupResult = '/home/result';
  static const scannerMode = '/home/scanner-mode';
  static const serialStack = '/home/serial-stack';

  /// The prefix of one session's checks; the guard checks it for every
  /// session ID.
  static const sessions = '/history/sessions';
  static const sessionChecks = '$sessions/:id';
  static const myReports = '/home/reports';
  static const reportIncident = '/home/reports/new';

  /// Open without login (final.md §9).
  static const Set<String> preLogin = {
    login,
    forgotPassword,
    resetPassword,
    requestAccess,
  };
}
