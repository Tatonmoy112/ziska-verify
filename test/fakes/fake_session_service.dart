import 'dart:async';

import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';

/// In-memory [SessionService] that records what it was told.
class FakeSessionService implements SessionService {
  FakeSessionService([this._current]);

  final _controller = StreamController<SessionState>.broadcast();
  SessionState? _current;
  String? savedAccess;
  String? savedRefresh;
  int endCalls = 0;

  @override
  SessionState? get current => _current;

  @override
  Stream<SessionState> get states => _controller.stream;

  /// Whether anything still listens to [states] (production audit P-34).
  bool get hasListeners => _controller.hasListener;

  @override
  String? get accessToken => savedAccess;

  void emitState(SessionState state) {
    _current = state;
    _controller.add(state);
  }

  @override
  Future<void> restore() async => emitState(const SessionUnauthenticated());

  @override
  void awaitCode({required String challengeId, required String email}) =>
      emitState(SessionAwaitingCode(challengeId: challengeId, email: email));

  @override
  void cancelCode() => emitState(const SessionUnauthenticated());

  @override
  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required bool mustChangePassword,
  }) async {
    savedAccess = accessToken;
    savedRefresh = refreshToken;
    emitState(
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
    savedAccess = accessToken;
    emitState(const SessionAuthenticated());
  }

  @override
  void requirePasswordChange() =>
      emitState(const SessionPasswordChangeRequired());

  @override
  Future<RenewalResult> renew() async => const Renewed();

  @override
  Future<void> end() async {
    endCalls++;
    savedAccess = null;
    savedRefresh = null;
    emitState(const SessionUnauthenticated());
  }

  @override
  Future<void> dispose() => _controller.close();
}
