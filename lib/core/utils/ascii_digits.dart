/// Digits of other scripts read as `0`–`9`: Bangla (`০`–`৯`), Arabic-Indic
/// (`٠`–`٩`), Extended Arabic-Indic (`۰`–`۹`), and Devanagari (`०`–`९`). A
/// Bangla keyboard types Bangla digits; the backend reads ASCII only
/// (final.md Section 16).
String toAsciiDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    out.writeCharCode(_asciiDigit(rune) ?? rune);
  }
  return out.toString();
}

int? _asciiDigit(int rune) {
  for (final zero in _zeros) {
    if (rune >= zero && rune <= zero + 9) return 0x30 + rune - zero;
  }
  return null;
}

const _zeros = [0x09E6, 0x0660, 0x06F0, 0x0966];
