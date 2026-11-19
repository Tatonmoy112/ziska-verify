import 'package:dio/dio.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';

/// **Mock build only.** Plays the backend's coming answers for **Not now**
/// on a forced password change, on top of the Postman mock, so the flow can
/// be seen and tested before the backend ships it (final.md Section 17).
///
/// Remove this file, its wiring in `registerCore`, and the
/// `DEMO_PASSWORD_LATER` flag when the backend ships `me/password/later`
/// (docs/backend-requests/password-change-later.md).
///
/// - A login with `must_change_password` gets `password_change_skippable`.
/// - `me/password/later` is answered here, without the network.
/// - After **Not now**, renewals and `GET me` no longer force the change,
///   and `GET me` says `password_change_pending` (the Profile reminder).
/// - After a change, `GET me` drops both; the next login starts again.
///
/// The state is in memory only: an app restart in the middle of a
/// postponed login lets the mock decide again.
class PasswordLaterDemo extends Interceptor {
  PasswordLaterDemo(this._logger);

  final LoggerService _logger;
  _State _state = _State.none;

  static const _later = 'me/password/later';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'POST' && options.path == _later) {
      _state = _State.postponed;
      _logger.info('demo: password change postponed');
      // The request's own pass stays valid: the mock does not check it.
      final pass = (options.headers['Authorization'] as String? ?? '')
          .replaceFirst('Bearer ', '');
      return handler.resolve(
        Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Password change postponed.',
            'data': {
              'access_token': pass.isEmpty ? 'demo-access' : pass,
              'access_expires_in': 900,
              'must_change_password': false,
              'password_change_pending': true,
            },
          },
        ),
      );
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
      switch ('${options.method} ${options.path}') {
        case 'POST auth/login' || 'POST auth/verify-phone':
          if (data['status'] == 'logged_in') {
            // Each login asks again.
            _state = _State.none;
            _offerLater(data);
          }
        case 'POST auth/refresh':
          if (_state == _State.postponed) {
            data['must_change_password'] = false;
          } else {
            _offerLater(data);
          }
        case 'GET me':
          switch (_state) {
            case _State.postponed:
              data['must_change_password'] = false;
              data['password_change_pending'] = true;
            case _State.changed:
              data['must_change_password'] = false;
              data['password_change_pending'] = false;
            case _State.none:
              _offerLater(data);
          }
        case 'POST me/password':
          _state = _State.changed;
          _logger.info('demo: password changed');
      }
    }
    handler.next(response);
  }

  static void _offerLater(Map<String, dynamic> data) {
    if (data['must_change_password'] == true) {
      data['password_change_skippable'] = true;
    }
  }
}

enum _State { none, postponed, changed }
