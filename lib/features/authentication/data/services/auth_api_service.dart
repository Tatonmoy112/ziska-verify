import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';

/// The authentication routes (final.md Section 5.7). `auth/refresh` is
/// called only by `SessionService`.
abstract interface class AuthApiService {
  Future<LoginResponseDto> login({
    required String email,
    required String password,
    required String phoneId,
  });

  Future<LoginResponseDto> verifyPhone({
    required String challengeId,
    required String code,
    required String phoneId,
  });

  Future<void> resendCode(String challengeId);

  Future<void> logout();

  Future<PasswordChangeResponseDto> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// `me/password/later`: **Not now** on a forced change.
  Future<PasswordLaterResponseDto> postponePasswordChange();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

class DioAuthApiService implements AuthApiService {
  DioAuthApiService(this._api);

  final ApiClient _api;

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
    required String phoneId,
  }) async => LoginResponseDto.fromJson(
    _map(
      await _api.post(
        'auth/login',
        body: {'email': email, 'password': password, 'phone_id': phoneId},
        skipAuth: true,
      ),
    ),
  );

  @override
  Future<LoginResponseDto> verifyPhone({
    required String challengeId,
    required String code,
    required String phoneId,
  }) async => LoginResponseDto.fromJson(
    _map(
      await _api.post(
        'auth/verify-phone',
        body: {'challenge_id': challengeId, 'code': code, 'phone_id': phoneId},
        skipAuth: true,
      ),
    ),
  );

  @override
  Future<void> resendCode(String challengeId) => _api.post(
    'auth/resend-code',
    body: {'challenge_id': challengeId},
    skipAuth: true,
  );

  @override
  Future<void> logout() => _api.post('auth/logout');

  @override
  Future<PasswordChangeResponseDto> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async => PasswordChangeResponseDto.fromJson(
    _map(
      await _api.post(
        'me/password',
        body: {'old_password': oldPassword, 'new_password': newPassword},
        // Here 401 means the old password is wrong, not that the login
        // ended (app API guide §3.6).
        keepSessionOn401: true,
      ),
    ),
  );

  @override
  Future<PasswordLaterResponseDto> postponePasswordChange() async =>
      PasswordLaterResponseDto.fromJson(
        _map(await _api.post('me/password/later')),
      );

  @override
  Future<void> forgotPassword(String email) => _api.post(
    'auth/password/forgot',
    body: {'email': email},
    skipAuth: true,
  );

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _api.post(
    'auth/password/reset',
    body: {'email': email, 'code': code, 'new_password': newPassword},
    skipAuth: true,
  );

  static Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const InternalErrorException(message: 'auth_shape');
  }
}
