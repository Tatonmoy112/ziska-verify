import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 3 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): the profile and what its permissions open, on the
/// server's real answers replayed offline (TC-STG-015 … -017).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  /// The test account as the server sends it: a Supervisor with all four
  /// permissions, no support contact, and nothing recorded yet.
  Map<String, Answer> server() => {
    'GET me': real('me_200.json'),
    'GET formats': real('formats_200.json'),
    'GET checks': real('checks_empty_200.json'),
    'GET lookups/sessions': real('sessions_empty_200.json'),
    'GET incidents': real('incidents_empty_200.json'),
    'GET retail-users': real('retail_users_empty_200.json'),
  };

  testWidgets("TC-STG-015 Profile shows the server's profile", (
    tester,
  ) async {
    final app = await startApp(tester, overrides: server());
    await app.tap(tab('Profile'));
    expect(find.text('Test Official'), findsOneWidget);
    expect(find.text('Ziska-test'), findsOneWidget);
    expect(find.text('Supervisor'), findsWidgets);
    expect(find.text('official@example.com'), findsOneWidget);
    for (final permission in [
      'Check one item',
      'Check many items',
      'Own history',
      'Report incidents',
    ]) {
      expect(find.text(permission), findsOneWidget, reason: permission);
    }
    // The server sends support as an object with both values null.
    expect(find.text('Not set by your office'), findsOneWidget);
    // No password_change_pending in the answer: no reminder.
    expect(find.byKey(const Key('profile.passwordPending')), findsNothing);
  });

  testWidgets('TC-STG-016 a new account: the counts are 0, never blank', (
    tester,
  ) async {
    final app = await startApp(tester, overrides: server());
    await app.tap(tab('Profile'));
    final stats = find.byKey(const Key('profile.stats'));
    expect(stats, findsOneWidget);
    expect(
      find.descendant(of: stats, matching: find.text('0')),
      findsNWidgets(3),
    );
    expect(find.byKey(const Key('profile.stats.failed')), findsNothing);
  });

  testWidgets('TC-STG-017 every tab and tool the permissions open', (
    tester,
  ) async {
    final app = await startApp(tester, overrides: server());
    for (final name in ['Check', 'History', 'Profile']) {
      expect(tab(name), findsOneWidget, reason: name);
    }
    for (final key in [
      'verify.tool.bulk',
      'verify.tool.serials',
      'verify.tool.report',
      'verify.tool.myReports',
    ]) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
    // The empty lists, as a new account sees them.
    await app.tap(tab('History'));
    expect(tester.takeException(), isNull);
  });
}
