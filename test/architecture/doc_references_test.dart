import 'package:flutter_test/flutter_test.dart';

import 'doc_references.dart';
import 'layer_rules.dart' show readLib;

/// TC-ARCH-019 … -021 (docs/test-cases/18-architecture.md): every document
/// a comment in `lib/` cites, by section or finding, exists (production
/// audit P-11). Comments once cited `final.md` v1.6's numbering
/// (docs/archive/app-architecture-1.6.md), which the current `final.md`
/// no longer has.
void main() {
  // Sample documents for the edge and worst cases.
  final sample = <Doc, Set<String>>{
    Doc.finalMd: {'4', '9', '13', '13.1', '13.8'},
    Doc.apiGuide: {'3', '3.4', '4', '4.3', '4.4', '4.5', '4.6', '5'},
    Doc.buildGuide: {'4', '4.9'},
    Doc.uiAudit: {'4.2', '7.1'},
  };
  List<String> check(String comment) => [
    for (final b in badReferences({'f.dart': comment}, sample)) b.problem,
  ];

  test('TC-ARCH-019 every citation in lib/ resolves', () {
    final bad = badReferences(readLib('lib'), readSections());
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
}
