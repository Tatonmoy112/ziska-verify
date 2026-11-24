/// Whether a typed email is worth sending (final.md §6): after
/// trimming, exactly one `@` with something on both sides, and no spaces,
/// control characters, or invisible (zero-width) characters. A full-width
/// `＠` is not `@`. The server decides the rest.
bool looksLikeEmail(String input) {
  final email = input.trim();
  if (_hidden.hasMatch(email)) return false;
  final at = email.indexOf('@');
  return at > 0 && at == email.lastIndexOf('@') && at < email.length - 1;
}

/// Spaces, control characters, and zero-width characters.
final _hidden = RegExp(r'[\s\x00-\x1F\x7F\u200B-\u200D\u2060\uFEFF]');
