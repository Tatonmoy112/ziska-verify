import 'package:ziska_verify/core/services/session/session_state.dart';

/// Owns the login: the two passes, renewal, and the session state stream
/// read by the router guard (final.md Sections 5.5, 6).
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
  /// [canSkip] is the answer's `password_change_skippable`.
  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required bool mustChangePassword,
    bool canSkip = false,
  });

  /// `me/password` answered with a new access pass (the refresh pass stays).
  /// [mustChangePassword] is the answer's `must_change_password`.
  Future<void> savePasswordChange(
    String accessToken, {
    bool mustChangePassword = false,
  });

  /// `me/password/later` answered with a normal access pass (the refresh
  /// pass stays): the official chose **Not now** (final.md Section 6.6).
  Future<void> postponePasswordChange(String accessToken);

  /// Marks that `GET me`, a renewal, or a route reported
  /// `must_change_password`. [canSkip] is `password_change_skippable` when
  /// the answer says; `null` (a bare `403 password_change_required`) keeps
  /// the last known value.
  void requirePasswordChange({bool? canSkip});

  /// One renewal at a time, app-wide: concurrent callers share it
  /// (final.md Section 6.4).
  Future<RenewalResult> renew();

  /// Clears both passes, keeps the phone ID, and emits
  /// [SessionUnauthenticated].
  Future<void> end();

  Future<void> dispose();
}
