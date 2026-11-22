import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';

import '../fakes/postman_examples.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

void main() {
  testWidgets('access request: form, code, pending, then return to login', (
    tester,
  ) async {
    final app = await startApp(tester, loggedIn: false);
    await app.tapText('Sign up');
    await fillAccessForm(app);
    expect(app.backend.sent('POST', 'auth/access/code'), isEmpty);
    await app.tap(find.byKey(const Key('access.sendCode')));
    expect(find.text('A code was sent to the address.'), findsOneWidget);
    await app.enter(const Key('access.code'), '123456');
    await app.tap(find.byKey(const Key('access.submit')));
    expect(find.textContaining('Thanks for signing up.'), findsOneWidget);
    expect(app.backend.sent('POST', 'auth/access').single.data, {
      'email': 'person@example.com',
      'code': '123456',
      'name': 'Rahim Store',
      'role_id': 7,
      'password': 'chosen-pass-1',
    });
    for (final r in app.backend.requests.where(
      (r) => r.path == 'roles/requestable' || r.path.startsWith('auth/access'),
    )) {
      expect(r.headers.containsKey('Authorization'), isFalse);
    }
    expect(app.storage.values.values, isNot(contains('chosen-pass-1')));
    expect(app.logger.lines.join(), isNot(contains('chosen-pass-1')));
    await app.tapText('Back to login');
    expect(find.text('Login to Track & Trace'), findsOneWidget);
  });
  // TC-MIG-066 (test-server integration, step 9): the name field keeps
  // the name within the server's 100 UTF-16 units, at whole characters.
  testWidgets('TC-MIG-066 the name field stops at 100 UTF-16 units', (
    tester,
  ) async {
    final app = await startApp(tester, loggedIn: false);
    await app.tapText('Sign up');
    await app.enter(const Key('access.name'), '${'a' * 99}🙂');
    expect(app.fieldText(const Key('access.name')), 'a' * 99);
    await app.enter(const Key('access.name'), '🙂' * 60);
    expect(app.fieldText(const Key('access.name')), '🙂' * 50);
    await app.enter(const Key('access.name'), 'ক' * 120);
    expect(app.fieldText(const Key('access.name')), 'ক' * 100);
  });

  testWidgets('an email edit requires a fresh access code', (tester) async {
    final app = await startApp(tester, loggedIn: false);
    await app.tapText('Sign up');
    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    await app.enter(const Key('access.email'), 'different@example.com');
    expect(find.byKey(const Key('access.submit')), findsNothing);
    expect(app.backend.sent('POST', 'auth/access'), isEmpty);
  });
  testWidgets('empty requestable roles show office fallback without a form', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {'GET roles/requestable': always(ok(<Object?>[]))},
    );
    await app.tapText('Sign up');
    expect(find.text('Ask the office for an account.'), findsOneWidget);
    expect(find.byKey(const Key('access.password')), findsNothing);
    await app.tapText('Contact the office');
    expect(app.launcher.emails.single.to, 'office@example.com');
    expect(app.backend.sent('POST', 'auth/access/code'), isEmpty);
  });
  testWidgets(
    'bulk-only scanner shows results, suppresses frames, '
    'and ends without history',
    (tester) async {
      final app = await startApp(
        tester,
        profile: Roles.only(['item:bulk_lookup']),
      );
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
      await tester.pumpAndSettle();
      final first = app.backend.sent('POST', 'lookups').single;
      final id = (first.data as Map)['session_id'] as String;
      expect(app.storage.values.values, contains(id));
      app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'lookups'), hasLength(1));
      expect(app.backend.sent('GET', 'checks'), isEmpty);
      await app.tap(find.byKey(const Key('session.latest')));
      expect(find.byType(LookupResultScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        app.backend.sent('POST', 'lookups/sessions/$id/end'),
        hasLength(1),
      );
      expect(app.storage.values.values, isNot(contains(id)));
    },
  );
  testWidgets(
    'serial stacks deduplicate and show details without single permission; '
    'legacy endpoints are never called',
    (tester) async {
      final app = await startApp(
        tester,
        profile: Roles.only(['item:bulk_lookup']),
      );
      await app.tap(find.byKey(const Key('verify.tool.serials')));
      await app.enter(
        const Key('serials.input'),
        '1000001,1000002\n1000001 1000003',
      );
      await app.tap(find.byKey(const Key('serials.submit')));
      expect(app.backend.sent('POST', 'lookups/serials').single.data, {
        'serials': ['1000001', '1000002', '1000003'],
      });
      expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
      await app.tap(find.text('1000001').first);
      expect(find.byType(LookupResultScreen), findsOneWidget);
      expect(app.backend.sent('POST', 'lookups/bulk'), isEmpty);
      expect(app.backend.sent('GET', 'checks'), isEmpty);
    },
  );
  testWidgets(
    'session browsing sends own-only session-filtered history, '
    'retaining legacy way filters',
    (tester) async {
      final app = await startApp(tester);
      await app.tap(tab('History'));
      await app.tapText('Sessions');
      await app.tap(find.text('Scanner mode').first);
      final request = app.backend.sent('GET', 'checks').last;
      expect(request.queryParameters['session_id'], isNotNull);
      final id = request.queryParameters['session_id'];
      expect(request.queryParameters.containsKey('scope'), isFalse);
      await app.tap(find.byKey(const Key('history.filters')));
      expect(find.byKey(const Key('history.scopeAll')), findsNothing);
      await app.tapText('Hidden code');
      await app.tapText('Apply');
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['way'],
        'hidden_code',
      );
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['session_id'],
        id,
      );
    },
  );
  testWidgets(
    'restored scanner reads server summary and history without persisting them',
    (tester) async {
      final app = await startApp(tester);
      final store = ActiveScanStore(
        app.storage,
        client: testConfig.clientSlug,
        official: Roles.fieldInspector['id'] as String,
      );
      const id = '7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33';
      await store.save(id);
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      expect(app.backend.sent('GET', 'lookups/sessions/$id'), hasLength(1));
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['session_id'],
        id,
      );
      expect(
        app.storage.values.keys.where((k) => k.startsWith('scan_session:')),
        hasLength(1),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    },
  );
  testWidgets('scanner result layout fits narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final app = await startApp(
      tester,
      profile: Roles.only(['item:bulk_lookup']),
    );
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });
  testWidgets('withdrawn permissions grant no features', (tester) async {
    final app = await startApp(
      tester,
      profile: Roles.only(['history:all', 'retail_user:add']),
    );
    expect(find.text('No features yet'), findsOneWidget);
    expect(find.byKey(const Key('verify.tool.retailUsers')), findsNothing);
    expect(app.backend.sent('GET', 'retail-roles'), isEmpty);
  });
  testWidgets(
    'single-result permission is rechecked even when bulk remains allowed',
    (tester) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      final context = tester.element(find.byType(LookupResultScreen));
      app.backend.profile = Roles.only(['item:bulk_lookup']);
      final refreshing = context.read<ProfileCubit>().refresh();
      await tester.pumpAndSettle();
      await refreshing;
      expect(find.byType(LookupResultScreen), findsNothing);
      expect(find.byKey(const Key('verify.tool.bulk')), findsOneWidget);
    },
  );
  testWidgets('access form stays usable with a selected role at large text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final app = await startApp(tester, loggedIn: false);
    await app.tapText('Sign up');
    await fillAccessForm(app);
    expect(tester.takeException(), isNull);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'MIG-031 History switches between Checks and Sessions; a session opens '
    'its checks and back returns to Sessions',
    (tester) async {
      final app = await startApp(tester);
      await app.tap(tab('History'));
      // Checks first: the search and filters of the history.
      expect(find.byKey(const Key('history.view')), findsOneWidget);
      expect(find.byKey(const Key('history.filters')), findsOneWidget);
      expect(app.backend.sent('GET', 'lookups/sessions'), isEmpty);

      await app.tap(find.byKey(const Key('history.view.sessions')));
      expect(app.backend.sent('GET', 'lookups/sessions'), hasLength(1));
      expect(find.byKey(const Key('sessions.list')), findsOneWidget);
      expect(find.text('Showing the last 7 days'), findsOneWidget);
      // Both times of a session (SRS FR-SCN-11).
      expect(find.textContaining('Started: '), findsWidgets);
      expect(find.textContaining('Last scan: '), findsWidgets);

      await app.tap(find.byKey(const Key('sessions.status.ended')));
      expect(
        app.backend.sent('GET', 'lookups/sessions').last.queryParameters,
        containsPair('status', 'ended'),
      );

      await app.tap(find.text('Scanner mode').first);
      expect(find.text('Session checks'), findsOneWidget);
      // Its summary on top (SRS FR-SCN-16): GET lookups/sessions/{id}.
      expect(find.byKey(const Key('session.summary')), findsOneWidget);
      expect(
        app.backend.requests.where(
          (r) => r.method == 'GET' && r.path.startsWith('lookups/sessions/'),
        ),
        isNotEmpty,
      );
      // One session's checks: no switch.
      expect(find.byKey(const Key('history.view')), findsNothing);
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['session_id'],
        isNotNull,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sessions.list')), findsOneWidget);

      await app.tap(find.byKey(const Key('history.view.checks')));
      expect(find.byKey(const Key('history.filters')), findsOneWidget);
      expect(find.byKey(const Key('sessions.list')), findsNothing);
    },
  );

  // Audit H4: a role list that failed to load is not an empty list.
  testWidgets('TC-MIG-033 a failed role load shows its error and Try again, '
      'never "Ask the office"', (tester) async {
    var calls = 0;
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'GET roles/requestable': (r) async => calls++ == 0
            ? offline()(r)
            : FakeBackend.example(
                200,
                '1. The roles that can be requested',
                '200 The roles',
              ),
      },
    );
    await app.tapText('Sign up');
    expect(find.text('Ask the office for an account.'), findsNothing);
    expect(find.text('Contact the office'), findsNothing);
    expect(
      find.text('No connection. Check the internet and try again.'),
      findsOneWidget,
    );
    await app.tapText('Try again');
    expect(find.byKey(const Key('access.name')), findsOneWidget);
    expect(app.backend.sent('GET', 'roles/requestable'), hasLength(2));
  });

  // TC-MIG-038 (audit): a result opened from a stack goes back to the list;
  // Home would drop the stack's results.
  testWidgets('TC-MIG-038 a stack row result goes back to the list, never '
      'Home', (tester) async {
    final app = await startApp(tester, profile: Roles.supervisor);
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '1000001 1000002 1000003');
    await app.tap(find.byKey(const Key('serials.submit')));
    await app.tap(find.text('1000003').first);
    expect(find.byType(LookupResultScreen), findsOneWidget);
    expect(find.byKey(const Key('result.backToVerify')), findsNothing);
    await app.tap(find.text('Back to the list'));
    expect(find.byType(LookupResultScreen), findsNothing);
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
  });

  // TC-MIG-039 (SRS FR-STK-01): the count before sending, repeats sent once.
  testWidgets('TC-MIG-039 the stack shows how many serials go', (
    tester,
  ) async {
    final app = await startApp(tester, profile: Roles.supervisor);
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '1000001 1000002 1000001');
    expect(
      find.text('2 of 50 serials · 1 repeated, sent once'),
      findsOneWidget,
    );
    await app.enter(const Key('serials.input'), '1000001');
    expect(find.text('1 of 50 serials'), findsOneWidget);
  });

  // TC-MIG-040 (SRS 7.1): scanner mode has the scanner's camera layout,
  // zero counters before the first scan, and Scan again only after a
  // failure.
  testWidgets('TC-MIG-040 scanner mode: camera, frame, counters', (
    tester,
  ) async {
    var calls = 0;
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'POST lookups': (r) async {
          if (calls++ == 0) return offline()(r);
          return FakeBackend.example(200, '1. Scan a QR', '200 A scan');
        },
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    expect(find.byKey(const Key('session.camera')), findsOneWidget);
    expect(find.byKey(const Key('session.frame')), findsOneWidget);
    expect(find.byKey(const Key('session.hint')), findsOneWidget);
    expect(find.bySemanticsLabel('Scanned: 0'), findsOneWidget);
    expect(find.byKey(const Key('session.scanAgain')), findsNothing);

    app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(find.text('No connection, scan again.'), findsOneWidget);
    expect(find.byKey(const Key('session.scanAgain')), findsOneWidget);
    // Leaving ends the session (and its timers).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  // TC-MIG-044 (guide sections 1, 3.9): "Role not found." names the role;
  // any other 404 on sending is the app not being available.
  for (final (message, text) in [
    (
      'Role not found.',
      'This role is no longer available. Choose another role.',
    ),
    (null, 'Not available.'),
  ]) {
    testWidgets('TC-MIG-044 an access request answered 404 "$message"', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/access': always(
            apiError(404, 'not_found', message: message),
          ),
        },
      );
      await app.tapText('Sign up');
      await fillAccessForm(app);
      await app.tap(find.byKey(const Key('access.sendCode')));
      await app.enter(const Key('access.code'), '123456');
      await app.tap(find.byKey(const Key('access.submit')));
      expect(find.text(text), findsOneWidget);
    });
  }

  // TC-MIG-049 (guide 4.3): QRs shown one after another are each sent and
  // each answer shows live on the camera, with a vibration; none is missed.
  testWidgets('TC-MIG-049 scanner mode: many QRs, each result live', (
    tester,
  ) async {
    Map<String, dynamic> answer(String value, String session) {
      final body = value == 'A1B2C3D4E5F6'
          ? postmanExample(
              request: '1. A scan in the session',
              example: '200 not_found',
            )
          : postmanExample(
              request: '1. A scan in the session',
              example: '200 first scan of an item: warning',
            );
      final data = body['data'] as Map<String, dynamic>;
      (data['session'] as Map)['id'] = session;
      data['ref'] = 'MA-$value';
      if (value == 'Q8F2KD91XA7M') {
        data['result'] = 'valid';
        data['reasons'] = <String>[];
      }
      return body;
    }

    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'POST lookups': (r) async {
          final sent = r.data as Map;
          return ScriptedAnswer(
            200,
            answer(sent['value'] as String, sent['session_id'] as String),
          );
        },
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    final felt = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') felt.add(call.arguments);
        return null;
      },
    );

    // Three products, one right after another: the second and third are
    // read while the first is still being checked.
    app.scanner
      ..scan('https://example.test/q/Q8F2KD91XA7M')
      ..scan('https://example.test/q/A1B2C3D4E5F6')
      ..scan('https://example.test/q/B1B2C3D4E5F6');
    // The bloc's answer reaches the screen on the next frame.
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('session.checking')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    final live = find.byKey(const Key('session.live'));
    expect(
      find.descendant(of: live, matching: find.text('Genuine product')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: live, matching: find.text('Not found')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: live,
        matching: find.text('Genuine, needs attention'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('session.checking')), findsNothing);
    expect(app.backend.sent('POST', 'lookups'), hasLength(3));
    // All three joined the list, newest first: the first one is last.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('MA-Q8F2KD91XA7M')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('session.rows')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const ValueKey('MA-A1B2C3D4E5F6')), findsOneWidget);
    expect(felt, [
      'HapticFeedbackType.mediumImpact',
      null,
      null,
    ]);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  group('Finish: every scan together (TC-MIG-053, -054)', () {
    /// A backend that counts like a real session: one reference per QR,
    /// a repeat for the same QR again, results by the last character.
    Answer countingBackend(List<String> sessions) {
      final seen = <String, Map<String, Object?>>{};
      return (r) async {
        final sent = r.data as Map;
        final value = sent['value'] as String;
        final session = sent['session_id'] as String;
        if (!sessions.contains(session)) {
          sessions.add(session);
          seen.clear();
        }
        final repeat = seen.containsKey(value);
        final result =
            seen[value] ??
            {
              'ref': 'MA-$value',
              'result': value.endsWith('3') ? 'not_found' : 'valid',
              'reasons': <String>[],
              if (!value.endsWith('3')) ...{
                'count': {'this_check': 1, 'last_at': null},
                'item': {
                  'serial': '41${seen.length}',
                  'code': '*****7K2',
                  'product': {
                    'name': 'Paracetamol 500',
                    'generic_name': 'Paracetamol',
                    'short_name': 'PCM500',
                    'picture_url': null,
                  },
                  'batch': {
                    'number': 'B-1042',
                    'made': '2026-01-10',
                    'expires': '2027-09-30',
                  },
                },
              },
            };
        seen[value] = result;
        final notFound = seen.values
            .where((v) => v['result'] == 'not_found')
            .length;
        return ok({
          ...result,
          'repeat': repeat,
          'session': {
            'id': session,
            'scanned': seen.length,
            'valid': seen.length - notFound,
            'warning': 0,
            'not_found': notFound,
            'unassigned': 0,
            'left': 5000 - seen.length,
          },
        });
      };
    }

    /// Lets every queued read go out and be answered.
    Future<void> settleScans(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pumpAndSettle();
    }

    for (final (name, profile) in [
      ('a supervisor', Roles.supervisor),
      ('a bulk-only role', Roles.only(['item:bulk_lookup'])),
    ]) {
      testWidgets('TC-MIG-053 Finish shows every scan together: $name', (
        tester,
      ) async {
        final sessions = <String>[];
        final app = await startApp(
          tester,
          profile: profile,
          overrides: {'POST lookups': countingBackend(sessions)},
        );
        await app.tap(find.byKey(const Key('verify.tool.bulk')));
        final finish = find.byKey(const Key('session.finish'));
        expect(app.enabled(const Key('session.finish')), isFalse);

        // Three products one after another, then the first one again.
        app.scanner
          ..scan('https://example.test/q/Q8F2KD91XA7M')
          ..scan('https://example.test/q/A1B2C3D4E5F3')
          ..scan('https://example.test/q/B1B2C3D4E5F6');
        await settleScans(tester);
        app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
        await settleScans(tester);
        expect(find.byKey(const Key('session.repeat')), findsOneWidget);
        expect(app.backend.sent('POST', 'lookups'), hasLength(4));

        await app.tap(finish);
        final summary = find.byKey(const Key('session.summary'));
        expect(summary, findsOneWidget);
        expect(find.byKey(const Key('session.camera')), findsNothing);
        expect(find.text('Session finished'), findsOneWidget);
        expect(find.text('3 products scanned'), findsOneWidget);
        for (final ref in [
          'MA-Q8F2KD91XA7M',
          'MA-A1B2C3D4E5F3',
          'MA-B1B2C3D4E5F6',
        ]) {
          expect(
            find.byKey(ValueKey('summary.$ref')),
            findsOneWidget,
            reason: ref,
          );
        }
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('summary.MA-A1B2C3D4E5F3')),
            matching: find.textContaining('Not found'),
          ),
          findsOneWidget,
        );
        final ended = [
          for (final r in app.backend.requests)
            if (r.method == 'POST' && r.path.endsWith('/end')) r.path,
        ];
        expect(ended, ['lookups/sessions/${sessions.single}/end']);

        // A row opens its result; Back returns to the summary.
        await app.tap(find.byKey(const ValueKey('summary.MA-B1B2C3D4E5F6')));
        expect(summary, findsNothing);
        expect(find.text('Genuine product'), findsWidgets);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(summary, findsOneWidget);
        expect(app.scanner.sessions.last.running, isFalse);

        // Done: back on the Check tab.
        await app.tap(find.byKey(const Key('session.done')));
        expect(summary, findsNothing);
        expect(find.byKey(const Key('verify.tool.bulk')), findsOneWidget);
      });
    }

    testWidgets('TC-MIG-054 Scan more starts a new session on the camera', (
      tester,
    ) async {
      final sessions = <String>[];
      final app = await startApp(
        tester,
        profile: Roles.supervisor,
        overrides: {'POST lookups': countingBackend(sessions)},
      );
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
      await settleScans(tester);
      await app.tap(find.byKey(const Key('session.finish')));
      expect(find.text('1 product scanned'), findsOneWidget);

      await app.tap(find.byKey(const Key('session.scanMore')));
      expect(find.byKey(const Key('session.summary')), findsNothing);
      expect(find.byKey(const Key('session.camera')), findsOneWidget);
      expect(app.enabled(const Key('session.finish')), isFalse);
      expect(app.scanner.sessions.last.running, isTrue);

      // The same product counts again, in a new session.
      app.scanner.scan('https://example.test/q/Q8F2KD91XA7M');
      await settleScans(tester);
      expect(sessions, hasLength(2));
      expect(find.byKey(const Key('session.repeat')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('MA-Q8F2KD91XA7M')),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('session.rows')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.byKey(const ValueKey('MA-Q8F2KD91XA7M')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    });
  });
}
