/// A role the client's office marked as a retail role (`GET retail-roles`).
class RetailRole {
  const RetailRole({required this.id, required this.name});

  final int id;
  final String name;
}

/// What happened to the login email (final.md Section 13.6.1).
enum EmailOutcome {
  /// `email_sent: true`: the login details were emailed.
  sent,

  /// `email_sent: false`: the mail failed; the account exists.
  failed,

  /// `email_sent: null`: not sent, as asked (`send_email: false`).
  notRequested,
}

/// The answer to adding a retail user.
class AddedRetailUser {
  const AddedRetailUser({
    required this.id,
    required this.name,
    required this.email,
    required this.emailOutcome,
  });

  final String id;
  final String name;
  final String email;
  final EmailOutcome emailOutcome;
}

/// The rules of the add form (final.md Section 13.6.1, backend D50).
abstract final class RetailUserRules {
  static const nameMaxLength = 100;

  /// A first password works once: 1 to 128 characters, no other rule.
  static const passwordMaxLength = 128;

  static final _control = RegExp(r'\p{Cc}', unicode: true);

  static bool isFirstPasswordValid(String password) =>
      password.isNotEmpty &&
      password.runes.length <= passwordMaxLength &&
      !_control.hasMatch(password);

  static bool isEmailValid(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
}
