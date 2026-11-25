/// Removes anything that looks like a secret before a line is written:
/// bearer passes, JSON fields holding secrets, and 6-digit codes.
abstract final class LogRedactor {
  static final _patterns = <RegExp>[
    RegExp(r'Bearer\s+[A-Za-z0-9\-_.~+/]+=*', caseSensitive: false),
    RegExp(
      '"(access_token|refresh_token|password|old_password|new_password|'
      r'code|phone_id|value)"\s*:\s*"[^"]*"',
      caseSensitive: false,
    ),
    RegExp(r'\b\d{6}\b'),
  ];

  static String redact(String input) {
    var out = input;
    for (final p in _patterns) {
      out = out.replaceAllMapped(p, (m) {
        final text = m.group(0)!;
        if (text.toLowerCase().startsWith('bearer')) return 'Bearer ***';
        final key = m.groupCount >= 1 ? m.group(1) : null;
        return key == null ? '***' : '"$key":"***"';
      });
    }
    return out;
  }
}
