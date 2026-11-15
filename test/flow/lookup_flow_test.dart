import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: LOOK, BULK, ERR, SEC (docs/test-cases/04-lookup.md,
/// 05-bulk.md, 10-errors-network.md, 11-security.md).
void main() {
  Future<void> lookUpSerial(FlowApp app, String serial) async {
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
  }

  Future<void> openTile(FlowApp app, Key key) async {
    await app.tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -3000),
    );
    await app.tester.pumpAndSettle();
    await app.tap(find.byKey(key));
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
        find.text('Verify another item'),
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

    testWidgets('TC-LOOK-013 a hidden code is cleared after use; '
        'TC-SEC-004 it never appears in a route', (tester) async {
      final app = await startApp(tester);
      await app.tapText('Hidden code');
      await app.enter(const Key('verify.input'), '4815 1623 4200');
      await app.tap(find.byKey(const Key('verify.submit')));

      expect(find.text('Genuine product'), findsOneWidget);
      expect(app.backend.sent('POST', 'lookups').single.data, {
        'way': 'hidden_code',
        'value': '481516234200',
      });
      final location = GoRouter.of(
        tester.element(find.text('Genuine product')),
      ).routeInformationProvider.value.uri.toString();
      expect(location, isNot(contains('4815')));

      await app.tapText('Verify another item');
      final field = tester.widget<TextField>(
        find.byKey(const Key('verify.input')),
      );
      expect(field.controller!.text, isEmpty);
    });
  });

  group('BULK', () {
    testWidgets('TC-BULK-001 bulk lookup only with item:bulk_lookup', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.fieldInspector);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify.tool.bulk')), findsOneWidget);

      await startApp(tester, profile: Roles.retailSeller);
      expect(find.byKey(const Key('verify.tool.bulk')), findsNothing);
    });

    testWidgets('TC-BULK-006 remove an item and clear the list', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.bulk'));
      for (final serial in ['1000001', '1000002']) {
        await app.enter(const Key('bulk.input'), serial);
        await app.tap(find.byKey(const Key('bulk.add')));
      }
      expect(find.text('2 / 500 items'), findsWidgets);

      await app.tap(find.byTooltip('Remove').first);
      expect(find.text('1 / 500 items'), findsWidgets);

      await app.tapText('Clear list');
      expect(
        find.text(
          'Scan QR codes or type serials and hidden codes to build the list.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-BULK-010 open a result row; TC-BULK-014 new list', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.bulk'));
      for (final serial in ['1000001', '1000002', '1000003']) {
        await app.enter(const Key('bulk.input'), serial);
        await app.tap(find.byKey(const Key('bulk.add')));
      }
      await app.tap(find.byKey(const Key('bulk.send')));
      expect(find.text('Summary'), findsOneWidget);
      expect(
        (app.backend.sent('POST', 'lookups/bulk').single.data
            as Map<String, dynamic>)['items'],
        hasLength(3),
      );

      await app.tapText('1. 1000001');
      expect(find.text('Genuine product'), findsOneWidget);
      await app.tapText('Verify another item');

      await app.tapText('New list');
      expect(find.text('0 / 500 items'), findsWidgets);
    });

    testWidgets('TC-BULK-008 a results count that differs is never shown', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.bulk'));
      await app.enter(const Key('bulk.input'), '1000001');
      await app.tap(find.byKey(const Key('bulk.add')));
      await app.tap(find.byKey(const Key('bulk.send')));

      expect(find.text('Summary'), findsNothing);
      expect(find.text('Something went wrong. Try again.'), findsOneWidget);
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
        find.text('Unable to verify. Check the connection and try again.'),
        findsOneWidget,
      );
    });
  });
}
