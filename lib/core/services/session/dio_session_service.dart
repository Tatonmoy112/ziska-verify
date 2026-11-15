import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// [SessionService] that renews on its own Dio instance, which has no auth
/// interceptor and sends no `Authorization` header (final.md Section 6.4).
class DioSessionService implements SessionService {
  DioSessionService({
    required SecureStorageService storage,
    required Dio refreshDio,
    required LoggerService logger,
  }) : _storage = storage,
       _refreshDio = refreshDio,
       _logger = logger;

  final SecureStorageService _storage;
  final Dio _refreshDio;
  final LoggerService _logger;
  final _controller = StreamController<SessionState>.broadcast();

  SessionState? _current;
  String? _accessToken;
  String? _refreshToken;
  Future<RenewalResult>? _renewing;

  @override
  SessionState? get current => _current;

  @override
  Stream<SessionState> get states => _controller.stream;

  @override
  String? get accessToken => _accessToken;

  void _emit(SessionState state) {
    _current = state;
    _controller.add(state);
  }

  @override
  Future<void> restore() async {
    _accessToken = await _storage.read(SecureKeys.accessToken);
    _refreshToken = await _storage.read(SecureKeys.refreshToken);
    final hasAccess = _accessToken?.isNotEmpty ?? false;
    final hasRefresh = _refreshToken?.isNotEmpty ?? false;
    if (hasAccess && hasRefresh) {
      _emit(const SessionAuthenticated());
      return;
    }
    // A login needs both passes. With only one left (an interrupted write),
    // requests would go out without a pass: start again from Login. The
    // phone stays trusted (final.md Sections 6.1, 6.7).
    if (hasAccess || hasRefresh) return end();
    _emit(const SessionUnauthenticated());
  }

  @override
  void awaitCode({required String challengeId, required String email}) =>
      _emit(SessionAwaitingCode(challengeId: challengeId, email: email));

  @override
  void cancelCode() => _emit(const SessionUnauthenticated());

  @override
  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required bool mustChangePassword,
  }) async {
    await _storePasses(accessToken, refreshToken);
    _emit(
      mustChangePassword
          ? const SessionPasswordChangeRequired()
          : const SessionAuthenticated(),
    );
  }

  @override
  Future<void> savePasswordChange(String accessToken) async {
    await _storage.write(SecureKeys.accessToken, accessToken);
    _accessToken = accessToken;
    // A forced change moves the session on; a voluntary one leaves it as
    // it is, so the router does not rebuild the screens (final.md 6.6).
    if (_current is! SessionAuthenticated) _emit(const SessionAuthenticated());
  }

  @override
  void requirePasswordChange() {
    if (_current is! SessionPasswordChangeRequired) {
      _emit(const SessionPasswordChangeRequired());
    }
  }

  @override
  Future<RenewalResult> renew() {
    final pending = _renewing;
    if (pending != null) return pending;
    final started = _renew();
    _renewing = started;
    // Cleared once settled, so the next expiry starts a new renewal.
    unawaited(started.whenComplete(() => _renewing = null));
    return started;
  }

  Future<RenewalResult> _renew() async {
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) {
      await end();
      return const SessionEnded();
    }
    try {
      final response = await _refreshDio.post<Object?>(
        'auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = ApiEnvelope.unwrap(response.data);
      if (data is! Map<String, dynamic>) {
        throw const InternalErrorException(message: 'renewal_shape');
      }
      final access = data['access_token'] as String?;
      final next = data['refresh_token'] as String?;
      if (access == null || next == null) {
        throw const InternalErrorException(message: 'renewal_shape');
      }
      // Both new passes are stored before anything else (Section 6.4).
      await _storePasses(access, next);
      if (data['must_change_password'] == true) requirePasswordChange();
      _logger.info('session renewed');
      return const Renewed();
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e);
      if (error is UnauthenticatedException) {
        _logger.info('session ended at renewal (${error.requestId})');
        await end();
        return const SessionEnded();
      }
      _logger.warning('renewal failed: $error');
      return RenewalFailed(error);
    } on AppException catch (e) {
      _logger.warning('renewal failed: $e');
      return RenewalFailed(e);
    }
  }

  Future<void> _storePasses(String access, String refresh) async {
    await _storage.write(SecureKeys.accessToken, access);
    await _storage.write(SecureKeys.refreshToken, refresh);
    _accessToken = access;
    _refreshToken = refresh;
  }

  @override
  Future<void> end() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(SecureKeys.accessToken);
    await _storage.delete(SecureKeys.refreshToken);
    // The phone ID is kept on purpose (Section 6.1).
    if (_current is! SessionUnauthenticated) {
      _emit(const SessionUnauthenticated());
    }
  }

  @override
  Future<void> dispose() => _controller.close();
}
