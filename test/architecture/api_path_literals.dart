/// API paths written as text where `ApiRoutes` has them (production audit
/// P-52; R20 makes every route in `api_routes.dart`, this finds the paths
/// written out by hand).
///
/// A path is a quoted text that is a route's whole template, with each
/// `{id}` written as any interpolation or text without `/` or a quote
/// (`'lookups/sessions/$id/end'`), wherever it stands, inside another
/// string's interpolation too. A message that only mentions a path
/// (`'POST auth/logout, empty JSON body'`) is not one; comments are left
/// out.
library;

final _comment = RegExp(r'//[^\n]*|/\*[\s\S]*?\*/');

/// The quoted paths of [code] that are one of [templates], as `line: text`.
List<String> apiPathLiterals(String code, Iterable<String> templates) {
  final patterns = [
    for (final t in templates)
      RegExp(
        "'(${t.split(RegExp(r'\{[^}]+\}')).map(RegExp.escape).join(
          r"[^/'\n]+",
        )})'",
      ),
  ];
  final found = <String>[];
  for (final (i, line) in code.split('\n').indexed) {
    final text = line.replaceAll(_comment, '');
    for (final p in patterns) {
      for (final m in p.allMatches(text)) {
        found.add('${i + 1}: ${m.group(1)}');
      }
    }
  }
  return found;
}
