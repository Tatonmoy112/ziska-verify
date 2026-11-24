import 'package:ziska_verify/core/utils/ascii_digits.dart';

/// Normalizes typed and scanned input (final.md §13.1): spaces and
/// `-` are removed and lower-case letters are read as capitals, as the
/// backend does (app API guide §4.1). Digits of another script (Bangla
/// `০`–`৯`) are read as `0`–`9` (final.md §16).
class CodeNormalizer {
  const CodeNormalizer();

  static final _ignored = RegExp(r'[\s\-]');

  String normalize(String input) =>
      toAsciiDigits(input.replaceAll(_ignored, '')).toUpperCase();
}
