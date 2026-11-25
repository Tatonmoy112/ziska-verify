/// The `error.code` values of the app API guide §1, written once
/// (production audit P-23). A test keeps this list equal to the guide's
/// table; a code not in it is decided by status (`ErrorMapper`).
abstract final class ApiErrorCodes {
  static const validationFailed = 'validation_failed';
  static const tokenExpired = 'token_expired';
  static const unauthenticated = 'unauthenticated';
  static const passwordChangeRequired = 'password_change_required';
  static const policyDenied = 'policy_denied';
  static const forbidden = 'forbidden';
  static const notFound = 'not_found';
  static const conflict = 'conflict';
  static const sessionFull = 'session_full';
  static const sessionEnded = 'session_ended';
  static const sessionNotYours = 'session_not_yours';
  static const rateLimited = 'rate_limited';
  static const appPreparing = 'app_preparing';
  static const serviceUnavailable = 'service_unavailable';
  static const internalError = 'internal_error';

  /// Every code: an answer with one of these is shown with the app's own
  /// text, except `conflict`, whose message says what conflicts.
  static const Set<String> all = {
    validationFailed,
    tokenExpired,
    unauthenticated,
    passwordChangeRequired,
    policyDenied,
    forbidden,
    notFound,
    conflict,
    sessionFull,
    sessionEnded,
    sessionNotYours,
    rateLimited,
    appPreparing,
    serviceUnavailable,
    internalError,
  };
}
