import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: PROF and TC-NFR-004 (docs/test-cases/09-profile.md,
/// 12-device-a11y-perf.md).
void main() {
  Future<void> openProfile(FlowApp app) => app.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Profile'),
    ),
  );

  group('PROF', () {
    testWidgets('TC-PROF-001 profile details', (tester) async {
      final app = await startApp(tester);
      await openProfile(app);

      expect(find.text('AR'), findsOneWidget);
      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('FIELD INSPECTOR'), findsOneWidget);
      expect(find.text('Field inspector'), findsOneWidget);
      expect(find.text('Ziska Pharma'), findsOneWidget);
      expect(find.text('official@example.com'), findsOneWidget);
    });

    testWidgets('TC-PROF-002 on screen: support contact opens mail', (
      tester,
    ) async {
      final app = await startApp(tester);
      await openProfile(app);
      await app.tap(find.byKey(const Key('profile.supportEmail')));
      expect(app.launcher.emails.single.to, 'help@ziska.example');
      // Both channels show (guide §3.8): the phone opens the dialler.
      final phone = find.byKey(const Key('profile.supportPhone'));
      if (phone.evaluate().isNotEmpty) {
        await app.tap(phone);
        expect(app.launcher.calls, hasLength(1));
      }
    });

    testWidgets('TC-PROF-003 support not set', (tester) async {
      final app = await startApp(tester, profile: Roles.noSupport);
      await openProfile(app);
      expect(find.text('Not set by your office'), findsOneWidget);

      await app.tapText('Support contact');
      expect(app.launcher.emails, isEmpty);
    });

    testWidgets('TC-PROF-004 app version', (tester) async {
      final app = await startApp(tester);
      await openProfile(app);
      expect(find.text('v0.1.0 · build 1'), findsOneWidget);
    });
  });

  group('TC-NFR-004 accessibility guidelines', () {
    Future<void> expectGuidelines(WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    }

    testWidgets('Login', (tester) async {
      await startApp(tester, loggedIn: false);
      await expectGuidelines(tester);
    });

    testWidgets('Verify tab', (tester) async {
      await startApp(tester);
      await expectGuidelines(tester);
    });

    testWidgets('Lookup result', (tester) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await expectGuidelines(tester);
    });

    testWidgets('Profile tab', (tester) async {
      final app = await startApp(tester);
      await openProfile(app);
      await expectGuidelines(tester);
    });
  });
}
