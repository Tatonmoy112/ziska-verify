import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-ARCH-098 … -100 (docs/test-cases/18-architecture.md): no leftovers in
/// the tree, and the test cases name only what exists (production audit
/// P-53).
void main() {
  /// Every test-case document, by its path.
  final cases = {
    for (final f in Directory('docs/test-cases').listSync())
      if (f is File && f.path.endsWith('.md'))
        f.path.replaceAll(r'\', '/'): f.readAsLinesSync(),
  };

  /// Every file name under the code folders.
  final files = {
    for (final dir in ['lib', 'test', 'tool'])
      for (final f in Directory(dir).listSync(recursive: true))
        if (f is File) f.uri.pathSegments.last,
  };

  group('TC-ARCH-098 normal: no leftovers in the tree', () {
    test('no empty folder in lib/, test/ or tool/', () {
      final empty = [
        for (final dir in ['lib', 'test', 'tool'])
          for (final d in Directory(dir).listSync(recursive: true))
            if (d is Directory && d.listSync().isEmpty) d.path,
      ];
      expect(empty, isEmpty);
    });

    test("DevTools' own settings file is ignored", () {
      expect(
        File('.gitignore').readAsLinesSync(),
        contains('devtools_options.yaml'),
      );
    });
  });

  group('TC-ARCH-099 edge: the code files a test case names exist', () {
    test('every .dart file named, but one a case says is gone', () {
      final named = RegExp(r'`(?:[\w./]*/)?(\w+\.dart)`');
      final gone = RegExp(r'[Nn]o `(?:[\w./]*/)?(\w+\.dart)`');
      final missing = [
        for (final MapEntry(key: path, value: lines) in cases.entries)
          for (final (i, line) in lines.indexed)
            for (final m in named.allMatches(line))
              if (!files.contains(m.group(1)) &&
                  !gone.allMatches(line).any((g) => g.group(1) == m.group(1)))
                '$path:${i + 1}: ${m.group(1)}',
      ];
      expect(missing, isEmpty);
    });
  });

  group('TC-ARCH-100 worst: no case claims a screenshot that is not there', () {
    test('every screenshot a case names is in test/ui/goldens', () {
      final shots = {
        for (final f in Directory('test/ui/goldens').listSync())
          f.uri.pathSegments.last,
      };
      // Figma's own pictures (`figma/…png`) are references, not shots.
      final named = RegExp(r'(?<![\w/])(\w+\.png)');
      final missing = [
        for (final MapEntry(key: path, value: lines) in cases.entries)
          for (final (i, line) in lines.indexed)
            if (line.startsWith('| TC-'))
              for (final m in named.allMatches(
                line.replaceAll(
                  RegExp('figma/[^`|]*'),
                  '',
                ),
              ))
                if (!shots.contains(m.group(1)))
                  '$path:${i + 1}: ${m.group(1)}',
      ];
      expect(missing, isEmpty);
    });

    test('the retired UI cases are gone, and their IDs not reused', () {
      final ui = cases['docs/test-cases/15-ui.md']!.join('\n');
      for (final id in [
        '069', '070', '071', '101', '102', '103', '104', '105', '106', //
        '113', '121', '122', '123', '124', '125', '126', '127', '128',
        '129',
      ]) {
        expect(ui, isNot(contains('| TC-UI-$id |')), reason: 'TC-UI-$id');
      }
      expect(ui, contains('TC-UI-069'), reason: 'named as retired');
    });
  });
}
