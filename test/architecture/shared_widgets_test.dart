import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/camera_problem_view.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/widgets/button_pair.dart';
import 'package:ziska_verify/shared/widgets/icon_action_tile.dart';
import 'package:ziska_verify/shared/widgets/picker_sheet_frame.dart';
import 'package:ziska_verify/shared/widgets/tab_visibility.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double scale = 1}) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: app!,
        ),
        home: Scaffold(body: child),
      ),
    );

/// Records what [TabVisibility] reports.
class _Tab extends StatefulWidget {
  const _Tab(this.log);
  final List<String> log;
  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with TabVisibility {
  @override
  void onTabShown({required bool firstTime}) =>
      widget.log.add(firstTime ? 'shown first' : 'shown again');

  @override
  void onTabHidden() => widget.log.add('hidden');

  @override
  Widget build(BuildContext context) => const SizedBox();
}

/// TC-ARCH-059 … -061 (docs/test-cases/18-architecture.md): widgets that
/// were written twice or more, written once (production audit P-40).
void main() {
  group('TC-ARCH-059 normal: each shared widget does what its copies did', () {
    for (final layout in CameraProblemLayout.values) {
      testWidgets('the camera problem, $layout', (tester) async {
        var opened = 0;
        await _pump(
          tester,
          CameraProblemView(
            problem: ScannerProblem.permissionDenied,
            layout: layout,
            onOpenSettings: () => opened++,
          ),
        );
        expect(find.byIcon(LucideIcons.cameraOff), findsOneWidget);
        await tester.tap(find.text('Open settings'));
        expect(opened, 1);
        if (layout == CameraProblemLayout.fullScreen) {
          expect(find.byKey(const Key('scanner.problem')), findsOneWidget);
          expect(find.byKey(const Key('scanner.openSettings')), findsOneWidget);
        } else {
          expect(
            find.byKey(const Key('session.cameraProblem')),
            findsOneWidget,
          );
        }
      });
    }

    testWidgets('a tile with an action, and one without', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        Column(
          children: [
            IconActionTile(
              icon: LucideIcons.flag,
              title: 'Report',
              onTap: () => taps++,
            ),
            const IconActionTile(
              icon: LucideIcons.info,
              title: 'Version',
              subtitle: '1.0.0',
            ),
          ],
        ),
      );
      expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      await tester.tap(find.text('Report'));
      expect(taps, 1);
    });

    testWidgets('a tab shown, hidden, shown again', (tester) async {
      final log = <String>[];
      Widget tab({required bool on}) =>
          TickerMode(enabled: on, child: _Tab(log));
      await _pump(tester, tab(on: true));
      await _pump(tester, tab(on: false));
      await _pump(tester, tab(on: true));
      expect(log, ['shown first', 'hidden', 'shown again']);
    });
  });

  group('TC-ARCH-060 edge: at a large font, and with the keyboard up', () {
    const a = Text('Verify', key: Key('a'));
    const b = Text('Clear', key: Key('b'));

    testWidgets('side by side, 3 : 2', (tester) async {
      await _pump(
        tester,
        const ButtonPair(first: a, second: b, firstFlex: 3, secondFlex: 2),
      );
      final flex = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex);
      expect(flex, [3, 2]);
    });

    testWidgets('stacked at a large font, in the order asked', (tester) async {
      await _pump(
        tester,
        const ButtonPair(first: a, second: b, secondFirstWhenStacked: true),
        scale: 1.6,
      );
      expect(find.byType(Expanded), findsNothing);
      final top = tester.getTopLeft(find.byKey(const Key('b'))).dy;
      expect(top, lessThan(tester.getTopLeft(find.byKey(const Key('a'))).dy));
    });

    testWidgets('a picker stays above the keyboard', (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      // As in a bottom sheet: no Scaffold making room for the keyboard.
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: PickerSheetFrame(
              title: 'Pick a check',
              search: SizedBox(key: Key('search')),
              list: SizedBox(key: Key('list')),
            ),
          ),
        ),
      );
      final padding = tester.widget<Padding>(
        find.byKey(const Key('picker.frame')),
      );
      expect((padding.padding as EdgeInsets).bottom, greaterThan(0));
      expect(find.text('Pick a check'), findsOneWidget);
    });
  });

  group('TC-ARCH-061 worst: written once', () {
    String read(String p) => File(p).readAsStringSync();
    const v = 'lib/features/verification/presentation/widgets';

    test('no copy left behind', () {
      final all = [
        for (final f in Directory('lib').listSync(recursive: true))
          if (f is File && f.path.endsWith('.dart')) f,
      ];
      final ticker = [
        for (final f in all)
          if (f.readAsStringSync().contains('TickerMode.valuesOf'))
            f.path.replaceAll(r'\', '/'),
      ];
      expect(ticker, ['lib/shared/widgets/tab_visibility.dart']);
      for (final f in all) {
        final s = f.readAsStringSync();
        expect(s, isNot(contains('class _CameraProblem')), reason: f.path);
        expect(s, isNot(contains('class _ActionRow')), reason: f.path);
        expect(s, isNot(contains('class _ButtonPair')), reason: f.path);
      }
    });

    test('each former copy uses the shared one', () {
      for (final (path, uses) in [
        ('$v/scan_camera_area.dart', 'CameraProblemView('),
        ('$v/live_qr_camera.dart', 'CameraProblemView('),
        ('$v/tools_section.dart', 'IconActionTile('),
        (
          'lib/features/profile/presentation/screens/profile_screen.dart',
          'IconActionTile(',
        ),
        ('$v/serial_lookup_form.dart', 'ButtonPair('),
        ('$v/session_bottom_bar.dart', 'ButtonPair('),
        (
          'lib/features/history/presentation/widgets/check_picker_sheet.dart',
          'PickerSheetFrame(',
        ),
        (
          'lib/features/retail_users/presentation/widgets/retail_user_picker_sheet.dart',
          'PickerSheetFrame(',
        ),
      ]) {
        expect(read(path), contains(uses), reason: path);
      }
    });
  });
}
