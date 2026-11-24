import 'package:ziska_verify/core/services/session/session_state.dart';

/// Owns the login: the two passes, renewal, and the session state stream
/// read by the router guard (final.md §6).
abstract interface class SessionService {
  /// The current state; `null` until [restore] completes.
  SessionState? get current;

  /// Every state change, starting with the one [restore] sets.
  Stream<SessionState> get states;

  /// The access pass for the `Authorization` header, or `null`.
  String? get accessToken;

  /// Reads the stored passes at start.
  Future<void> restore();

  /// `auth/login` answered `code_sent`.
  void awaitCode({required String challengeId, required String email});

  /// Back from Verify code to Login.
  void cancelCode();

  /// Stores both passes from a `logged_in` answer, before anything else.
  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required bool mustChangePassword,
  });

  /// `me/password` answered with a new access pass (the refresh pass stays).
  /// [mustChangePassword] is the answer's `must_change_password`.
  Future<void> savePasswordChange(
    String accessToken, {
    bool mustChangePassword = false,
  });

  /// Marks that `GET me`, a renewal, or a route reported
  /// `must_change_password`.
  void requirePasswordChange();

  /// One renewal at a time, app-wide: concurrent callers share it
  /// (final.md §6).
  Future<RenewalResult> renew();

  /// Clears both passes, keeps the phone ID, and emits
  /// [SessionUnauthenticated].
  Future<void> end();

  Future<void> dispose();
}
