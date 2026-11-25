import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';

/// The authentication routes (final.md §15). `auth/refresh` is
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
    ApiData.map(
      await _api.post(
        ApiRoutes.login,
        body: {'email': email, 'password': password, 'phone_id': phoneId},
        skipAuth: true,
      ),
      'auth',
    ),
  );

  @override
  Future<LoginResponseDto> verifyPhone({
    required String challengeId,
    required String code,
    required String phoneId,
  }) async => LoginResponseDto.fromJson(
    ApiData.map(
      await _api.post(
        ApiRoutes.verifyPhone,
        body: {'challenge_id': challengeId, 'code': code, 'phone_id': phoneId},
        skipAuth: true,
      ),
      'auth',
    ),
  );

  @override
  Future<void> resendCode(String challengeId) => _api.post(
    ApiRoutes.resendCode,
    body: {'challenge_id': challengeId},
    skipAuth: true,
  );

  @override
  Future<void> logout() => _api.post(ApiRoutes.logout);

  @override
  Future<PasswordChangeResponseDto> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async => PasswordChangeResponseDto.fromJson(
    ApiData.map(
      await _api.post(
        ApiRoutes.changePassword,
        body: {'old_password': oldPassword, 'new_password': newPassword},
        // Here 401 means the old password is wrong, not that the login
        // ended (app API guide §3.6).
        keepSessionOn401: true,
      ),
      'auth',
    ),
  );

  @override
  Future<void> forgotPassword(String email) => _api.post(
    ApiRoutes.forgotPassword,
    body: {'email': email},
    skipAuth: true,
  );

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _api.post(
    ApiRoutes.resetPassword,
    body: {'email': email, 'code': code, 'new_password': newPassword},
    skipAuth: true,
  );
}
