import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiService api,
    required SessionService session,
    required PhoneIdService phoneId,
    required LoggerService logger,
  }) : _api = api,
       _session = session,
       _phoneId = phoneId,
       _logger = logger;

  final AuthApiService _api;
  final SessionService _session;
  final PhoneIdService _phoneId;
  final LoggerService _logger;

  @override
  Future<Result<LoginOutcome>> login({
    required String email,
    required String password,
  }) => guard(() async {
    final dto = await _api.login(
      email: email,
      password: password,
      phoneId: await _readPhoneId(),
    );
    return _apply(dto, email: email);
  });

  @override
  Future<Result<LoginOutcome>> verifyCode(String code) => guard(() async {
    final state = _session.current;
    if (state is! SessionAwaitingCode) {
      throw const UnauthenticatedException(message: 'no_challenge');
    }
    final dto = await _api.verifyPhone(
      challengeId: state.challengeId,
      code: code,
      phoneId: await _readPhoneId(),
    );
    // Back to login while the code was checked: the late answer belongs to
    // a challenge that was given up and never logs in.
    final now = _session.current;
    if (now is! SessionAwaitingCode || now.challengeId != state.challengeId) {
      throw const RequestCancelledException();
    }
    return _apply(dto, email: state.email);
  });

  @override
  Future<Result<void>> resendCode() => guard(() async {
    final state = _session.current;
    if (state is! SessionAwaitingCode) {
      throw const UnauthenticatedException(message: 'no_challenge');
    }
    await _api.resendCode(state.challengeId);
  });

  @override
  void cancelCode() => _session.cancelCode();

  @override
  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) => guard(() async {
    final dto = await _api.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    await _session.savePasswordChange(
      dto.accessToken,
      mustChangePassword: dto.mustChangePassword,
    );
  });

  @override
  Future<Result<void>> requestPasswordReset(String email) =>
      guard(() => _api.forgotPassword(email));

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => guard(
    () =>
        _api.resetPassword(email: email, code: code, newPassword: newPassword),
  );

  Future<void>? _loggingOut;

  /// One logout at a time: a second press while one runs joins it instead
  /// of sending `auth/logout` again.
  @override
  Future<void> logout() =>
      _loggingOut ??= _logout().whenComplete(() => _loggingOut = null);

  Future<void> _logout() async {
    try {
      await _api.logout();
    } on AppException catch (e) {
      // The passes are deleted on the phone whatever the answer.
      _logger.info('logout answered $e');
    }
    await _session.end();
  }

  /// The phone ID; a secure-storage failure (a platform error) becomes an
  /// app error, so the screen says "Something went wrong" instead of
  /// spinning (app API guide §2). The service tries again next time.
  Future<String> _readPhoneId() async {
    try {
      return await _phoneId.getOrCreate();
    } on AppException {
      rethrow;
    } on Object catch (e) {
      _logger.warning('phone ID not readable: ${e.runtimeType}');
      throw const InternalErrorException(message: 'phone_id');
    }
  }

  /// Decided by `data.status`, never by the message (Section 6.2).
  Future<LoginOutcome> _apply(
    LoginResponseDto dto, {
    required String email,
  }) async {
    switch (dto.status) {
      case 'code_sent':
        final challengeId = dto.challengeId;
        if (challengeId == null) {
          throw const InternalErrorException(message: 'login_shape');
        }
        _session.awaitCode(challengeId: challengeId, email: email);
        return CodeSent(challengeId);
      case 'logged_in':
        final access = dto.accessToken;
        final refresh = dto.refreshToken;
        if (access == null || refresh == null) {
          throw const InternalErrorException(message: 'login_shape');
        }
        final mustChange = dto.mustChangePassword ?? false;
        await _session.saveLogin(
          accessToken: access,
          refreshToken: refresh,
          mustChangePassword: mustChange,
        );
        return LoggedIn(mustChangePassword: mustChange);
      default:
        throw InternalErrorException(message: 'login_status_${dto.status}');
    }
  }
}
