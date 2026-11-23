import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-UI-186 (emulator run, finding F-8): in landscape the Check tab's navy
/// header scrolls away with the page, as at a large font, so the camera and
/// the serial field get the screen; in portrait it stays fixed.
void main() {
  final welcome = find.text('Welcome back,');

  /// How far the header moved when the page was dragged up.
  Future<double> headerMoves(WidgetTester tester) async {
    final before = tester.getTopLeft(welcome).dy;
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    if (welcome.evaluate().isEmpty) return double.infinity;
    return before - tester.getTopLeft(welcome).dy;
  }

  group('TC-UI-186 the Check tab header', () {
    testWidgets('landscape: scrolls away; the serial field is reached', (
      tester,
    ) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      // A phone on its side (844 × 390).
      tester.view.physicalSize = const Size(2532, 1170);
      await tester.pumpAndSettle();
      expect(await headerMoves(tester), greaterThan(100));

      await tester.scrollUntilVisible(
        find.byKey(const Key('verify.submit')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      final screen = tester.getSize(find.byType(Scaffold).first);
      final field = tester.getRect(find.byKey(const Key('verify.input')));
      expect(field.top, greaterThanOrEqualTo(0));
      expect(field.bottom, lessThan(screen.height));
      await app.enter(const Key('verify.input'), '1000001');
      expect(app.enabled(const Key('verify.submit')), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('portrait: stays fixed above the page', (tester) async {
      await startApp(tester, profile: Roles.supervisor);
      expect(await headerMoves(tester), 0);
    });
  });
}
