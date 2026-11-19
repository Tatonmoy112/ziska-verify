import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../fakes/postman_examples.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart';
import 'ui_helpers.dart';

void main() {
  setUpAll(loadUiFonts);
  hideFlavourRibbon();
  uiTest('MIG scanner inline result and authoritative counters', (
    tester,
    shot,
  ) async {
    final app = await startApp(
      tester,
      profile: Roles.only(['item:bulk_lookup']),
    );
    await atOneX(tester);
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Scanned: 41'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await shot('screen_scanner_session');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  // TC-MIG-049: a Not found answer shows red on the camera.
  uiTest('MIG scanner live result: not found', (tester, shot) async {
    final app = await startApp(
      tester,
      profile: Roles.only(['item:bulk_lookup']),
      overrides: {
        'POST lookups': (r) async {
          final body = postmanExample(
            request: '1. A scan in the session',
            example: '200 not_found',
          );
          ((body['data'] as Map)['session'] as Map)['id'] =
              (r.data as Map)['session_id'];
          return ScriptedAnswer(200, body);
        },
      },
    );
    await atOneX(tester);
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('session.live')),
        matching: find.text('Not found'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await shot('screen_scanner_live_not_found');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });
  uiTest('MIG serial stack composer', (tester, shot) async {
    final app = await startApp(
      tester,
      profile: Roles.only(['item:bulk_lookup']),
    );
    await atOneX(tester);
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    expect(find.byKey(const Key('serials.input')), findsOneWidget);
    await shot('screen_serial_stack');
  });
  uiTest('MIG serial stack results', (tester, shot) async {
    final app = await startApp(tester);
    await atOneX(tester);
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '1000001,1000002,1000003');
    await app.tap(find.byKey(const Key('serials.submit')));
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await shot('screen_serial_stack_results');
  });
  uiTest('MIG own sessions list', (tester, shot) async {
    final app = await startApp(tester);
    await atOneX(tester);
    await app.tap(tab('History'));
    await app.tapText('Sessions');
    expect(find.text('Showing the last 7 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await shot('screen_sessions');
  });
  uiTest('MIG access request code stage', (tester, shot) async {
    final app = await startApp(tester, loggedIn: false);
    await atOneX(tester);
    await app.tapText('Sign up');
    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await tester.ensureVisible(find.byKey(const Key('access.code')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await shot('screen_access_code');
  });
  uiTest('MIG access request pending', (tester, shot) async {
    final app = await startApp(tester, loggedIn: false);
    await atOneX(tester);
    await app.tapText('Sign up');
    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    await app.tap(find.byKey(const Key('access.submit')));
    expect(find.textContaining('Thanks for signing up.'), findsOneWidget);
    await shot('screen_access_pending');
  });
}
