import 'dart:io';

/// The documents the code's comments cite, each with the section or
/// finding numbers it has (production audit P-11, P-16).
enum Doc {
  finalMd('final.md'),
  apiGuide('app API guide'),
  buildGuide('app build guide'),
  testPlan('test plan'),
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
  '(app build guide|build guide|app API guide|API guide|guide|test plan|'
  r'final\.md|UI audit 2026-11-22,?|audit)'
  r'|(§ ?|Sections? )(\d+(?:\.\d+)*)'
  r'((?:(?:,? and |, |–|-)\d+(?:\.\d+)*)*)',
);
final _number = RegExp(r'\d+(?:\.\d+)*');
final _auditNumber = RegExp(r'^\s*(\d+\.\d+)');

/// A comment line that stops in the middle of a citation: it goes on, as
/// one, on the next line.
final _unfinished = RegExp(
  r'(final\.md|guide|test plan|audit|audit 2026-11-22,|Sections?|§|\d,|'
  r' and)\s*\(?$',
);

/// One comment line: where it is, and its text without the comment marks.
class _Line {
  _Line(this.number, this.text);

  final int number;
  String text;
}

/// The comment lines of [source], by the kind of file [path] names: `//`
/// comments in Dart, Kotlin and Swift (never a `//` inside a string), and
/// `<!-- -->` comments in XML.
List<_Line> _commentLines(String path, String source) {
  final lines = source.split('\n');
  if (path.endsWith('.xml') || path.endsWith('.plist')) {
    final out = <_Line>[];
    for (final m in RegExp(r'<!--([\s\S]*?)-->').allMatches(source)) {
      final first = '\n'.allMatches(source.substring(0, m.start)).length;
      final parts = m.group(1)!.split('\n');
      for (var i = 0; i < parts.length; i++) {
        out.add(_Line(first + i + 1, parts[i]));
      }
    }
    return out;
  }
  return [
    for (var i = 0; i < lines.length; i++)
      if (_commentStart(lines[i]) case final at?)
        _Line(i + 1, lines[i].substring(at).replaceFirst(RegExp('^/+'), '')),
  ];
}

/// Where the `//` comment of [line] starts, or `null`: a `//` inside a
/// string (`'https://…'`, a sample comment in a test) is not one.
int? _commentStart(String line) {
  String? quote;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (quote != null) {
      if (c == r'\') {
        i++;
      } else if (c == quote) {
        quote = null;
      }
    } else if (c == "'" || c == '"') {
      quote = c;
    } else if (c == '/' && i + 1 < line.length && line[i + 1] == '/') {
      return i;
    }
  }
  return null;
}

/// Checks every citation in the comments of [sources] (path → text)
/// against [sections]: for each document, the numbers it has.
///
/// In a comment, `§N` or `Section N` belongs to the last document named
/// before it on the same line, and to `final.md` when none is. A line that
/// stops in the middle of a citation goes on with the next one. A list or
/// a range cites every number in it. Text between backticks is an example,
/// not a citation. An audit's finding must name its audit
/// (`UI audit 2026-11-22, 4.2`).
List<BadReference> badReferences(
  Map<String, String> sources,
  Map<Doc, Set<String>> sections,
) {
  final bad = <BadReference>[];
  for (final MapEntry(key: file, value: text) in sources.entries) {
    final lines = _commentLines(file, text);
    // Lines joined where a citation runs on, each part with its line.
    final logical = <List<_Line>>[];
    for (var i = 0; i < lines.length; i++) {
      final previous = logical.isEmpty ? null : logical.last.last;
      if (previous != null &&
          previous.number + 1 == lines[i].number &&
          _unfinished.hasMatch(_withoutCode(previous.text))) {
        logical.last.add(lines[i]);
      } else {
        logical.add([lines[i]]);
      }
    }
    for (final parts in logical) {
      final starts = <int>[];
      final buffer = StringBuffer();
      for (final p in parts) {
        starts.add(buffer.length);
        buffer
          ..write(_withoutCode(p.text).trim())
          ..write(' ');
      }
      final comment = buffer.toString();
      int lineAt(int offset) {
        var k = 0;
        while (k + 1 < starts.length && starts[k + 1] <= offset) {
          k++;
        }
        return parts[k].number;
      }

      var doc = Doc.finalMd;
      for (final m in _token.allMatches(comment)) {
        final name = m.group(1);
        final at = lineAt(m.start);
        if (name != null) {
          if (name.startsWith('UI audit')) {
            doc = Doc.uiAudit;
            final finding = _auditNumber.firstMatch(comment.substring(m.end));
            if (finding != null &&
                !sections[Doc.uiAudit]!.contains(finding.group(1))) {
              bad.add(
                BadReference(
                  file,
                  at,
                  '${Doc.uiAudit.label} has no finding ${finding.group(1)}',
                ),
              );
            }
          } else if (name == 'audit') {
            if (_auditNumber.hasMatch(comment.substring(m.end))) {
              bad.add(
                BadReference(
                  file,
                  at,
                  'an audit finding without its audit: write '
                  '"${Doc.uiAudit.label}, N.N"',
                ),
              );
            }
          } else if (name.contains('build guide')) {
            doc = Doc.buildGuide;
          } else if (name.contains('guide')) {
            doc = Doc.apiGuide;
          } else if (name == 'test plan') {
            doc = Doc.testPlan;
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
            bad.add(BadReference(file, at, '${doc.label} has no §$n'));
          }
        }
      }
    }
  }
  return bad;
}

/// [text] with its code spans (`…`) blanked, keeping its length.
String _withoutCode(String text) =>
    text.replaceAllMapped(RegExp('`[^`]*`'), (m) => ' ' * m[0]!.length);

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

/// The sections of the cited documents, read from the repository.
Map<Doc, Set<String>> readSections() => {
  Doc.finalMd: headings(File('final.md').readAsStringSync()),
  Doc.apiGuide: headings(
    File('docs/protectb-api/app-api-guide.md').readAsStringSync(),
  ),
  Doc.buildGuide: headings(
    File('docs/protectb-api/app-build-guide.md').readAsStringSync(),
  ),
  Doc.testPlan: headings(File('docs/test-plan.md').readAsStringSync()),
  Doc.uiAudit: findings(
    File('docs/ui-backend-audit-2026-11-22.md').readAsStringSync(),
  ),
};

/// Every file whose comments may cite the documents: the code, the tests,
/// the tools, and the Android and iOS projects (build output left out).
Map<String, String> readSources() {
  const skip = [
    '/build/',
    '/.gradle/',
    '/Pods/',
    '/.dart_tool/',
    '/.symlinks/',
    '/ephemeral/',
    '/generated/',
  ];
  const kinds = ['.dart', '.kt', '.kts', '.swift', '.xml', '.plist'];
  final out = <String, String>{};
  for (final root in ['lib', 'test', 'tool', 'android', 'ios']) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (skip.any('/$path'.contains)) continue;
      if (!kinds.any(path.endsWith)) continue;
      if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) continue;
      out[path] = f.readAsStringSync();
    }
  }
  return out;
}
