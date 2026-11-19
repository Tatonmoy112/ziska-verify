import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: LOOK, BULK, ERR, SEC (docs/test-cases/04-lookup.md,
/// 05-bulk.md, 10-errors-network.md, 11-security.md).
void main() {
  Future<void> lookUpSerial(FlowApp app, String serial) async {
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
  }

  group('LOOK', () {
    testWidgets('TC-LOOK-001 the formats load', (tester) async {
      final app = await startApp(tester);
      expect(find.text('Up to 19 digits'), findsOneWidget);
      expect(app.backend.sent('GET', 'formats'), hasLength(1));
    });

    testWidgets('TC-LOOK-006 a valid result shows the item and reference', (
      tester,
    ) async {
      final app = await startApp(tester);
      await lookUpSerial(app, '1000001');

      expect(find.text('Genuine product'), findsOneWidget);
      expect(find.text('Paracetamol 500'), findsOneWidget);
      expect(find.text('*****7K2'), findsOneWidget);
      expect(find.text('B-1042'), findsOneWidget);
      expect(find.text('MA-2026-000123'), findsOneWidget);
      expect(app.backend.sent('POST', 'lookups').single.data, {
        'way': 'serial',
        'value': '1000001',
      });
    });

    testWidgets('TC-LOOK-010 the reference can be copied', (tester) async {
      final app = await startApp(tester);
      await lookUpSerial(app, '1000001');
      await app.tap(find.byTooltip('Copy reference number'));
      expect(find.text('Copied'), findsWidgets);
    });

    testWidgets('TC-LOOK-011 the Report button only with incident:report', (
      tester,
    ) async {
      // The actions follow the cards: scrolled to the end first.
      Future<void> toEnd() => tester.scrollUntilVisible(
        find.text('Check another item'),
        300,
        scrollable: find.byType(Scrollable).last,
      );

      var app = await startApp(tester, profile: Roles.fieldInspector);
      await lookUpSerial(app, '1000001');
      await toEnd();
      expect(find.byKey(const Key('result.report')), findsOneWidget);

      app = await startApp(tester, profile: Roles.auditor);
      await lookUpSerial(app, '1000001');
      expect(find.text('Genuine product'), findsOneWidget);
      await toEnd();
      expect(find.byKey(const Key('result.report')), findsNothing);
    });
  });

  group('ERR', () {
    testWidgets('TC-ERR-003 no connection while verifying', (tester) async {
      final app = await startApp(
        tester,
        overrides: {'POST lookups': offline()},
      );
      await lookUpSerial(app, '1000001');
      expect(
        find.text('Unable to check. Check the connection and try again.'),
        findsOneWidget,
      );
    });
  });
}
