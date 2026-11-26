import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_material.dart';

/// TC-ARCH-092 … -094 (docs/test-cases/18-architecture.md): every
/// screenshot is taken by a test and every recorded answer is replayed
/// (production audit P-51).
void main() {
  String name(FileSystemEntity f) => f.uri.pathSegments.last;

  group('TC-ARCH-092 normal: the real tests', () {
    final sources = [
      for (final f in Directory('test').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart')) f.readAsStringSync(),
    ];

    test('every screenshot is taken', () {
      final names = [
        for (final f in Directory('test/ui/goldens').listSync())
          if (f is File && f.path.endsWith('.png'))
            name(f).substring(0, name(f).length - 4),
      ];
      expect(names, isNotEmpty);
      expect(
        untakenScreenshots(names: names, sources: sources),
        isEmpty,
        reason: 'Delete the screenshot, or take it in a test.',
      );
    });

    test('every recorded answer is replayed', () {
      final files = [
        for (final f in Directory('test/fixtures/staging').listSync())
          if (f is File && f.path.endsWith('.json')) name(f),
      ];
      expect(files, isNotEmpty);
      expect(
        unloadedAnswers(files: files, sources: sources),
        isEmpty,
        reason: 'Replay the answer in a test, or delete it.',
      );
    });
  });

  group('TC-ARCH-093 edge: names a test builds', () {
    test('a prefix with an interpolated suffix, and a list it loops over', () {
      const sources = [
        r"""
for (final scale in [1.0, 2.0]) {
  final name = scale == 1 ? 'bn' : 'bn_font2x';
  await shot('${name}_login');
}
for (final (name, _) in [('screen_summary', 1.0)]) {
  await shot(name);
}
""",
      ];
      expect(
        untakenScreenshots(
          names: ['bn_login', 'bn_font2x_login', 'screen_summary'],
          sources: sources,
        ),
        isEmpty,
      );
    });

    test('an answer chosen by a switch', () {
      expect(
        unloadedAnswers(
          files: ['page1.json', 'page2.json'],
          sources: [
            "stagingScripted(cursor == null ? 'page1.json' : 'page2.json')",
          ],
        ),
        isEmpty,
      );
    });
  });

  group('TC-ARCH-094 worst: material nothing uses', () {
    test('a screenshot and an answer no test names', () {
      const sources = ["await shot('kept'); stagingAnswer('kept.json');"];
      expect(
        untakenScreenshots(names: ['kept', 'orphan'], sources: sources),
        ['orphan'],
      );
      expect(
        unloadedAnswers(files: ['kept.json', 'orphan.json'], sources: sources),
        ['orphan.json'],
      );
    });

    test('named only in a comment, or only as a suffix', () {
      const sources = [
        r"""
// shot('commented');
/* stagingAnswer('commented.json'); */
await shot('${name}_login');
""",
      ];
      expect(
        untakenScreenshots(names: ['commented', 'xx_login'], sources: sources),
        ['commented', 'xx_login'],
      );
      expect(
        unloadedAnswers(files: ['commented.json'], sources: sources),
        ['commented.json'],
      );
    });
  });
}
