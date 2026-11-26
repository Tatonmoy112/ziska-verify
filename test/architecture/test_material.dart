/// Test material nothing uses (production audit P-51): screenshots no test
/// takes, and recorded server answers no test loads.
///
/// Both are matched by name in the tests' code, comments left out. A
/// screenshot is taken when its name is written whole (`shot('name')`, or
/// in a list the test loops over), or as a written prefix and an
/// interpolated suffix (`'bn'` with `shot('${name}_login')`). An answer is
/// loaded when its file name is written whole.
library;

final _comment = RegExp(r'//[^\n]*|/\*[\s\S]*?\*/');

/// The code of [sources] without its comments.
String _code(Iterable<String> sources) =>
    sources.map((s) => s.replaceAll(_comment, '')).join('\n');

/// The screenshots of [names] (file names without `.png`) no test takes.
List<String> untakenScreenshots({
  required Iterable<String> names,
  required Iterable<String> sources,
}) {
  final code = _code(sources);
  final written = {
    for (final m in RegExp("'([A-Za-z0-9_]+)'").allMatches(code)) m.group(1)!,
  };
  final suffixes = {
    for (final m in RegExp(r"\}(_[A-Za-z0-9_]+)'").allMatches(code))
      m.group(1)!,
  };
  bool taken(String name) =>
      written.contains(name) ||
      suffixes.any(
        (s) =>
            name.endsWith(s) &&
            written.contains(name.substring(0, name.length - s.length)),
      );
  return [
    for (final n in names)
      if (!taken(n)) n,
  ];
}

/// The recorded answers of [files] (file names with `.json`) no test
/// loads.
List<String> unloadedAnswers({
  required Iterable<String> files,
  required Iterable<String> sources,
}) {
  final code = _code(sources);
  return [
    for (final f in files)
      if (!code.contains("'$f'")) f,
  ];
}
