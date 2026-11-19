import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_preferences_service.dart';
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

  group('MIG scanner summary after Finish (TC-MIG-053)', () {
    /// Answers each QR by its last character, as the mock build does, with
    /// its own reference and counts that add up.
    Answer byLastCharacter() {
      final seen = <String, String>{};
      return (r) async {
        final sent = r.data as Map;
        final value = sent['value'] as String;
        final Map<String, dynamic> body;
        switch (value[value.length - 1]) {
          case '2':
            body = postmanExample(
              request: '1. A scan in the session',
              example: '200 first scan of an item: warning',
            );
          case '3':
            body = postmanExample(
              request: '1. A scan in the session',
              example: '200 not_found',
            );
          case '4':
            body = postmanExample(
              request: 'Look up one item',
              example: '200 unassigned',
            );
          default:
            body = postmanExample(
              request: 'Look up one item',
              example: '200 valid: genuine, first check',
            );
        }
        final data = body['data'] as Map<String, dynamic>;
        seen[value] = data['result'] as String;
        data['ref'] = 'MA-$value';
        final item = data['item'];
        if (item is Map<String, dynamic>) {
          item['serial'] = '410000${seen.length}';
          (item['product'] as Map)['picture_url'] = null;
        }
        int count(String result) =>
            seen.values.where((v) => v == result).length;
        data
          ..['repeat'] = false
          ..['session'] = {
            'id': sent['session_id'],
            'scanned': seen.length,
            'valid': count('valid'),
            'warning': count('warning'),
            'not_found': count('not_found'),
            'unassigned': count('unassigned'),
            'left': 5000 - seen.length,
          };
        return ScriptedAnswer(200, body);
      };
    }

    Future<void> scanAndFinish(WidgetTester tester, FlowApp app) async {
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      for (final value in [
        'K7M2PX4Q9AB1',
        'R3T8WZ5N2CD2',
        'H6J9LV1B4EF3',
        'P2Q7XM8S5GH4',
      ]) {
        app.scanner.scan('https://www.ziskaverify.com/q/$value');
      }
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pumpAndSettle();
      await app.tap(find.byKey(const Key('session.finish')));
      expect(find.byKey(const Key('session.summary')), findsOneWidget);
    }

    for (final (name, scale, language) in [
      ('screen_scanner_summary', 1.0, null),
      ('font2x_scanner_summary', 2.0, null),
      ('bn_scanner_summary', 1.0, 'bn'),
    ]) {
      uiTest('MIG scanner summary: $name', (tester, shot) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final app = await startApp(
          tester,
          profile: Roles.only(['item:bulk_lookup']),
          overrides: {'POST lookups': byLastCharacter()},
          preferences: FakePreferencesService(language: language),
        );
        await atOneX(tester);
        await scanAndFinish(tester, app);
        if (language == null) {
          expect(find.text('4 products scanned'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await shot(name);
      });
    }

    testWidgets('the summary fits a 320 px phone at 3x font', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final app = await startApp(
        tester,
        profile: Roles.only(['item:bulk_lookup']),
        overrides: {'POST lookups': byLastCharacter()},
      );
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      await tester.pumpAndSettle();
      await scanAndFinish(tester, app);
      expect(tester.takeException(), isNull);
    });
  });
}
