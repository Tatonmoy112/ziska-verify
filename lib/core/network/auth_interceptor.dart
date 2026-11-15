import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';

/// Request flags read by [AuthInterceptor].
abstract final class RequestFlags {
  /// Sends no `Authorization` header (login, code, forgotten password).
  static const skipAuth = 'skip_auth';

  /// A `401 unauthenticated` here does not end the login: on `me/password`
  /// it means the old password is wrong (app API guide §3.6).
  static const keepSessionOn401 = 'keep_session_on_401';

  /// Set on the single retry after a renewal.
  static const retried = 'retried';

  /// The access pass this request was sent with.
  static const usedToken = 'used_token';
}

/// Adds the access pass and renews it on `401 token_expired` only, then
/// retries the request once (final.md Section 6.4).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionService session,
    required Dio dio,
    void Function()? onForbidden,
  }) : _session = session,
       _dio = dio,
       _onForbidden = onForbidden;

  final SessionService _session;
  final Dio _dio;

  /// Called on every `403 forbidden` (final.md Section 7.2).
  final void Function()? _onForbidden;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _session.accessToken;
    if (options.extra[RequestFlags.skipAuth] != true && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[RequestFlags.usedToken] = token;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final response = err.response;
    final code = _codeOf(response?.data);
    final sentWithToken = options.extra[RequestFlags.usedToken] != null;

    if (response?.statusCode == 401 &&
        code == 'token_expired' &&
        sentWithToken &&
        options.extra[RequestFlags.retried] != true) {
      // A request that failed with a pass renewed meanwhile is retried with
      // the new pass; it never starts a second renewal.
      if (options.extra[RequestFlags.usedToken] == _session.accessToken) {
        final result = await _session.renew();
        switch (result) {
          case Renewed():
            break;
          case SessionEnded():
            return handler.reject(
              _withError(err, const UnauthenticatedException(statusCode: 401)),
            );
          case RenewalFailed(:final error):
            return handler.reject(_withError(err, error));
        }
      }
      options.extra[RequestFlags.retried] = true;
      try {
        final retried = await _dio.fetch<Object?>(options);
        return handler.resolve(retried);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    // Every route except me, me/password and logout answers this until the
    // password is changed (final.md Section 6.6).
    if (response?.statusCode == 403 && code == 'password_change_required') {
      _session.requirePasswordChange();
    }

    // The role may have lost a permission: the profile is loaded again.
    if (response?.statusCode == 403 && code == 'forbidden') {
      _onForbidden?.call();
    }

    if (response?.statusCode == 401 &&
        code == 'unauthenticated' &&
        sentWithToken &&
        options.extra[RequestFlags.keepSessionOn401] != true) {
      await _session.end();
    }
    handler.next(err);
  }

  static DioException _withError(DioException err, Object error) =>
      err.copyWith(error: error);

  static String? _codeOf(Object? body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map<String, dynamic>) return error['code'] as String?;
    }
    return null;
  }
}
