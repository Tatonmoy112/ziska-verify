import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _screens = 'lib/features/verification/presentation/screens';
const _widgets = 'lib/features/verification/presentation/widgets';

/// The widgets split out of the two largest screens (production audit
/// P-37).
const _split = [
  'scan_camera_area.dart',
  'session_live_panel.dart',
  'session_rows_sliver.dart',
  'session_scan_row.dart',
  'session_summary_view.dart',
  'session_bottom_bar.dart',
  'check_header.dart',
  'serial_lookup_form.dart',
  'tools_section.dart',
];

/// The lines of the `Widget build(` method in [source], from its first line
/// to the brace that closes it.
int _buildLength(String source) {
  final lines = source.split('\n');
  final start = lines.indexWhere((l) => l.contains('Widget build('));
  var depth = 0;
  for (var i = start; i < lines.length; i++) {
    depth += '{'.allMatches(lines[i]).length - '}'.allMatches(lines[i]).length;
    if (i > start && depth == 0) return i - start + 1;
  }
  return lines.length - start;
}

/// TC-ARCH-053 … -055 (docs/test-cases/18-architecture.md): the scanner
/// screen and the check tab are split into widgets that take values and
/// callbacks, with no change in what they show or do (P-37).
void main() {
  group('TC-ARCH-053 normal: each screen holds itself and its state', () {
    for (final (file, maxLines) in [
      ('scan_session_screen.dart', 400),
      ('verify_screen.dart', 450),
    ]) {
      test(file, () {
        final source = File('$_screens/$file').readAsStringSync();
        final classes = RegExp(
          r'^(?:final |abstract )?class (\w+)',
          multiLine: true,
        ).allMatches(source).map((m) => m.group(1)).toList();
        expect(classes, hasLength(2), reason: '$classes');
        expect(
          source.split('\n').length,
          lessThanOrEqualTo(maxLines),
          reason: 'lines',
        );
      });
    }
  });

  group('TC-ARCH-054 edge: a build method that can be read', () {
    for (final file in ['scan_session_screen.dart', 'verify_screen.dart']) {
      test(file, () {
        final source = File('$_screens/$file').readAsStringSync();
        expect(_buildLength(source), lessThanOrEqualTo(150));
      });
    }
  });

  group('TC-ARCH-055 worst: the split widgets hold no state', () {
    for (final file in _split) {
      test(file, () {
        final widget = File('$_widgets/$file');
        expect(widget.existsSync(), isTrue);
        final source = widget.readAsStringSync();
        for (final reach in [
          'StatefulWidget',
          'setState(',
          'context.read',
          'context.watch',
          'BlocProvider.of',
          'BlocBuilder',
          'BlocConsumer',
        ]) {
          expect(source, isNot(contains(reach)), reason: reach);
        }
      });
    }
  });
}
