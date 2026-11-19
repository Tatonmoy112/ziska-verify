import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// End-to-end journeys: one session per role across its features
/// (docs/test-cases/13-e2e-journeys.md).
void main() {
  const loginTitle = 'Login to Track & Trace';
  final input = find.byKey(const Key('verify.input'));

  /// Never the Login screen in the middle of a journey.
  void stillIn() => expect(find.text(loginTitle), findsNothing);

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  /// Back until the tab bar shows (Done closes a report onto the screen
  /// it was opened from).
  Future<void> home(WidgetTester tester) async {
    for (
      var i = 0;
      i < 5 && find.byType(NavigationBar).evaluate().isEmpty;
      i++
    ) {
      await back(tester);
    }
    expect(find.byType(NavigationBar), findsOneWidget);
  }

  Future<void> logOut(FlowApp app) async {
    await app.tap(tab('Profile'));
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log out'),
      ),
    );
    expect(find.text(loginTitle), findsOneWidget);
  }

  Future<void> lookUp(FlowApp app, String serial) async {
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
  }

  Future<void> fileReport(FlowApp app, String note) async {
    await app.enter(const Key('report.note'), note);
    final list = find
        .ancestor(
          of: find.byKey(const Key('report.note')),
          matching: find.byType(Scrollable),
        )
        .last;
    final position = app.tester.state<ScrollableState>(list).position;
    position.jumpTo(position.maxScrollExtent);
    await app.tester.pumpAndSettle();
    await app.tap(find.byKey(const Key('report.submit')));
  }

  Future<FlowApp> logIn(
    WidgetTester tester,
    Map<String, dynamic> profile,
  ) async {
    final app = await startApp(tester, profile: profile, loggedIn: false);
    await logInWithCode(app);
    stillIn();
    return app;
  }

  testWidgets("TC-E2E-001 a supervisor's day", (tester) async {
    final app = await logIn(tester, Roles.supervisor);

    await lookUp(app, '1000001');
    expect(find.text('Genuine product'), findsOneWidget);
    await app.tap(find.byKey(const Key('result.report')));
    await app.tap(find.byKey(const Key('report.addPhoto')));
    await app.tapText('Choose from gallery');
    await fileReport(app, 'Seal is cut');
    expect(find.text('Report 1042 filed.'), findsOneWidget);
    await app.tapText('Done');
    await home(tester);
    stillIn();

    await app.tap(find.byKey(const Key('verify.tool.myReports')));
    expect(find.textContaining('1042'), findsWidgets);
    await back(tester);

    await app.tap(tab('History'));
    await app.tap(find.byKey(const Key('history.filters')));
    await app.tapText('Apply');
    await app.enter(const Key('history.search'), '1000001');
    await app.settleAfter(const Duration(milliseconds: 500));
    expectTrackingLog('1000001');
    stillIn();

    await app.tap(tab('Check'));
    expect(find.byKey(const Key('verify.tool.retailUsers')), findsNothing);
    await logOut(app);
  });

  testWidgets("TC-E2E-002 a field inspector's day", (tester) async {
    final app = await logIn(tester, Roles.fieldInspector);

    // The Check tab is the camera: the scan is the trigger.
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(find.text('Genuine product'), findsOneWidget);
    await back(tester);

    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '1000001,1000002,1000003');
    await app.tap(find.byKey(const Key('serials.submit')));
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
    await app.tap(find.text('1000001').first);
    await app.tap(find.byKey(const Key('result.report')));
    await fileReport(app, 'Label print is blurred');
    expect(find.text('Report 1042 filed.'), findsOneWidget);
    await app.tapText('Done');
    await home(tester);
    stillIn();

    await app.tap(tab('History'));
    await app.tap(find.byKey(const Key('history.filters')));
    expect(find.byKey(const Key('history.scopeAll')), findsNothing);
    await back(tester);
    await logOut(app);
  });

  testWidgets("TC-E2E-003 a head office auditor's day", (tester) async {
    final app = await logIn(tester, Roles.auditor);
    await lookUp(app, '1000001');
    expect(find.byKey(const Key('result.report')), findsNothing);
    await back(tester);

    await app.tap(tab('History'));
    await app.tap(find.byKey(const Key('history.filters')));
    await app.tapText('Apply');
    await app.enter(const Key('history.search'), '1000001');
    await app.settleAfter(const Duration(milliseconds: 500));
    expectTrackingLog('1000001');
    expect(
      app.backend.sent('GET', 'checks').last.queryParameters['scope'],
      isNull,
    );
    await logOut(app);
  });

  testWidgets("TC-E2E-004 a senior seller's day", (tester) async {
    final app = await logIn(tester, Roles.seniorSeller);
    expect(find.byKey(const Key('verify.tool.report')), findsNothing);
    expect(find.byKey(const Key('verify.tool.retailUsers')), findsNothing);
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '1000001,1000002,1000003');
    await app.tap(find.byKey(const Key('serials.submit')));
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
    await back(tester);
    await app.tap(tab('History'));
    expect(find.text('1000001'), findsOneWidget);
    await app.tap(tab('Profile'));
    expect(find.text('Senior seller'), findsWidgets);
    await logOut(app);
  });

  testWidgets("TC-E2E-005 a retail seller's day", (tester) async {
    final app = await logIn(tester, Roles.retailSeller);
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(find.text('Genuine product'), findsOneWidget);
    await back(tester);
    expect(app.fieldText(const Key('verify.input')), '1000001');

    await app.tap(tab('History'));
    for (final r in app.backend.sent('GET', 'checks')) {
      expect(r.queryParameters.containsKey('scope'), isFalse);
    }
    await app.tap(tab('Profile'));
    await logOut(app);
  });

  testWidgets("TC-E2E-006 an incident reporter's day", (tester) async {
    final app = await logIn(tester, Roles.incidentReporter);
    expect(input, findsNothing);
    await app.tap(find.byKey(const Key('verify.tool.report')));
    await app.tap(find.byKey(const Key('report.retailUser')));
    await app.tapText('Rahim Store');
    await fileReport(app, 'Selling outside the area');
    expect(find.text('Report 1042 filed.'), findsOneWidget);
    await app.tapText('Done');
    await home(tester);
    await app.tap(find.byKey(const Key('verify.tool.myReports')));
    expect(find.textContaining('1042'), findsWidgets);
    await back(tester);
    await logOut(app);
  });

  testWidgets("TC-E2E-007 a trainee's day", (tester) async {
    final app = await logIn(tester, Roles.trainee);
    expect(find.text('No features yet'), findsOneWidget);
    await app.tap(tab('Profile'));
    await app.tapText('Change password');
    await app.enter(const Key('change.old'), 'old-pass-1');
    await app.enter(const Key('change.new'), 'abcd1234');
    await app.enter(const Key('change.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('change.submit')));
    expect(find.text('Your password was changed.'), findsOneWidget);
    await logOut(app);
  });

  testWidgets('TC-E2E-008 a retail seller without history', (tester) async {
    final app = await logIn(tester, Roles.retailSellerNoHistory);
    expect(tab('History'), findsNothing);
    await lookUp(app, '1000001');
    expect(find.text('Genuine product'), findsOneWidget);
    await back(tester);
    expect(tab('History'), findsNothing);
    await logOut(app);
  });

  testWidgets('TC-E2E-012 the login ends in the middle of a report', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST incidents': always(apiError(401, 'token_expired')),
        'POST auth/refresh': always(apiError(401, 'unauthenticated')),
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.report')));
    await fileReport(app, 'Torn seal');
    expect(find.text(loginTitle), findsOneWidget);
    expect(app.backend.sent('POST', 'incidents'), hasLength(1));

    await logInWithCode(app);
    await app.tap(find.byKey(const Key('verify.tool.myReports')));
    // Nothing was filed again by itself.
    expect(app.backend.sent('POST', 'incidents'), hasLength(1));
  });

  testWidgets('TC-E2E-014 a forced change, then a normal day', (
    tester,
  ) async {
    var forced = true;
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/login': (_) => forced
            ? FakeBackend.example(
                200,
                '1. Log in',
                '200 New phone: a code was emailed',
              )
            : loggedIn(),
        'POST auth/verify-phone': always(loggedIn(mustChange: true)),
      },
    );
    app.backend.profile = {
      ...Roles.fieldInspector,
      'must_change_password': true,
    };
    await logInWithCode(app);
    expect(find.text('Set a new password'), findsOneWidget);
    app.backend.profile = Roles.fieldInspector;
    await app.enter(const Key('change.old'), 'first-pass');
    await app.enter(const Key('change.new'), 'abcd1234');
    await app.enter(const Key('change.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('change.submit')));
    expect(find.text('Welcome back,'), findsOneWidget);
    await lookUp(app, '1000001');
    expect(find.text('Genuine product'), findsOneWidget);
    await back(tester);
    await logOut(app);

    forced = false;
    await logInToCode(app);
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Set a new password'), findsNothing);
  });
}
