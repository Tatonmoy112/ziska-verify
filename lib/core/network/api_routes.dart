enum ApiMethod { get, post }

/// One route of the app API, relative to `{base}/v1/clients/{slug}/`
/// (final.md §15). Made only in [ApiRoutes] (production audit P-17).
class ApiRoute {
  const ApiRoute(this.method, this.template, [String? path]) : _path = path;

  final ApiMethod method;

  /// The path as the contract writes it, with `{id}` for a path variable.
  final String template;

  final String? _path;

  /// The path to send, with any ID encoded.
  String get path => _path ?? template;

  @override
  String toString() => '${method.name.toUpperCase()} $template';
}

/// Every route the app calls, and no other: the backend's 23 (the Postman
/// collection; app API guide §3 … §7). A test compares the two.
abstract final class ApiRoutes {
  // Logging in and the session (guide §3).
  static const login = ApiRoute(ApiMethod.post, 'auth/login');
  static const verifyPhone = ApiRoute(ApiMethod.post, 'auth/verify-phone');
  static const resendCode = ApiRoute(ApiMethod.post, 'auth/resend-code');
  static const refresh = ApiRoute(ApiMethod.post, 'auth/refresh');
  static const logout = ApiRoute(ApiMethod.post, 'auth/logout');
  static const me = ApiRoute(ApiMethod.get, 'me');
  static const changePassword = ApiRoute(ApiMethod.post, 'me/password');
  static const forgotPassword = ApiRoute(
    ApiMethod.post,
    'auth/password/forgot',
  );
  static const resetPassword = ApiRoute(ApiMethod.post, 'auth/password/reset');

  // Request access, without a pass (guide §3.9).
  static const requestableRoles = ApiRoute(ApiMethod.get, 'roles/requestable');
  static const accessCode = ApiRoute(ApiMethod.post, 'auth/access/code');
  static const accessRequest = ApiRoute(ApiMethod.post, 'auth/access');

  // Looking items up (guide §4).
  static const formats = ApiRoute(ApiMethod.get, 'formats');
  static const lookups = ApiRoute(ApiMethod.post, 'lookups');
  static const serials = ApiRoute(ApiMethod.post, 'lookups/serials');
  static const sessions = ApiRoute(ApiMethod.get, 'lookups/sessions');

  /// One session (guide §4.5).
  static ApiRoute session(String id) => ApiRoute(
    ApiMethod.get,
    'lookups/sessions/{id}',
    'lookups/sessions/${_id(id)}',
  );

  /// Ends a session (guide §4.4).
  static ApiRoute endSession(String id) => ApiRoute(
    ApiMethod.post,
    'lookups/sessions/{id}/end',
    'lookups/sessions/${_id(id)}/end',
  );

  // The official's own checks (guide §5).
  static const checks = ApiRoute(ApiMethod.get, 'checks');

  // Reports (guide §6).
  static const fileReport = ApiRoute(ApiMethod.post, 'incidents');
  static const myReports = ApiRoute(ApiMethod.get, 'incidents');

  /// A photo of report [reportId] (guide §6.2).
  static ApiRoute reportPhotos(int reportId) {
    if (reportId <= 0) {
      throw ArgumentError.value(reportId, 'reportId', 'not a report');
    }
    return ApiRoute(
      ApiMethod.post,
      'incidents/{id}/photos',
      'incidents/$reportId/photos',
    );
  }

  // The retail user picker (guide §7).
  static const retailUsers = ApiRoute(ApiMethod.get, 'retail-users');

  /// Every route, for the contract test; a route with an ID by its
  /// template.
  static final List<ApiRoute> all = [
    login,
    verifyPhone,
    resendCode,
    refresh,
    logout,
    me,
    changePassword,
    forgotPassword,
    resetPassword,
    requestableRoles,
    accessCode,
    accessRequest,
    formats,
    lookups,
    serials,
    sessions,
    session('{id}'),
    endSession('{id}'),
    checks,
    fileReport,
    myReports,
    reportPhotos(1),
    retailUsers,
  ];

  /// [id] encoded for a path; an empty one is refused, never sent as a
  /// path that names another route.
  static String _id(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'empty');
    }
    return Uri.encodeComponent(id);
  }
}
