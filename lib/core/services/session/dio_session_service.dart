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

  /// Bumped by every login and every end: a renewal that finishes after its
  /// login ended stores nothing (final.md Section 6.4).
  int _generation = 0;

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
    try {
      _accessToken = await _storage.read(SecureKeys.accessToken);
      _refreshToken = await _storage.read(SecureKeys.refreshToken);
    } on Object catch (e) {
      // Unreadable storage (a broken keystore): start again from Login
      // rather than not starting at all (final.md Section 6.1).
      _logger.warning('stored passes unreadable: ${e.runtimeType}');
      return end();
    }
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

  /// Whether the last answer allowed **Not now**; kept for a bare `403
  /// password_change_required`, which does not say.
  bool _canSkip = false;

  @override
  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required bool mustChangePassword,
    bool canSkip = false,
  }) async {
    _generation++;
    await _storePasses(accessToken, refreshToken);
    _canSkip = canSkip;
    _emit(
      mustChangePassword
          ? SessionPasswordChangeRequired(canSkip: canSkip)
          : const SessionAuthenticated(),
    );
  }

  @override
  Future<void> savePasswordChange(
    String accessToken, {
    bool mustChangePassword = false,
  }) async {
    await _write(SecureKeys.accessToken, accessToken);
    _accessToken = accessToken;
    // An answer that still forces a change keeps the session there.
    if (mustChangePassword) return requirePasswordChange();
    // A forced change moves the session on; a voluntary one leaves it as
    // it is, so the router does not rebuild the screens (final.md 6.6).
    if (_current is! SessionAuthenticated) _emit(const SessionAuthenticated());
  }

  @override
  Future<void> postponePasswordChange(String accessToken) async {
    await _write(SecureKeys.accessToken, accessToken);
    _accessToken = accessToken;
    _emit(const SessionAuthenticated());
  }

  @override
  void requirePasswordChange({bool? canSkip}) {
    if (canSkip != null) _canSkip = canSkip;
    final current = _current;
    if (current is SessionPasswordChangeRequired &&
        current.canSkip == _canSkip) {
      return;
    }
    _emit(SessionPasswordChangeRequired(canSkip: _canSkip));
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
    final generation = _generation;
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
      final access = data['access_token'];
      final next = data['refresh_token'];
      if (access is! String || next is! String) {
        throw const InternalErrorException(message: 'renewal_shape');
      }
      // Logged out (or in again) meanwhile: these passes belong to a login
      // that is over.
      if (generation != _generation) return const SessionEnded();
      // Both new passes are stored before anything else (Section 6.4).
      await _storePasses(access, next);
      if (data['must_change_password'] == true) {
        requirePasswordChange(
          canSkip: data['password_change_skippable'] == true,
        );
      }
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
    await _write(SecureKeys.accessToken, access);
    await _write(SecureKeys.refreshToken, refresh);
    _accessToken = access;
    _refreshToken = refresh;
  }

  /// A storage write that fails (a full disk, a broken keystore) is an app
  /// error the screen shows, never an escaped platform error.
  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key, value);
    } on Object catch (e) {
      _logger.warning('pass not stored: ${e.runtimeType}');
      throw const InternalErrorException(message: 'storage');
    }
  }

  @override
  Future<void> end() async {
    _generation++;
    _accessToken = null;
    _refreshToken = null;
    // Login is reached even when the passes cannot be deleted; the next
    // start finds no usable pair and starts again (Section 6.5).
    for (final key in [SecureKeys.accessToken, SecureKeys.refreshToken]) {
      try {
        await _storage.delete(key);
      } on Object catch (e) {
        _logger.warning('pass not deleted: ${e.runtimeType}');
      }
    }
    // The phone ID is kept on purpose (Section 6.1).
    if (_current is! SessionUnauthenticated) {
      _emit(const SessionUnauthenticated());
    }
  }

  @override
  Future<void> dispose() => _controller.close();
}
