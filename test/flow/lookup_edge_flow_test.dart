import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: single lookup edge, worst, and failure cases
/// (docs/test-cases/04-lookup.md, TC-LOOK-020 and later). The input rules
/// themselves are unit tests in `input_preparation_test.dart`.
void main() {
  const formatsFailed = 'Could not load the code formats.';
  const general = 'Something went wrong. Try again.';
  const lookupNetwork = 'Unable to check. Check the connection and try again.';
  const lookupLost =
      'The answer was lost. This check may already be recorded; checking '
      'again counts as another check.';
  final input = find.byKey(const Key('verify.input'));

  /// A `POST lookups` answer (app API guide §4.2).
  ScriptedAnswer lookup({
    String result = 'valid',
    List<String> reasons = const [],
    Map<String, Object?> count = const {'this_check': 1, 'last_at': null},
    Map<String, Object?>? item,
    Map<String, Object?> extra = const {},
  }) => ok({
    'ref': 'MA-2026-000777',
    'result': result,
    'reasons': reasons,
    if (result == 'valid' || result == 'warning') ...{
      'count': count,
      'item':
          item ??
          {
            'serial': '1000001',
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
    ...extra,
  });

  Map<String, Object?> formats({int maxDigits = 19}) => {
    'hidden_code': [
      {'length': 12, 'characters': '0123456789'},
    ],
    'serial': {'max_digits': maxDigits},
    'qr': {'length': 12, 'characters': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'},
  };

  Future<FlowApp> lookUp(
    WidgetTester tester,
    Answer answer, {
    String serial = '1000001',
  }) async {
    final app = await startApp(tester, overrides: {'POST lookups': answer});
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
    return app;
  }

  group('Formats', () {
    testWidgets('TC-LOOK-020 formats fail to load, then Try again', (
      tester,
    ) async {
      var calls = 0;
      final app = await startApp(
        tester,
        overrides: {
          'GET formats': (_) => calls++ == 0
              ? apiError(500, 'internal_error', requestId: 'req-f')
              : ok(formats()),
        },
      );
      expect(find.textContaining(formatsFailed), findsOneWidget);
      expect(find.textContaining(general), findsOneWidget);
      expect(find.textContaining('req-f'), findsOneWidget);
      expect(input, findsNothing);

      await app.tapText('Try again');
      expect(input, findsOneWidget);
    });

    testWidgets('TC-LOOK-021 formats offline', (tester) async {
      var online = false;
      final app = await startApp(
        tester,
        overrides: {
          'GET formats': (r) => online ? ok(formats()) : offline()(r),
        },
      );
      expect(find.textContaining(formatsFailed), findsOneWidget);
      expect(find.textContaining('No connection.'), findsOneWidget);
      online = true;
      await app.tapText('Try again');
      expect(input, findsOneWidget);
    });

    testWidgets('TC-LOOK-022 formats load once per session', (tester) async {
      final app = await startApp(tester);
      await app.tap(tab('History'));
      await app.tap(tab('Check'));
      for (var i = 0; i < 3; i++) {
        await app.enter(const Key('verify.input'), '1000001');
        await app.tap(find.byKey(const Key('verify.submit')));
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      expect(app.backend.sent('GET', 'formats'), hasLength(1));
      expect(app.backend.sent('POST', 'lookups'), hasLength(3));
    });

    testWidgets('TC-LOOK-024 the serial length comes from the formats', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        overrides: {'GET formats': always(ok(formats(maxDigits: 10)))},
      );
      expect(find.text('Up to 10 digits'), findsOneWidget);
      await app.enter(const Key('verify.input'), '12345678901');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(
        find.text('A serial has digits only, up to 10 digits.'),
        findsOneWidget,
      );
      expect(app.backend.sent('POST', 'lookups'), isEmpty);
    });
  });

  group('Input on the screen', () {
    testWidgets('TC-LOOK-030 a serial pasted with a letter is refused, '
        'never changed', (tester) async {
      final app = await startApp(tester);
      await app.enter(const Key('verify.input'), '10O0001');
      await app.tap(find.byKey(const Key('verify.submit')));

      for (final r in app.backend.sent('POST', 'lookups')) {
        expect((r.data as Map)['value'], isNot('100001'));
      }
      expect(app.backend.sent('POST', 'lookups'), isEmpty);
      expect(
        find.text('A serial has digits only, up to 19 digits.'),
        findsOneWidget,
      );
    });

    // TC-LOOK-132 (emulator run, finding F-1): a refused serial's message is
    // about what was typed; it goes as soon as the text changes. A failure
    // after sending is about the check, not the text: it stays.
    group('TC-LOOK-132 a refused serial message goes with the text', () {
      const refused = 'A serial has digits only, up to 19 digits.';

      Future<FlowApp> refuse(WidgetTester tester) async {
        final app = await startApp(tester);
        await app.enter(const Key('verify.input'), '10O0001');
        await app.tap(find.byKey(const Key('verify.submit')));
        expect(find.text(refused), findsOneWidget);
        return app;
      }

      testWidgets('the field emptied', (tester) async {
        final app = await refuse(tester);
        await app.enter(const Key('verify.input'), '');
        expect(find.text(refused), findsNothing);
        expect(app.enabled(const Key('verify.submit')), isFalse);
        expect(app.backend.sent('POST', 'lookups'), isEmpty);
      });

      testWidgets('the serial corrected', (tester) async {
        final app = await refuse(tester);
        await app.enter(const Key('verify.input'), '1000001');
        expect(find.text(refused), findsNothing);
        expect(app.backend.sent('POST', 'lookups'), isEmpty);
      });

      testWidgets('a lost answer stays when the text changes', (tester) async {
        final app = await startApp(
          tester,
          overrides: {'POST lookups': timedOut()},
        );
        await app.enter(const Key('verify.input'), '1000001');
        await app.tap(find.byKey(const Key('verify.submit')));
        final lost = find.textContaining('may already be recorded');
        expect(lost, findsOneWidget);
        await app.enter(const Key('verify.input'), '1000002');
        expect(lost, findsOneWidget);
      });
    });

    testWidgets('TC-LOOK-031 empty input: Verify product disabled', (
      tester,
    ) async {
      final app = await startApp(tester);
      expect(app.enabled(const Key('verify.submit')), isFalse);
    });
  });

  group('Results', () {
    testWidgets('TC-LOOK-043 every reason at once', (tester) async {
      await lookUp(
        tester,
        always(
          lookup(
            result: 'warning',
            reasons: [
              'checked_before',
              'recalled',
              'expired',
              'damaged',
              'switched_off',
            ],
            count: {'this_check': 3, 'last_at': '2026-10-12T09:14:00Z'},
          ),
        ),
      );
      expect(find.text('Genuine, needs attention'), findsOneWidget);
      // `checked_before` is the badge and the check number; the others
      // are rows (final.md Section 13.1.4).
      expect(find.text('CHECKED BEFORE'), findsOneWidget);
      expect(find.textContaining('check number 3'), findsOneWidget);
      for (final reason in [
        'Batch recalled',
        'Expired',
        'Marked damaged',
        'Batch switched off',
      ]) {
        expect(find.text(reason), findsOneWidget, reason: reason);
      }
    });

    testWidgets('TC-LOOK-044 an unknown reason next to a known one', (
      tester,
    ) async {
      await lookUp(
        tester,
        always(lookup(result: 'warning', reasons: ['expired', 'new_reason'])),
      );
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Needs attention'), findsOneWidget);
      // TC-LOOK-093: without checked_before, the badge says it needs
      // attention and the item shows its product details.
      expect(find.text('NEEDS ATTENTION'), findsOneWidget);
      expect(find.text('PRODUCT DETAILS'), findsOneWidget);
      expect(find.text('TRACKING DETAILS'), findsNothing);
    });

    testWidgets('TC-SEC-027 the picture host never gets the access pass', (
      tester,
    ) async {
      final app = await lookUp(
        tester,
        always(
          lookup(
            item: {
              'serial': '1000001',
              'code': '*****7K2',
              'product': {
                'name': 'Paracetamol 500',
                'generic_name': 'Paracetamol',
                'short_name': 'PCM500',
                'picture_url': 'https://pictures.example.com/53/9f2c.png',
              },
              'batch': {'number': 'B-1042', 'made': null, 'expires': null},
            },
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('PRODUCT IMAGE'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      // Asked of the picture service only, never through the API client
      // (which adds the access pass).
      expect(app.pictures.asked, [
        Uri.parse('https://pictures.example.com/53/9f2c.png'),
      ]);
      expect(
        app.backend.requests.where(
          (r) => r.uri.host == 'pictures.example.com',
        ),
        isEmpty,
      );
    });

    testWidgets('TC-LOOK-045 a warning without reasons is never genuine', (
      tester,
    ) async {
      await lookUp(tester, always(lookup(result: 'warning')));
      expect(find.text('Genuine, needs attention'), findsOneWidget);
      expect(find.text('Genuine product'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-LOOK-046 optional fields null', (tester) async {
      await lookUp(
        tester,
        always(
          lookup(
            item: {
              'serial': '1000001',
              'code': '*****7K2',
              'product': {
                'name': 'Paracetamol 500',
                'generic_name': 'Paracetamol',
                'short_name': null,
                'picture_url': null,
              },
              'batch': {'number': 'B-1042', 'made': null, 'expires': null},
            },
          ),
        ),
      );
      expect(find.text('Genuine product'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-LOOK-048 a first check has no last time', (tester) async {
      await lookUp(tester, always(lookup()));
      expect(find.textContaining('Last check'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    for (final (result, title, body) in [
      (
        'not_found',
        'Not found',
        'No product of this company has this serial or QR code.',
      ),
      (
        'unassigned',
        'Not in a batch',
        'This item exists but has not been given to a batch yet.',
      ),
    ]) {
      testWidgets('TC-LOOK-049 $result shows no item', (tester) async {
        await lookUp(tester, always(lookup(result: result)));
        // The title, and the result row of WHAT YOU ENTERED.
        expect(find.text(title), findsNWidgets(2));
        expect(find.text(body), findsOneWidget);
        expect(find.textContaining('MA-2026-000777'), findsNWidgets(2));
        expect(find.text('Batch'), findsNothing);
        expect(find.text('Product'), findsNothing);
      });
    }

    testWidgets('TC-LOOK-050 very long product names fit', (tester) async {
      final long = 'Paracetamol ' * 17;
      await lookUp(
        tester,
        always(
          lookup(
            item: {
              'serial': '1000001',
              'code': '*****7K2',
              'product': {
                'name': long,
                'generic_name': long,
                'short_name': 'PCM500',
                'picture_url': null,
              },
              'batch': {
                'number': 'B-1042',
                'made': '2026-01-10',
                'expires': '2027-09-30',
              },
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.textContaining('MA-2026-000777'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('MA-2026-000777'), findsOneWidget);
    });

    testWidgets('TC-LOOK-051 a very high check number fits', (tester) async {
      await lookUp(
        tester,
        always(
          lookup(
            result: 'warning',
            reasons: ['checked_before'],
            count: {'this_check': 99999, 'last_at': '2026-10-12T09:14:00Z'},
          ),
        ),
      );
      expect(
        find.textContaining('This is check number 99999 of this item.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-LOOK-052 the last check in Bangladesh time', (
      tester,
    ) async {
      await lookUp(
        tester,
        always(
          lookup(
            result: 'warning',
            reasons: ['checked_before'],
            count: {'this_check': 2, 'last_at': '2026-10-12T20:30:00Z'},
          ),
        ),
      );
      // 20:30 UTC is 02:30 the next day in Dhaka (UTC+6): in the top card
      // and as the previous check of TRACKING DETAILS.
      expect(find.textContaining('Oct 13, 2026'), findsNWidgets(2));
      expect(find.textContaining('2:30'), findsNWidgets(2));
    });

    testWidgets('TC-LOOK-055 unknown fields are ignored', (tester) async {
      await lookUp(
        tester,
        always(
          lookup(
            extra: {
              'new_field': {'a': 1},
            },
          ),
        ),
      );
      expect(find.text('Genuine product'), findsOneWidget);
    });
  });

  group('Errors', () {
    testWidgets('TC-LOOK-056 a 400 answer', (tester) async {
      await lookUp(tester, always(apiError(400, 'validation_failed')));
      expect(find.text(general), findsOneWidget);
      expect(find.textContaining('req-1'), findsOneWidget);
    });

    testWidgets('TC-LOOK-057 a rate-limited lookup counts down', (
      tester,
    ) async {
      var calls = 0;
      final app = await lookUp(
        tester,
        (_) => calls++ == 0
            ? apiError(429, 'rate_limited', retryAfter: 15)
            : lookup(),
      );
      expect(
        find.text('Too many attempts. Try again in 15 s.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Too many attempts. Try again in 14 s.'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text('Genuine product'), findsOneWidget);
    });

    testWidgets('TC-LOOK-058 client switched off', (tester) async {
      await lookUp(tester, always(apiError(404, 'not_found')));
      expect(find.text('Not available.'), findsOneWidget);
    });

    testWidgets('TC-LOOK-059 500, then 503', (tester) async {
      await lookUp(tester, always(apiError(500, 'internal_error')));
      expect(find.text(general), findsOneWidget);
      await lookUp(tester, always(apiError(503, 'service_unavailable')));
      expect(
        find.text('The service is busy. Try again shortly.'),
        findsOneWidget,
      );
    });

    // Audit 4.2: a timeout after sending is a lost answer, and the check
    // may already be recorded; checking again counts as another check.
    testWidgets('TC-LOOK-060 a timeout: the answer was lost', (tester) async {
      await lookUp(tester, timedOut());
      expect(find.text(lookupLost), findsOneWidget);
      expect(find.text(lookupNetwork), findsNothing);
    });

    for (final (name, answer) in [
      (
        'cut-off JSON',
        const ScriptedAnswer.raw(
          200,
          '{"success": true, "data": {"ref": "MA',
          contentType: 'application/json',
        ),
      ),
      ('data null', ScriptedAnswer(200, okBody(null))),
    ]) {
      testWidgets('TC-LOOK-061 a broken answer ($name) is never a result', (
        tester,
      ) async {
        await lookUp(tester, always(answer));
        expect(find.text('Genuine product'), findsNothing);
        expect(find.text('Check result'), findsNothing);
        expect(input, findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // Audit (final.md Section 13.7): without the formats only the serial form
  // waits; scanning and the tools need no formats.
  testWidgets('TC-LOOK-120 a formats failure keeps the camera and the '
      'tools', (tester) async {
    var calls = 0;
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'GET formats': (r) async => calls++ == 0
            ? offline()(r)
            : FakeBackend.example(200, 'Input formats', '200 The formats'),
      },
    );
    expect(find.byKey(const Key('verify.formatsRetry')), findsOneWidget);
    expect(find.byKey(const Key('verify.input')), findsNothing);
    expect(find.byKey(const Key('verify.camera')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('verify.tool.bulk')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('verify.tool.bulk')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('verify.formatsRetry')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(const Key('verify.formatsRetry')));
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
  });

  // Audit (guide §4.6, FR-LKP-02): after a failed lookup the same QR can be
  // scanned again; nothing is sent again by itself.
  testWidgets('TC-LOOK-121 Scan again after a failed QR lookup', (
    tester,
  ) async {
    var calls = 0;
    final app = await startApp(
      tester,
      overrides: {
        'POST lookups': (r) async => calls++ == 0
            ? offline()(r)
            : FakeBackend.example(
                200,
                'Look up one item',
                '200 valid: genuine, first check',
              ),
      },
    );
    const qr = 'https://www.ziskaverify.com/q/Q8F2KD91XA7M';
    app.scanner.scan(qr);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner.scanAgain')), findsOneWidget);
    expect(app.backend.sent('POST', 'lookups'), hasLength(1));

    await app.tap(find.byKey(const Key('scanner.scanAgain')));
    app.scanner.scan(qr);
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'lookups'), hasLength(2));
    expect(find.text('Genuine product'), findsWidgets);
  });

  // Data-flow audit A2 (guide §1): the scanner says the formats failed and
  // offers Try again; it never spins.
  testWidgets('TC-LOOK-122 the camera shows a formats failure', (
    tester,
  ) async {
    var calls = 0;
    final app = await startApp(
      tester,
      overrides: {
        'GET formats': (r) async => calls++ < 1
            ? offline()(r)
            : FakeBackend.example(200, 'Input formats', '200 The formats'),
      },
    );
    // The camera says why it cannot check yet; Try again is under it.
    expect(
      find.descendant(
        of: find.byKey(const Key('verify.camera')),
        matching: find.text('Scanning waits for the code formats.'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('scanner.status')), findsNothing);
    await app.tap(find.byKey(const Key('verify.formatsRetry')));
    expect(find.byKey(const Key('verify.formatsRetry')), findsNothing);
    // A scan now is sent.
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'lookups'), hasLength(1));
  });

  testWidgets('TC-LOOK-123 a 429 on the formats counts down before Retry', (
    tester,
  ) async {
    var calls = 0;
    final app = await startApp(
      tester,
      overrides: {
        'GET formats': (_) => calls++ == 0
            ? apiError(429, 'rate_limited', retryAfter: 20)
            : FakeBackend.example(200, 'Input formats', '200 The formats'),
      },
    );
    final retry = find.byKey(const Key('verify.formatsRetry'));
    expect(
      find.descendant(
        of: retry,
        matching: find.text('Too many attempts. Try again in 20 s.'),
      ),
      findsOneWidget,
    );
    await tester.tap(retry, warnIfMissed: false);
    await tester.pump();
    expect(app.backend.sent('GET', 'formats'), hasLength(1));

    await tester.pump(const Duration(seconds: 21));
    await app.tap(retry);
    expect(retry, findsNothing);
    expect(app.backend.sent('GET', 'formats'), hasLength(2));
  });
}
