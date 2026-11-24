/// What a login or a verified code leads to (final.md §6).
sealed class LoginOutcome {
  const LoginOutcome();
}

/// Logged in; both passes are stored.
final class LoggedIn extends LoginOutcome {
  const LoggedIn({required this.mustChangePassword});
  final bool mustChangePassword;
}

/// A code was emailed for this new phone.
final class CodeSent extends LoginOutcome {
  const CodeSent(this.challengeId);
  final String challengeId;
}
