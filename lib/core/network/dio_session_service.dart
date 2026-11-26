import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// [SessionService] that renews on its own Dio instance, which has no auth
/// interceptor and sends no `Authorization` header (final.md §6).
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
  /// login ended stores nothing (final.md §6).
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
      // rather than not starting at all (final.md §6).
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
    // phone stays trusted (final.md §6).
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
    _generation++;
    try {
      await _storePasses(accessToken, refreshToken);
    } on InternalErrorException {
      // Not logged in: the passes do not stay in memory either.
      _accessToken = null;
      _refreshToken = null;
      rethrow;
    }
    _emit(
      mustChangePassword
          ? const SessionPasswordChangeRequired()
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
    // it is, so the router does not rebuild the screens (final.md §6).
    if (_current is! SessionAuthenticated) _emit(const SessionAuthenticated());
  }

  @override
  void requirePasswordChange() {
    if (_current is SessionPasswordChangeRequired) return;
    _emit(const SessionPasswordChangeRequired());
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
        ApiRoutes.refresh.path,
        data: {'refresh_token': refresh},
      );
      final data = ApiData.map(
        ApiEnvelope.unwrap(response.data),
        ApiAnswer.renewal,
      );
      final access = data['access_token'];
      final next = data['refresh_token'];
      if (access is! String || next is! String) {
        throw const InternalErrorException(reason: ApiAnswer.renewal);
      }
      // Logged out (or in again) meanwhile: these passes belong to a login
      // that is over.
      if (generation != _generation) return const SessionEnded();
      // Both new passes are stored before anything else (§6). If
      // the phone cannot store them, they still work from memory: the old
      // refresh pass is spent and must never be sent again (guide §3.4).
      try {
        await _storePasses(access, next);
      } on InternalErrorException catch (e) {
        _logger.warning('renewed passes kept in memory only: $e');
      }
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

  /// Keeps the new passes in memory first, then on the phone
  /// (UI audit 2026-11-22, 1.1).
  /// A renewal has already spent the old refresh pass, and "sending one
  /// that was already used ends the login" on every phone (guide §3.4), so
  /// it must never be sent again. When they cannot be stored, the old pair
  /// is deleted too, so a restart asks for a login instead of sending it.
  Future<void> _storePasses(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    try {
      await _write(SecureKeys.accessToken, access);
      await _write(SecureKeys.refreshToken, refresh);
    } on InternalErrorException {
      await _deleteStored();
      rethrow;
    }
  }

  /// Deletes both stored passes, as far as the phone allows.
  Future<void> _deleteStored() async {
    for (final key in [SecureKeys.accessToken, SecureKeys.refreshToken]) {
      try {
        await _storage.delete(key);
      } on Object catch (e) {
        _logger.warning('pass not deleted: ${e.runtimeType}');
      }
    }
  }

  /// A storage write that fails (a full disk, a broken keystore) is an app
  /// error the screen shows, never an escaped platform error.
  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key, value);
    } on Object catch (e) {
      _logger.warning('pass not stored: ${e.runtimeType}');
      throw const InternalErrorException(reason: CoreReason.storage);
    }
  }

  @override
  Future<void> end() async {
    _generation++;
    _accessToken = null;
    _refreshToken = null;
    // Login is reached even when the passes cannot be deleted; the next
    // start finds no usable pair and starts again (§6).
    await _deleteStored();
    // The phone ID is kept on purpose (§6).
    if (_current is! SessionUnauthenticated) {
      _emit(const SessionUnauthenticated());
    }
  }

  @override
  /// Closes the state stream and the renewal client (production audit
  /// P-34).
  Future<void> dispose() {
    _refreshDio.close();
    return _controller.close();
  }
}
