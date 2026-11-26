/// Text limits counted the way the backend counts them.
///
/// The test server counts a search (guide §7.1) and an access
/// request's name (guide §3.9) in UTF-16 units, an emoji as two; a note
/// and a password in code points (2026-11-22, backend question B5).
abstract final class TextLimits {
  /// [text]'s whole characters, as many as fit in [units] UTF-16 units:
  /// never half of an emoji. Within the limit whichever way the server
  /// counts, as code points are never more than units.
  static String fitUtf16(String text, int units) {
    if (text.length <= units) return text;
    final out = StringBuffer();
    var used = 0;
    for (final rune in text.runes) {
      final size = rune > 0xFFFF ? 2 : 1;
      if (used + size > units) break;
      out.writeCharCode(rune);
      used += size;
    }
    return out.toString();
  }
}
