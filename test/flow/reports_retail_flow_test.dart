import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'harness.dart';

/// Flow tests: REP and RTL (docs/test-cases/07-reports.md, 08-retail-users.md).
void main() {
  Future<void> openTile(FlowApp app, Key key) async {
    await app.tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -3000),
    );
    await app.tester.pumpAndSettle();
    await app.tap(find.byKey(key));
  }

  group('REP', () {
    testWidgets('TC-REP-003 file a report with a photo', (tester) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.report'));

      await app.enter(const Key('report.note'), 'Seal is cut');
      await app.tap(find.byKey(const Key('report.addPhoto')));
      await app.tapText('Choose from gallery');
      await app.tap(find.byKey(const Key('report.submit')));

      expect(find.text('Report 1042 filed.'), findsOneWidget);
      expect(find.text('Photo 1'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(app.backend.sent('POST', 'incidents').single.data, {
        'note': 'Seal is cut',
      });
      final photo = app.backend.sent('POST', 'incidents/1042/photos').single;
      expect(photo.contentType, 'image/jpeg');
    });

    // Decision N3 (2026-11-17), SRS UC-08: the official optionally picks
    // one of their own checks; its ref goes as check_ref.
    testWidgets('TC-REP-051 link one of your own checks to the report', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.report'));
      await app.tap(find.byKey(const Key('report.check')));
      expect(find.text('Choose a check'), findsOneWidget);
      // The history example's first page: one check, MA-2026-000124.
      const ref = 'MA-2026-000124';
      await app.tap(find.text(ref).first);
      expect(find.text(ref), findsOneWidget);

      await app.enter(const Key('report.note'), 'Seal is cut');
      await app.tap(find.byKey(const Key('report.submit')));
      expect(app.backend.sent('POST', 'incidents').single.data, {
        'note': 'Seal is cut',
        'check_ref': ref,
      });
    });

    // TC-REP-067 (finding F-4): the check picker searches as History does;
    // part of a reference is not sent, and the list says what to type.
    testWidgets('TC-REP-067 the check picker: part of a reference not sent', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.report'));
      await app.tap(find.byKey(const Key('report.check')));
      final before = app.backend.sent('GET', 'checks').length;
      await app.enter(const Key('checkPicker.search'), 'MA-2026');
      await app.settleAfter(const Duration(milliseconds: 500));
      expect(app.backend.sent('GET', 'checks'), hasLength(before));
      expect(find.text('Not a serial or a reference number'), findsOneWidget);

      await app.enter(const Key('checkPicker.search'), 'MA-2026-000124');
      await app.settleAfter(const Duration(milliseconds: 500));
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['search'],
        'MA-2026-000124',
      );
    });

    // TC-REP-053 (SRS UC-09): a report opens in full.
    testWidgets('TC-REP-053 a report opens in full from My reports', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.myReports'));
      final row = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('reports.row.'),
      );
      expect(row, findsWidgets);
      await app.tap(row.first);
      expect(find.byKey(const Key('reports.detail')), findsOneWidget);
    });

    testWidgets('TC-REP-013 pick a retail user for the report', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.report'));
      await app.tap(find.byKey(const Key('report.retailUser')));

      await app.enter(const Key('picker.search'), 'rahim');
      await app.settleAfter(const Duration(milliseconds: 500));
      expect(find.text('ra***@gmail.com'), findsOneWidget);
      expect(
        app.backend.sent('GET', 'retail-users').last.queryParameters['search'],
        'rahim',
      );

      await app.tapText('Rahim Store');
      expect(find.text('Rahim Store'), findsOneWidget);

      await app.enter(const Key('report.note'), 'Selling outside the area');
      await app.tap(find.byKey(const Key('report.submit')));
      expect(
        (app.backend.sent('POST', 'incidents').single.data
            as Map<String, dynamic>)['retail_user_id'],
        '9d2e7c1b-3a4f-4e5d-8b6c-1f2a3b4c5d6e',
      );
    });

    testWidgets('TC-REP-014 a check link can be removed before filing', (
      tester,
    ) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await app.tap(find.byKey(const Key('result.report')));

      expect(find.text('MA-2026-000123'), findsOneWidget);
      await app.tap(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byIcon(LucideIcons.x),
        ),
      );
      expect(find.text('MA-2026-000123'), findsNothing);

      await app.enter(const Key('report.note'), 'Torn seal');
      await app.tap(find.byKey(const Key('report.submit')));
      expect(app.backend.sent('POST', 'incidents').single.data, {
        'note': 'Torn seal',
      });
    });

    testWidgets('TC-REP-001 on screen: a report from a result carries '
        'check_ref', (tester) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await app.tap(find.byKey(const Key('result.report')));
      await app.enter(const Key('report.note'), 'Fake label');
      await app.tap(find.byKey(const Key('report.submit')));

      expect(app.backend.sent('POST', 'incidents').single.data, {
        'note': 'Fake label',
        'check_ref': 'MA-2026-000123',
      });
    });

    testWidgets('TC-REP-017 My reports, then a new report', (tester) async {
      final app = await startApp(tester);
      await openTile(app, const Key('verify.tool.myReports'));

      expect(find.text('#1042'), findsOneWidget);
      expect(find.text('2 photos'), findsOneWidget);
      expect(find.text('Rahim Store'), findsOneWidget);
      final before = app.backend.sent('GET', 'incidents').length;

      await app.tap(find.byKey(const Key('reports.new')));
      expect(find.text('Report incident'), findsWidgets);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('#1042'), findsOneWidget);
      expect(
        app.backend.sent('GET', 'incidents').length,
        greaterThan(before),
      );
    });
  });
}
