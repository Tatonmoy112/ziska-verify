/// Text limits counted the way the backend counts them: every length is in
/// Unicode code points, an emoji as one (backend DEC-429; guide §1).
abstract final class TextLimits {
  /// [text]'s first [max] characters counted as code points: cut at a whole
  /// character, never half of an emoji.
  static String fitCodePoints(String text, int max) {
    final runes = text.runes;
    if (runes.length <= max) return text;
    return String.fromCharCodes(runes.take(max));
  }
}
