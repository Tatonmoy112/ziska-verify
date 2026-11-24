import 'dart:io';

/// The documents the code's comments cite, each with the section or
/// finding numbers it has (production audit P-11).
enum Doc {
  finalMd('final.md'),
  apiGuide('app API guide'),
  buildGuide('app build guide'),
  uiAudit('UI audit 2026-11-22')
  ;

  const Doc(this.label);

  final String label;
}

/// One citation in a comment that does not resolve.
class BadReference {
  const BadReference(this.file, this.line, this.problem);

  final String file;
  final int line;
  final String problem;

  @override
  String toString() => '$file:$line: $problem';
}

// The longest names first, so "app build guide" is not read as "guide".
final _token = RegExp(
  r'(app build guide|build guide|app API guide|API guide|guide|final\.md|'
  'UI audit 2026-11-22,?|audit)'
  r'|(§ ?|Sections? )(\d+(?:\.\d+)*)'
  r'((?:(?:,? and |, |–|-)\d+(?:\.\d+)*)*)',
);
final _number = RegExp(r'\d+(?:\.\d+)*');
final _auditNumber = RegExp(r'^\s*(\d+\.\d+)');

/// Checks every citation in the comments of [sources] (path → text)
/// against [sections]: for each document, the numbers it has.
///
/// In a comment, `§N` or `Section N` belongs to the last document named
/// before it on the same line, and to `final.md` when none is. A list or a
/// range (`Sections 7.2, 9.4`, `§4.3–4.6`) cites every number in it. An
/// audit's finding must name its audit (`UI audit 2026-11-22, 4.2`).
List<BadReference> badReferences(
  Map<String, String> sources,
  Map<Doc, Set<String>> sections,
) {
  final bad = <BadReference>[];
  for (final MapEntry(key: file, value: text) in sources.entries) {
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final at = lines[i].indexOf('//');
      if (at < 0) continue;
      final comment = lines[i].substring(at);
      var doc = Doc.finalMd;
      for (final m in _token.allMatches(comment)) {
        final name = m.group(1);
        if (name != null) {
          if (name.startsWith('UI audit')) {
            doc = Doc.uiAudit;
            final finding = _auditNumber.firstMatch(
              comment.substring(m.end),
            );
            if (finding == null) continue;
            if (!sections[Doc.uiAudit]!.contains(finding.group(1))) {
              bad.add(
                BadReference(
                  file,
                  i + 1,
                  '${Doc.uiAudit.label} has no finding ${finding.group(1)}',
                ),
              );
            }
          } else if (name == 'audit') {
            if (_auditNumber.hasMatch(comment.substring(m.end))) {
              bad.add(
                BadReference(
                  file,
                  i + 1,
                  'an audit finding without its audit: write '
                  '"${Doc.uiAudit.label}, N.N"',
                ),
              );
            }
          } else if (name.contains('build guide')) {
            doc = Doc.buildGuide;
          } else if (name.contains('guide')) {
            doc = Doc.apiGuide;
          } else {
            doc = Doc.finalMd;
          }
          continue;
        }
        if (doc == Doc.uiAudit) doc = Doc.finalMd;
        final numbers = [
          m.group(3)!,
          for (final n in _number.allMatches(m.group(4) ?? '')) n.group(0)!,
        ];
        for (final n in numbers) {
          if (!sections[doc]!.contains(n)) {
            bad.add(BadReference(file, i + 1, '${doc.label} has no §$n'));
          }
        }
      }
    }
  }
  return bad;
}

/// The numbered headings of a Markdown document (`## 4. …`, `### 13.1 …`).
Set<String> headings(String markdown) => {
  for (final m in RegExp(
    r'^#{1,4} (\d+(?:\.\d+)*)\.? ',
    multiLine: true,
  ).allMatches(markdown))
    m.group(1)!,
};

/// The finding numbers of an audit's tables (`| 4.2 | … |`).
Set<String> findings(String markdown) => {
  for (final m in RegExp(
    r'^\| ?(\d+\.\d+) ?\|',
    multiLine: true,
  ).allMatches(markdown))
    m.group(1)!,
};

/// The sections of the four documents, read from the repository.
Map<Doc, Set<String>> readSections() => {
  Doc.finalMd: headings(File('final.md').readAsStringSync()),
  Doc.apiGuide: headings(
    File('docs/protectb-api/app-api-guide.md').readAsStringSync(),
  ),
  Doc.buildGuide: headings(
    File('docs/protectb-api/app-build-guide.md').readAsStringSync(),
  ),
  Doc.uiAudit: findings(
    File('docs/ui-backend-audit-2026-11-22.md').readAsStringSync(),
  ),
};
