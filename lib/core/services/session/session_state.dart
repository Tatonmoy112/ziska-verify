/// The four session states that drive routing (final.md §6).
sealed class SessionState {
  const SessionState();
}

/// No valid session: Login and the pre-login screens.
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// `auth/login` answered `code_sent`: the email code screen.
final class SessionAwaitingCode extends SessionState {
  const SessionAwaitingCode({required this.challengeId, required this.email});
  final String challengeId;

  /// Shown on the email code screen ("We sent a code to …").
  final String email;
}

/// Logged in with `must_change_password: true`: only Change password (and
/// Log out) until it is changed. There is no "Not now" (backend D65,
/// guide §3.2).
final class SessionPasswordChangeRequired extends SessionState {
  const SessionPasswordChangeRequired();
}

/// Logged in, password accepted.
final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated();
}

/// The outcome of one renewal (final.md §6).
sealed class RenewalResult {
  const RenewalResult();
}

/// Both new passes are stored.
final class Renewed extends RenewalResult {
  const Renewed();
}

/// The login ended (`401 unauthenticated`); both passes are cleared.
final class SessionEnded extends RenewalResult {
  const SessionEnded();
}

/// The renewal could not complete (network, 503, 429); the passes are kept.
final class RenewalFailed extends RenewalResult {
  const RenewalFailed(this.error);
  final Object error;
}
