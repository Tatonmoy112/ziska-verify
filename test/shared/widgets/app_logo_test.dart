import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/shared/widgets/app_logo.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    double width = 140,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(child: AppLogo(width: width)),
        ),
      ),
    );
  }

  testWidgets('TC-UI-008 keeps its size at any system font size', (
    tester,
  ) async {
    await pump(tester);
    final normal = tester.getSize(find.byType(AppLogo));

    for (final scale in [1.3, 2.0, 3.0]) {
      await pump(tester, textScale: scale);
      expect(tester.takeException(), isNull, reason: 'font scale $scale');
      expect(
        tester.getSize(find.byType(AppLogo)),
        normal,
        reason: 'font scale $scale',
      );
    }
  });

  testWidgets('TC-UI-008 "ZISKA" stays on one line at the largest font', (
    tester,
  ) async {
    await pump(tester);
    final oneLine = tester.getSize(find.text('ZISKA')).height;

    await pump(tester, textScale: 3);
    expect(tester.getSize(find.text('ZISKA')).height, oneLine);
  });

  testWidgets('is drawn at the width asked for', (tester) async {
    await pump(tester, width: 120);
    expect(tester.getSize(find.byType(AppLogo)).width, 120);

    await pump(tester);
    expect(tester.getSize(find.byType(AppLogo)).width, 140);
  });

  testWidgets('TC-UI-009 screen readers read "Ziska Pharma" once', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(find.bySemanticsLabel('Ziska Pharma'), findsOneWidget);
    expect(find.bySemanticsLabel('ZISKA'), findsNothing);
    expect(find.bySemanticsLabel('PHARMA'), findsNothing);
    handle.dispose();
  });
}
