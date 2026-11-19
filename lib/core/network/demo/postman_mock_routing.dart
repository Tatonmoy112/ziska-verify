import 'package:dio/dio.dart';

/// **Mock build only.** Lets the Postman mock (build guide §6) serve the
/// flows a fixed mock cannot tell apart, so the whole app can be tried on
/// it (docs/postman-mock-setup.md). Never in staging or live: the real
/// backend needs none of this.
///
/// - A single check and a scanner-mode scan share `POST lookups`: the
///   `x-mock-response-name` header picks the example. A single check's
///   result follows the value's last digit (1 genuine, 2 needs attention,
///   3 not found, 4 not in a batch); a scan ending in 3 is not found.
/// - The examples carry one fixed session ID: a session's path asks for it,
///   and the answer gets the app's own session ID back.
/// - History's next page has the same query as the first: its cursor asks
///   for the "later page" example.
/// - Every other route names its success example, as the mock may score a
///   body unlike the saved one closer to an error example. The code
///   `111111` logs in to a forced password change (to try **Not now**).
/// - Every photo answers "photo 1": each report's photos are numbered here.
/// - The examples' passes are shortened with "…", which no HTTP header may
///   carry (the app could send nothing after logging in): each is replaced
///   by a numbered stand-in, new on every renewal as a real pass is.
class PostmanMockRouting extends Interceptor {
  PostmanMockRouting();

  /// Stand-in passes given so far.
  int _passes = 0;

  /// Visible ASCII only, as an HTTP header value must be.
  static final _headerSafe = RegExp(r'^[!-~]+$');

  /// The photos numbered so far, per report.
  final _photos = <String, int>{};

  static final _photoPath = RegExp(r'^incidents/(\d+)/photos$');

  /// The success example of each route with a fixed answer.
  static const _pinned = {
    'POST auth/login': '200 New phone: a code was emailed',
    'POST auth/resend-code': '200 A new code was emailed',
    'GET me': '200 The profile',
    'POST me/password': '200 Changed: a new access pass',
    'POST auth/refresh': '200 Renewed: two new passes',
    'POST auth/logout': '200 Logged out',
    'POST auth/password/forgot': '200 Always the same answer',
    'POST auth/password/reset': '200 Changed: log in again',
    'GET roles/requestable': '200 The roles',
    'POST auth/access/code': '200 Always the same answer',
    'POST auth/access': '200 Sent: waiting for the office',
    'GET formats': '200 The formats',
    'POST lookups/serials': '200 Three serials, one sent twice',
    'GET lookups/sessions': '200 Sessions',
    'POST incidents': '201 Filed',
    'GET incidents': '200 The reports',
    'GET retail-users': '200 The retail users',
  };

  /// The session ID in the collection's examples.
  static const exampleSessionId = '7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33';

  static const header = 'x-mock-response-name';
  static const _realId = 'postman_mock_real_session_id';
  static final _sessionPath = RegExp(r'^lookups/sessions/([^/?]+)(/end)?$');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final body = options.data;
    final session = _sessionPath.firstMatch(options.path);
    if (options.method == 'POST' && options.path == 'lookups' && body is Map) {
      final value = '${body['value'] ?? ''}';
      final last = value.isEmpty ? '' : value.substring(value.length - 1);
      options.headers[header] = body.containsKey('session_id')
          ? (last == '3'
                ? '200 not_found'
                : '200 first scan of an item: warning')
          : switch (last) {
              '2' => '200 warning: checked before and expired',
              '3' => '200 not_found',
              '4' => '200 unassigned',
              _ => '200 valid: genuine, first check',
            };
    } else if (options.method == 'GET' && options.path == 'checks') {
      options.headers[header] = options.queryParameters['cursor'] != null
          ? '200 A later page'
          : '200 First page';
    } else if (options.method == 'POST' &&
        options.path == 'auth/verify-phone') {
      options.headers[header] = body is Map && body['code'] == '111111'
          ? '200 Logged in, a new password must be set'
          : '200 Logged in, the phone is now trusted';
    } else if (session != null) {
      options.headers[header] = session.group(2) == null
          ? '200 Session'
          : '200 Session ended';
      if (session.group(1) != exampleSessionId) {
        options.extra[_realId] = session.group(1);
        options.path =
            'lookups/sessions/$exampleSessionId${session.group(2) ?? ''}';
      }
    } else if (_photoPath.hasMatch(options.path)) {
      options.headers[header] = '201 Uploaded as photo 1';
    } else if (_pinned['${options.method} ${options.path}'] case final name?) {
      options.headers[header] = name;
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is Map<String, dynamic>) {
      final sent = options.data;
      final scan = data['session'];
      if (options.path == 'lookups' &&
          sent is Map &&
          sent['session_id'] is String &&
          scan is Map<String, dynamic>) {
        scan['id'] = sent['session_id'];
      }
      final realId = options.extra[_realId];
      if (realId is String && data['id'] is String) data['id'] = realId;
      for (final key in const ['access_token', 'refresh_token']) {
        final pass = data[key];
        if (pass is String && !_headerSafe.hasMatch(pass)) {
          data[key] = 'mock-${key.split('_').first}-${++_passes}';
        }
      }
      final report = _photoPath.firstMatch(options.path)?.group(1);
      if (report != null && data['n'] is int) {
        data['n'] = _photos[report] = (_photos[report] ?? 0) + 1;
      }
    }
    handler.next(response);
  }
}
