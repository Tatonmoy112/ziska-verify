import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: broken answers, odd status codes, `Retry-After` variants,
/// and network faults (docs/test-cases/10-errors-network.md). The request
/// matrix itself is `error_matrix_flow_test.dart`.
void main() {
  const general = 'Something went wrong. Try again.';
  const html = '<html><body><h1>Log in to the Wi-Fi</h1></body></html>';

  Future<FlowApp> lookUp(WidgetTester tester, Answer answer) async {
    final app = await startApp(tester, overrides: {'POST lookups': answer});
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    return app;
  }

  Future<FlowApp> history(WidgetTester tester, Answer answer) async {
    final app = await startApp(tester, overrides: {'GET checks': answer});
    await app.tap(tab('History'));
    return app;
  }

  void expectNoResult() {
    expect(find.text('Genuine product'), findsNothing);
    expect(find.text('Check result'), findsNothing);
  }

  testWidgets('TC-ERR-008 413 and 415 are handled as 400', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST incidents': always(apiError(413, 'validation_failed')),
      },
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('verify.tool.report')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(const Key('verify.tool.report')));
    await app.enter(const Key('report.note'), 'Seal is cut');
    await app.tap(find.byKey(const Key('report.submit')));
    expect(find.text(general), findsOneWidget);

    final second = await startApp(
      tester,
      overrides: {
        'POST incidents/1042/photos': always(
          apiError(415, 'validation_failed'),
        ),
      },
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('verify.tool.report')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await second.tap(find.byKey(const Key('verify.tool.report')));
    await second.tap(find.byKey(const Key('report.addPhoto')));
    await second.tapText('Choose from gallery');
    await second.enter(const Key('report.note'), 'Seal is cut');
    await second.tap(find.byKey(const Key('report.submit')));
    // On the tile, and with its reference under the photos (guide §1).
    expect(find.text('This photo was refused.'), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byKey(const Key('report.photoFailure')),
        matching: find.text('Reference: req-1'),
      ),
      findsOneWidget,
    );
  });

  // The guide's error table (§1): a 409 `conflict` "conflicts with the
  // current state … Show the message".
  testWidgets('TC-ERR-012 409 where the route has no 409 case: the server '
      'message', (tester) async {
    const said = 'The request conflicts with the current state.';
    await history(tester, always(apiError(409, 'conflict', message: said)));
    expect(find.text(said), findsOneWidget);
    expect(find.text(general), findsNothing);
    expect(find.textContaining('req-1'), findsOneWidget);

    await startApp(
      tester,
      overrides: {'GET formats': always(apiError(409, 'conflict'))},
    );
    expect(find.textContaining('Could not load the code formats.'), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-ERR-014 app_preparing outside lookups', (tester) async {
    await history(tester, always(apiError(503, 'app_preparing')));
    expect(
      find.text('The app is being prepared. Try again later.'),
      findsOneWidget,
    );
  });

  for (final status in [502, 504]) {
    testWidgets('TC-ERR-016 $status without an envelope', (tester) async {
      await history(tester, always(ScriptedAnswer.raw(status, html)));
      expect(find.textContaining(general), findsOneWidget);
      expect(find.textContaining('Reference'), findsNothing);
    });
  }

  testWidgets('TC-ERR-017 an unknown code shows the server message', (
    tester,
  ) async {
    await lookUp(
      tester,
      always(
        apiError(
          400,
          'brand_new',
          requestId: 'req-new',
          message: 'This client is under review.',
        ),
      ),
    );
    expect(find.textContaining('This client is under review.'), findsOneWidget);
    expect(find.textContaining('req-new'), findsOneWidget);
    expectNoResult();
  });

  // TC-ERR-050 (audit 2026-11-19): the rule holds for a busy (503) or a
  // wait (429) answer too; a known code keeps the app's text.
  for (final (status, code, message, expected) in [
    (
      503,
      'storage_slow',
      'Photo storage is slow. Try again in a minute.',
      'Photo storage is slow. Try again in a minute.',
    ),
    (
      503,
      'service_unavailable',
      'Service temporarily unavailable.',
      'The service is busy. Try again shortly.',
    ),
    (
      429,
      'daily_quota',
      'You reached the checks allowed today.',
      'You reached the checks allowed today.',
    ),
  ]) {
    testWidgets('TC-ERR-050 $status $code: the right message', (
      tester,
    ) async {
      await lookUp(
        tester,
        always(apiError(status, code, requestId: 'req-49', message: message)),
      );
      expect(find.textContaining(expected), findsOneWidget);
      expect(find.textContaining('req-49'), findsOneWidget);
      expectNoResult();
    });
  }

  testWidgets('TC-ERR-018 an error without a reference', (tester) async {
    await lookUp(
      tester,
      always(
        const ScriptedAnswer(400, {
          'success': false,
          'message': 'Invalid request.',
          'error': {'code': 'validation_failed', 'message': 'Invalid request.'},
        }),
      ),
    );
    expect(find.text(general), findsOneWidget);
    expect(find.textContaining('Reference'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('TC-ERR-019 the server text never replaces the app text', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/login': always(
          apiError(401, 'unauthenticated', message: 'Some other text'),
        ),
      },
    );
    await logInToCode(app);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.textContaining('Some other text'), findsNothing);
  });

  group('TC-ERR-020 a success answer without data', () {
    const noData = ScriptedAnswer(200, {'success': true, 'message': 'OK'});

    testWidgets('GET me', (tester) async {
      await startApp(tester, overrides: {'GET me': always(noData)});
      expect(find.text('Welcome back,'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('POST lookups', (tester) async {
      await lookUp(tester, always(noData));
      expectNoResult();
      expect(tester.takeException(), isNull);
    });

    testWidgets('GET checks', (tester) async {
      await history(tester, always(noData));
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('TC-ERR-021 success false with 200 is an error', (
    tester,
  ) async {
    await lookUp(
      tester,
      always(
        const ScriptedAnswer(200, {
          'success': false,
          'message': 'Failed.',
          'error': {
            'code': 'internal_error',
            'message': 'Failed.',
            'request_id': 'req-21',
          },
        }),
      ),
    );
    expectNoResult();
    expect(find.textContaining('req-21'), findsOneWidget);
  });

  for (final (name, body) in [
    ('empty', ''),
    ('cut off', '{"success": tr'),
  ]) {
    testWidgets('TC-ERR-022 an $name body', (tester) async {
      await history(
        tester,
        always(ScriptedAnswer.raw(200, body, contentType: 'application/json')),
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('TC-ERR-023 a captive portal page: an error, never a logout', (
    tester,
  ) async {
    var portal = true;
    final app = await startApp(
      tester,
      overrides: {
        // A hotel Wi-Fi answers its own login page, then the real network.
        'GET me': (r) => portal
            ? const ScriptedAnswer.raw(200, html)
            : ok(Roles.fieldInspector),
      },
    );
    expect(find.text('Welcome back,'), findsNothing);
    expect(find.text('Login to Track & Trace'), findsNothing);
    expect(app.storage.values[SecureKeys.refreshToken], isNotNull);

    portal = false;
    await app.tapText('Try again');
    expect(find.text('Welcome back,'), findsOneWidget);
  });

  for (final status in [403, 404]) {
    testWidgets('TC-ERR-024 a proxy HTML page with $status', (tester) async {
      final app = await history(
        tester,
        always(ScriptedAnswer.raw(status, html)),
      );
      final mes = app.backend.sent('GET', 'me').length;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      // Without the envelope the status decides (guide section 1): 404 is
      // "Not available"; 403 has no code to act on, so a general error.
      expect(
        find.textContaining(status == 404 ? 'Not available.' : general),
        findsOneWidget,
      );
      expect(app.backend.sent('GET', 'me'), hasLength(mes));
      expect(app.storage.values[SecureKeys.refreshToken], isNotNull);
    });
  }

  group('Retry-After', () {
    ScriptedAnswer limited(String? retryAfter) => ScriptedAnswer(
      429,
      errorBody('rate_limited'),
      headers: {
        if (retryAfter != null) 'retry-after': [retryAfter],
      },
    );

    for (final (id, header) in [
      ('025', null),
      ('027', 'Wed, 21 Oct 2026 07:28:00 GMT'),
    ]) {
      testWidgets('TC-ERR-$id Retry-After ${header ?? 'missing'}: never '
          'retried by itself', (tester) async {
        final app = await lookUp(tester, always(limited(header)));
        await tester.pump(const Duration(seconds: 90));
        await tester.pumpAndSettle();
        expect(app.backend.sent('POST', 'lookups'), hasLength(1));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('TC-ERR-026 Retry-After 0: a retry is possible at once', (
      tester,
    ) async {
      final app = await lookUp(tester, always(limited('0')));
      expect(find.textContaining('in 0 s'), findsNothing);
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(app.backend.sent('POST', 'lookups'), hasLength(2));
    });

    testWidgets('TC-ERR-028 Retry-After 86400 fits and blocks', (
      tester,
    ) async {
      final app = await lookUp(tester, always(limited('86400')));
      expect(
        find.textContaining('Too many attempts. Try again in 86'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(app.backend.sent('POST', 'lookups'), hasLength(1));
    });

    testWidgets('TC-ERR-029 leaving and returning during a countdown', (
      tester,
    ) async {
      final app = await lookUp(tester, always(limited('60')));
      await app.tap(tab('History'));
      await tester.pump(const Duration(seconds: 10));
      await app.tap(tab('Check'));
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      final afterReturn = app.backend.sent('POST', 'lookups').length;
      expect(afterReturn, lessThanOrEqualTo(2));
      await tester.pump(const Duration(seconds: 90));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'lookups'), hasLength(afterReturn));
    });
  });

  testWidgets('TC-ERR-031 a request timeout', (tester) async {
    await history(tester, timedOut());
    expect(
      find.text('No connection. Check the internet and try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('TC-ERR-034 the connection lost during a next page', (
    tester,
  ) async {
    final app = await history(
      tester,
      (r) => r.queryParameters['cursor'] == null
          ? FakeBackend.example(200, 'History of checks', '200 First page')
          : offline()(r),
    );
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('1000001'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(
      app.backend
          .sent('GET', 'checks')
          .where(
            (r) => r.queryParameters['cursor'] != null,
          ),
      hasLength(1),
    );
  });
}
