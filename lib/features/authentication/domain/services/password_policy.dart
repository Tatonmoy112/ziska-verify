/// The result of checking a new password against the rule.
class PasswordCheck {
  const PasswordCheck({
    required this.hasLength,
    required this.hasLetter,
    required this.hasNumber,
    required this.hasNoControl,
  });

  /// 8 to 128 characters.
  final bool hasLength;

  /// At least one letter of any alphabet (Bangla included).
  final bool hasLetter;

  /// At least one digit of any script.
  final bool hasNumber;

  /// No line breaks, tabs, or other control characters.
  final bool hasNoControl;

  bool get isValid => hasLength && hasLetter && hasNumber && hasNoControl;
}

/// The password rule of backend D54 (final.md Section 6.6). Checked before
/// sending; the server is final.
class PasswordPolicy {
  const PasswordPolicy();

  static const minLength = 8;
  static const maxLength = 128;

  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _number = RegExp(r'\p{Nd}', unicode: true);
  static final _control = RegExp(r'\p{Cc}', unicode: true);

  PasswordCheck check(String password) {
    // Counted in characters (code points), never in bytes.
    final length = password.runes.length;
    return PasswordCheck(
      hasLength: length >= minLength && length <= maxLength,
      hasLetter: _letter.hasMatch(password),
      hasNumber: _number.hasMatch(password),
      hasNoControl: !_control.hasMatch(password),
    );
  }
}
