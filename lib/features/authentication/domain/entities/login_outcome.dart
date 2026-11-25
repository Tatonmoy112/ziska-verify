import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_outcome.freezed.dart';

/// What a login or a verified code leads to (final.md §6).
@freezed
sealed class LoginOutcome with _$LoginOutcome {
  /// Logged in; both passes are stored.
  const factory LoginOutcome.loggedIn({required bool mustChangePassword}) =
      LoggedIn;

  /// A code was emailed for this new phone.
  const factory LoginOutcome.codeSent(String challengeId) = CodeSent;

  const LoginOutcome._();

  /// Never the challenge, which with the emailed code completes a login
  /// (final.md §12).
  @override
  String toString() => switch (this) {
    LoggedIn(:final mustChangePassword) =>
      'LoggedIn(mustChangePassword: $mustChangePassword)',
    CodeSent() => 'CodeSent()',
  };
}
