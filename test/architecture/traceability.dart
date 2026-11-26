/// Test cases and tests that point at each other (production audit P-55).
///
/// A test cites a case by its ID (`TC-AUTH-012`) in a name or a comment,
/// a list (`TC-PROF-006, -019`) or a range (`TC-UI-056 … -068`), or by an
/// ID it builds from a data table: `'TC-AUTH-$id'` with rows starting
/// `('029', …)`, `'TC-$id'` with rows starting `('LOOK-024', …)`.
library;

/// One test case: its ID, the files its Auto cell names, and its state.
class TestCase {
  const TestCase(this.id, this.files, {required this.automated});

  final String id;

  /// The test files (`flow/auth_flow_test`) and CI workflows (`ci.yml`)
  /// the Auto cell names.
  final List<String> files;

  /// ✅: a test proves it.
  final bool automated;
}

final _row = RegExp(r'^\| (TC-[A-Z0-9]+-\d{3}) \|');
final _named = RegExp(r'`((?:[a-z0-9_]+/)*[a-z0-9_]+_test|[a-z0-9_]+\.yml)`');

/// The cases of a test-case document's table rows.
List<TestCase> readCases(String markdown) => [
  for (final line in markdown.split('\n'))
    if (_row.firstMatch(line) case final m?)
      () {
        final auto = line.split('|')[6];
        return TestCase(
          m.group(1)!,
          [for (final f in _named.allMatches(auto)) f.group(1)!],
          automated: auto.contains('✅'),
        );
      }(),
];

final _wrapped = RegExp(r'\n\s*//+\s*');
final _cited = RegExp(
  r'TC-([A-Z0-9]+)-(\d{3})'
  r'((?:\s*(?:…|\.\.\.|,|/|and|to)\s*-?(?:TC-[A-Z0-9]+-)?\d{3})*)',
);
final _more = RegExp(r'(…|\.\.\.|,|/|and|to)\s*-?(?:TC-([A-Z0-9]+)-)?(\d{3})');

/// The IDs [source] cites, ranges expanded and IDs built from data tables
/// resolved.
Set<String> citedIds(String source) {
  final text = source.replaceAll(_wrapped, ' ');
  final out = <String>{};
  String id(String area, int n) => 'TC-$area-${'$n'.padLeft(3, '0')}';
  for (final m in _cited.allMatches(text)) {
    final area = m.group(1)!;
    var previous = int.parse(m.group(2)!);
    out.add(id(area, previous));
    // A bare number belongs to the last area named (`TC-SEC-016, -017`).
    var current = area;
    for (final more in _more.allMatches(m.group(3)!)) {
      final to = more.group(2) ?? current;
      final n = int.parse(more.group(3)!);
      final range =
          more.group(1) == '…' ||
          more.group(1) == '...' ||
          more.group(1) == 'to';
      if (range && to == current) {
        for (var k = previous; k <= n; k++) {
          out.add(id(to, k));
        }
      } else {
        out.add(id(to, n));
      }
      previous = n;
      current = to;
    }
  }
  for (final area in RegExp(r'TC-([A-Z0-9]+)-\$').allMatches(source)) {
    for (final row in RegExp(r"\(\s*'(\d{3})'").allMatches(source)) {
      out.add('TC-${area.group(1)}-${row.group(1)}');
    }
  }
  if (source.contains(r'TC-$')) {
    for (final row in RegExp(r"\(\s*'([A-Z0-9]+-\d{3})'").allMatches(source)) {
      out.add('TC-${row.group(1)}');
    }
  }
  return out;
}

/// An ID written without its `TC-` (`'MIG-031 History …'`); an ID alone in
/// a data table's string (`'LOOK-024'`) is the table's, not one.
final _bare = RegExp(
  r"(?<![\w-])(AUTH|SESS|ROLE|NAV|LOOK|HIST|REP|PROF|ERR|SEC|NFR|E2E|UI|MIG|STG|ARCH)-\d{3}\b(?!')",
);

/// What does not point where it should: for [cases] (every document's)
/// and [sources] (each test file and CI workflow by its path), one line
/// per problem.
List<String> traceProblems(
  List<TestCase> cases,
  Map<String, String> sources,
) {
  final byId = {for (final c in cases) c.id: c};
  final cited = {for (final e in sources.entries) e.key: citedIds(e.value)};
  final problems = <String>[];

  bool names(String file, String path) =>
      path.endsWith('/$file.dart') || path.endsWith('/$file');

  for (final c in cases.where((c) => c.automated)) {
    if (c.files.isEmpty) {
      problems.add('${c.id}: ✅ but names no test');
      continue;
    }
    final files = [
      for (final path in cited.keys)
        if (c.files.any((f) => names(f, path))) path,
    ];
    if (!files.any((f) => cited[f]!.contains(c.id))) {
      problems.add('${c.id}: not cited by ${c.files.join(', ')}');
    }
  }
  for (final MapEntry(key: path, value: ids) in cited.entries) {
    for (final id in ids) {
      final c = byId[id];
      if (c == null) {
        problems.add('$path: $id is not a test case');
      } else if (!c.automated) {
        problems.add('$path: $id is not automated (✋)');
      }
    }
    for (final (i, line) in sources[path]!.split('\n').indexed) {
      for (final m in _bare.allMatches(line)) {
        problems.add('$path:${i + 1}: ${m.group(0)} without TC-');
      }
    }
  }
  return problems..sort();
}
