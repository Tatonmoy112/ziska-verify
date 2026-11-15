/// Normalizes typed and scanned input (final.md Section 13.1.2): spaces and
/// `-` are removed and lower-case letters are read as capitals, as the
/// backend does (app API guide §4.1).
class CodeNormalizer {
  const CodeNormalizer();

  static final _ignored = RegExp(r'[\s\-]');

  String normalize(String input) =>
      input.replaceAll(_ignored, '').toUpperCase();
}
