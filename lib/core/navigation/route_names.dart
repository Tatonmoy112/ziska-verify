/// Route names used by features to navigate (final.md §9). Paths
/// live in `app/router/` only.
abstract final class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const verifyCode = 'verifyCode';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const requestAccess = 'requestAccess';
  static const changePassword = 'changePassword';
  static const home = 'home';
  static const history = 'history';
  static const profile = 'profile';
  static const lookupResult = 'lookupResult';
  static const scannerMode = 'scannerMode';
  static const serialStack = 'serialStack';
  static const sessionChecks = 'sessionChecks';
  static const myReports = 'myReports';
  static const reportIncident = 'reportIncident';
}
