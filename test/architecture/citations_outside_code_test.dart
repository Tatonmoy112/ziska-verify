import 'package:flutter_test/flutter_test.dart';

import 'doc_references.dart';

/// TC-ARCH-101 … -103 (docs/test-cases/18-architecture.md): the citations
/// in the files beside the code resolve too: the root YAML files, CI,
/// `README.md` and `AGENTS.md` (production audit P-54).
void main() {
  /// Sections the samples may cite.
  const sample = {
    Doc.finalMd: {'3', '12', '16'},
    Doc.apiGuide: {'4', '4.3'},
    Doc.buildGuide: {'4'},
    Doc.testPlan: {'12'},
    Doc.uiAudit: {'4.2'},
  };
  List<String> check(String path, String text) => [
    for (final b in badReferences({path: text}, sample))
      '${b.line}: ${b.problem}',
  ];

  group('TC-ARCH-101 normal: the files beside the code', () {
    test('are read, and their citations resolve', () {
      final sources = readSources();
      for (final f in [
        'pubspec.yaml',
        'analysis_options.yaml',
        'l10n.yaml',
        '.github/workflows/ci.yml',
        'README.md',
        'AGENTS.md',
      ]) {
        expect(sources.keys, contains(f), reason: f);
      }
      final outside = {
        for (final MapEntry(:key, :value) in sources.entries)
          if (!key.contains('/') || key.startsWith('.github/')) key: value,
      };
      expect(
        badReferences(outside, readSections()).map((b) => '$b'),
        isEmpty,
        reason: 'Cite the current section, or none.',
      );
    });
  });

  group('TC-ARCH-102 edge: how each kind is read', () {
    test('a YAML comment, but not a # inside a value', () {
      expect(
        check(
          'pubspec.yaml',
          'color: "#FFFFFF" # final.md §16\n'
              "name: 'a # final.md §99'\n",
        ),
        isEmpty,
      );
    });

    test('a Markdown line, tables too; "Guide" written with a capital', () {
      expect(
        check(
          'README.md',
          '| `mock` | Guide §4.3 |\n'
              'See final.md §3 and the test plan §12.\n',
        ),
        isEmpty,
      );
    });

    test('a number right after a document, without § or "Section"', () {
      expect(check('analysis_options.yaml', '# (final.md 3)'), isEmpty);
      expect(
        check('analysis_options.yaml', '# (final.md 12; guide 4.3)'),
        isEmpty,
      );
      // A date after a document is not a section.
      expect(check('AGENTS.md', 'final.md 2026-11-24 says so.'), isEmpty);
    });
  });

  group('TC-ARCH-103 worst: a stale section in each kind', () {
    test('is reported with its line', () {
      expect(check('l10n.yaml', 'a: b\n# (final.md Section 20.3)\n'), [
        '2: final.md has no §20.3',
      ]);
      expect(check('.github/workflows/ci.yml', '  # (final.md §12.1\n'), [
        '1: final.md has no §12.1',
      ]);
      expect(check('analysis_options.yaml', '# (final.md 5.1)'), [
        '1: final.md has no §5.1',
      ]);
      expect(check('AGENTS.md', 'Intro.\n\nPer final.md §7.2, do it.\n'), [
        '3: final.md has no §7.2',
      ]);
    });

    test('a Markdown code span is an example, not a citation', () {
      expect(check('README.md', 'Write `final.md §99` like this.'), isEmpty);
    });
  });
}
