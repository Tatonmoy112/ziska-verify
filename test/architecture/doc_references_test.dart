import 'package:flutter_test/flutter_test.dart';

import 'doc_references.dart';

/// TC-ARCH-019 … -021 and -023 … -025 (docs/test-cases/18-architecture.md):
/// every document a comment cites, by section or finding, exists, in the
/// code, the tests, the tools and the Android and iOS projects (production
/// audit P-11, P-16). Comments once cited `final.md` v1.6's numbering
/// (docs/archive/app-architecture-1.6.md), which the current `final.md`
/// no longer has.
void main() {
  // Sample documents for the edge and worst cases.
  final sample = <Doc, Set<String>>{
    Doc.finalMd: {'4', '9', '13', '13.1', '13.8'},
    Doc.apiGuide: {'3', '3.4', '4', '4.3', '4.4', '4.5', '4.6', '5'},
    Doc.buildGuide: {'4', '4.9'},
    Doc.testPlan: {'7'},
    Doc.uiAudit: {'4.2', '7.1'},
  };
  List<String> check(String comment) => [
    for (final b in badReferences({'f.dart': comment}, sample)) b.problem,
  ];

  /// The problems of one file, each with its line: [lines] joined by
  /// line breaks.
  List<String> checkFile(String path, List<String> lines) => [
    for (final b in badReferences({path: lines.join('\n')}, sample))
      '${b.line}: ${b.problem}',
  ];

  test('TC-ARCH-019 every citation resolves: lib/, test/, tool/, android/, '
      'ios/', () {
    final sources = readSources();
    expect(sources.keys, contains('lib/main.dart'));
    expect(sources.keys, contains('android/app/src/main/AndroidManifest.xml'));
    expect(sources.keys.where((p) => p.startsWith('test/')), isNotEmpty);
    final bad = badReferences(sources, readSections());
    expect(
      bad.map((b) => '$b'),
      isEmpty,
      reason:
          'Cite the current section: final.md §N, guide §N, '
          'build guide §N, UI audit 2026-11-22, N.N',
    );
  });

  group('TC-ARCH-020 normal and edge: each kind of citation', () {
    test('each document, each form', () {
      expect(check('/// (final.md §9; Section 13.1)'), isEmpty);
      expect(check('/// (final.md Sections 4, 13.8)'), isEmpty);
      expect(check('// refresh pass (guide §3.4)'), isEmpty);
      expect(check('/// (app API guide §4.3)'), isEmpty);
      expect(check('/// (app build guide §4.9)'), isEmpty);
      expect(check('/// (UI audit 2026-11-22, 4.2)'), isEmpty);
    });

    test('a bare § belongs to the last document named on its line', () {
      expect(check('/// (final.md §4, §9)'), isEmpty);
      expect(check('/// UTC days (guide §4.5 and §5)'), isEmpty);
      expect(check('/// §13.8, then guide §3.4 and §5'), isEmpty);
    });

    test('lists and ranges cite every number', () {
      expect(check('/// (guide §4.3–4.6)'), isEmpty);
      expect(check('/// (final.md Sections 4, 9, and 13.1)'), isEmpty);
      expect(check('/// (guide §4.3–4.7)'), ['app API guide has no §4.7']);
    });

    test('only comments count', () {
      expect(check("final text = 'Section 99';"), isEmpty);
      expect(check("final t = 'x'; // Section 13.1"), isEmpty);
    });
  });

  group('TC-ARCH-021 worst: a citation that leads nowhere', () {
    test('a section of an old numbering', () {
      expect(check('/// (final.md Section 9.4)'), ['final.md has no §9.4']);
      expect(check('/// (Section 13.1.6)'), ['final.md has no §13.1.6']);
      expect(check('/// (final.md Sections 4.2, 5.9)'), [
        'final.md has no §4.2',
        'final.md has no §5.9',
      ]);
    });

    test('a wrong document: the number exists in another one', () {
      expect(check('/// (guide §13.8)'), ['app API guide has no §13.8']);
      expect(check('/// (build guide §5)'), ['app build guide has no §5']);
    });

    test('an audit finding without its audit, or one it does not have', () {
      const unnamed =
          'an audit finding without its audit: write '
          '"UI audit 2026-11-22, N.N"';
      expect(check('/// (audit 4.2)'), [unnamed]);
      expect(check('/// (UI audit 2026-11-22, 9.9)'), [
        'UI audit 2026-11-22 has no finding 9.9',
      ]);
    });

    test('the file and line are named', () {
      final bad = badReferences(
        {'lib/a.dart': 'void a() {}\n/// (final.md Section 9.4)'},
        sample,
      );
      expect('${bad.single}', 'lib/a.dart:2: final.md has no §9.4');
    });
  });

  group('TC-ARCH-023 normal: a citation over lines, in any file', () {
    test('a document at the end of a line, its number on the next', () {
      expect(
        checkFile('f.dart', ['/// kept in memory (final.md', '/// §13.1).']),
        isEmpty,
      );
      expect(
        checkFile('f.dart', ['/// (final.md Sections', '/// 4, 9).']),
        isEmpty,
      );
      expect(checkFile('f.dart', ['/// (guide §4.3,', '/// §4.5)']), isEmpty);
    });

    test('XML and Kotlin comments are read', () {
      expect(
        checkFile('a.xml', ['<!-- HTTPS only (final.md §9). -->']),
        isEmpty,
      );
      expect(
        checkFile('b.kts', ['// Three flavors (final.md §13.1).']),
        isEmpty,
      );
      expect(
        checkFile('c.xml', [
          '<x/>',
          '<!-- one',
          '  two (final.md',
          '  §4). -->',
        ]),
        isEmpty,
      );
    });
  });

  group('TC-ARCH-024 edge: what is not a citation', () {
    test('a // inside a string is no comment', () {
      expect(
        checkFile('f.dart', ["final s = '/// (final.md Section 9.4)';"]),
        isEmpty,
      );
      expect(
        checkFile('f.dart', ["final u = 'https://x/Section 9.4';"]),
        isEmpty,
      );
      expect(
        checkFile('f.dart', ['final s = "a // b"; // (final.md §13.8)']),
        isEmpty,
      );
    });

    test('an example between backticks', () {
      expect(
        checkFile('f.dart', ['/// a list (`Sections 7.2, 9.4`) is read']),
        isEmpty,
      );
    });

    test('the test plan is its own document', () {
      expect(
        checkFile('f.dart', ['/// The roles (test plan Section 7).']),
        isEmpty,
      );
      expect(checkFile('f.dart', ['/// (test plan Section 8)']), [
        '1: test plan has no §8',
      ]);
    });

    test('a line that ends a sentence does not run on', () {
      expect(
        checkFile('f.dart', ['/// See the guide.', '/// 99 bottles (§4).']),
        isEmpty,
      );
    });
  });

  group('TC-ARCH-025 worst: a split citation that leads nowhere', () {
    test('reported at the line where its Section or § stands', () {
      expect(
        checkFile('f.dart', [
          'void f() {}',
          '/// stored (final.md Section',
          '/// 12.1).',
        ]),
        ['2: final.md has no §12.1'],
      );
      expect(
        checkFile('f.dart', ['/// (final.md Sections', '/// 10.4, 10.6)']),
        ['1: final.md has no §10.4', '1: final.md has no §10.6'],
      );
    });

    test('in an XML comment over three lines', () {
      expect(
        checkFile('a.xml', [
          '<!-- kept on this',
          '     phone (final.md',
          '     Section 12.1). -->',
        ]),
        ['3: final.md has no §12.1'],
      );
    });
  });
}
