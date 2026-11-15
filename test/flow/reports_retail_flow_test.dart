import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../fakes/roles.dart';
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

  group('RTL', () {
    testWidgets('TC-RTL-001 retail users only with retail_user:add', (
      tester,
    ) async {
      await startApp(tester, profile: Roles.supervisor);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify.tool.retailUsers')), findsOneWidget);

      await startApp(tester, profile: Roles.fieldInspector);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify.tool.retailUsers')), findsNothing);
    });

    testWidgets('TC-RTL-002 list and search', (tester) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      await openTile(app, const Key('verify.tool.retailUsers'));
      expect(find.text('Rahim Store'), findsOneWidget);
      expect(find.text('ra***@gmail.com'), findsOneWidget);

      await app.enter(const Key('retailUsers.search'), 'rahim');
      await app.settleAfter(const Duration(milliseconds: 500));
      expect(
        app.backend.sent('GET', 'retail-users').last.queryParameters['search'],
        'rahim',
      );
    });

    testWidgets('TC-RTL-009 email a new first password', (tester) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      await openTile(app, const Key('verify.tool.retailUsers'));
      await app.tap(find.byIcon(LucideIcons.ellipsisVertical));
      await app.tapText('Email a new first password');
      await app.tapText('Email it');

      expect(
        find.text('A new first password was emailed to Rahim Store.'),
        findsOneWidget,
      );
      expect(
        app.backend.requests.where(
          (r) =>
              r.path ==
              'retail-users/9d2e7c1b-3a4f-4e5d-8b6c-1f2a3b4c5d6e/password',
        ),
        hasLength(1),
      );
    });

    testWidgets('add a retail user with a role (RTL-004…008 on screen)', (
      tester,
    ) async {
      final app = await startApp(tester, profile: Roles.supervisor);
      await openTile(app, const Key('verify.tool.retailUsers'));
      await app.tap(find.byKey(const Key('retailUsers.add')));

      await app.enter(const Key('addRetail.name'), 'Rahim Store');
      await app.enter(const Key('addRetail.email'), 'rahim.store@gmail.com');
      await app.tap(find.byKey(const Key('addRetail.role')));
      await app.tapText('Retail seller');
      await app.enter(const Key('addRetail.password'), '1234567890');
      await app.tap(find.byKey(const Key('addRetail.submit')));

      expect(find.text('Rahim Store was added'), findsOneWidget);
      expect(
        find.text('The login details were emailed to rahim.store@gmail.com.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('addRetail.passwordOnce')), findsNothing);
      expect(app.backend.sent('POST', 'retail-users').single.data, {
        'name': 'Rahim Store',
        'email': 'rahim.store@gmail.com',
        'role_id': 7,
        'password': '1234567890',
        'send_email': true,
      });
    });
  });
}
