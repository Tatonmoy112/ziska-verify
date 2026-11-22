import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: History edge, worst, and failure cases
/// (docs/test-cases/06-history.md, TC-HIST-015 and later). Query building
/// and paging races are unit and BLoC tests.
void main() {
  const general = 'Something went wrong. Try again.';

  Map<String, Object?> check(
    String ref, {
    String result = 'valid',
    List<String> reasons = const [],
    String? serial = '1000001',
    String? product = 'Paracetamol 500',
    String? batch = 'B-1042',
    String official = 'Asha Rao',
  }) => {
    'ref': ref,
    'at': '2026-10-28T10:02:11Z',
    'way': 'qr',
    'result': result,
    'reasons': reasons,
    'serial': serial,
    'product': product,
    'batch': batch,
    'official': official,
  };

  ScriptedAnswer page(
    List<Map<String, Object?>> checks, {
    Map<String, Object?>? totals,
    String? next,
  }) => ok({'checks': checks, 'totals': totals, 'next_cursor': next});

  const totals = {
    'total': 120,
    'valid': 80,
    'warning': 30,
    'not_found': 9,
    'unassigned': 1,
  };

  Future<FlowApp> openHistory(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, profile: profile, overrides: overrides);
    await app.tap(tab('History'));
    return app;
  }

  List<Map<String, dynamic>> checksSent(FlowApp app) => [
    for (final r in app.backend.sent('GET', 'checks')) r.queryParameters,
  ];

  /// Opens Filters → Choose dates, types [start] and [end] (MM/DD/YYYY),
  /// and confirms. Returns whether the picker closed.
  Future<bool> pickDates(
    FlowApp app,
    WidgetTester tester,
    String start,
    String end,
  ) async {
    // The test font draws every glyph a full square: Flutter's own picker
    // header needs a wider screen here than on a phone.
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();
    await app.tap(find.byKey(const Key('history.filters')));
    await app.tapText('Choose dates');
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(DateRangePickerDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), start);
    await tester.enterText(fields.at(1), end);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    return find.byType(DateRangePickerDialog).evaluate().isEmpty;
  }

  group('Dates (Bangladesh calendar)', () {
    // 2026-11-10 06:00 in Dhaka.
    final now = DateTime.utc(2026, 11, 10);

    testWidgets('TC-HIST-015 a range ending before it starts is refused', (
      tester,
    ) async {
      await withClock(Clock.fixed(now), () async {
        final app = await openHistory(tester);
        final closed = await pickDates(app, tester, '10/28/2026', '10/01/2026');
        expect(closed, isFalse);
        expect(find.text('Invalid range.'), findsOneWidget);
        for (final q in checksSent(app)) {
          expect(q.containsKey('from'), isFalse);
        }
      });
    });

    testWidgets('TC-HIST-016 a one-day range; TC-HIST-017 YYYY-MM-DD', (
      tester,
    ) async {
      await withClock(Clock.fixed(now), () async {
        var app = await openHistory(tester);
        expect(
          await pickDates(app, tester, '10/28/2026', '10/28/2026'),
          isTrue,
        );
        await app.tapText('Apply');
        expect(checksSent(app).last['from'], '2026-10-28');
        expect(checksSent(app).last['to'], '2026-10-28');

        app = await openHistory(tester);
        expect(
          await pickDates(app, tester, '10/01/2026', '10/28/2026'),
          isTrue,
        );
        await app.tapText('Apply');
        expect(checksSent(app).last['from'], '2026-10-01');
        expect(checksSent(app).last['to'], '2026-10-28');
      });
    });

    testWidgets('TC-HIST-018 "today" is the Bangladesh date', (tester) async {
      // 20:00 UTC on 9 Nov is already 02:00 on 10 Nov in Dhaka.
      await withClock(Clock.fixed(DateTime.utc(2026, 11, 9, 20)), () async {
        final app = await openHistory(tester);
        expect(
          await pickDates(app, tester, '11/10/2026', '11/10/2026'),
          isTrue,
        );
        await app.tapText('Apply');
        expect(checksSent(app).last['to'], '2026-11-10');
      });
    });
  });

  testWidgets('TC-HIST-023 no match for the filters', (tester) async {
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (r) => r.queryParameters['result'] == 'warning'
            ? page([])
            : FakeBackend.example(200, 'History of checks', '200 First page'),
      },
    );
    await app.tap(find.byKey(const Key('history.chip.warning')));
    expect(find.text('No checks'), findsOneWidget);
    expect(find.text('No check matches these filters.'), findsOneWidget);
  });

  // Audit (§14.2): a new official has no checks; there is no filter to blame.
  testWidgets('TC-HIST-049 no checks yet, without filters', (tester) async {
    await openHistory(tester, overrides: {'GET checks': (r) => page([])});
    expect(find.text('No checks'), findsOneWidget);
    expect(
      find.text('Your checks appear here after your first check.'),
      findsOneWidget,
    );
    expect(find.text('No check matches these filters.'), findsNothing);
  });

  testWidgets('TC-HIST-025 a 1-character search waits, then sends once', (
    tester,
  ) async {
    final app = await openHistory(tester);
    final before = app.backend.sent('GET', 'checks').length;
    await tester.enterText(find.byKey(const Key('history.search')), '1');
    await tester.pump(const Duration(milliseconds: 300));
    expect(app.backend.sent('GET', 'checks'), hasLength(before));
    await app.settleAfter(const Duration(milliseconds: 200));
    final searched = checksSent(
      app,
    ).where((q) => q['search'] == '1' && q['cursor'] == null);
    expect(searched, hasLength(1));
  });

  testWidgets('TC-HIST-026 a very long search answered 400', (tester) async {
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (r) => r.queryParameters['search'] != null
            ? apiError(400, 'validation_failed', requestId: 'req-long')
            : FakeBackend.example(200, 'History of checks', '200 First page'),
      },
    );
    await app.enter(const Key('history.search'), '9' * 200);
    await app.settleAfter(const Duration(milliseconds: 500));
    expect(find.text(general), findsOneWidget);
    expect(find.textContaining('req-long'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-HIST-032 a rate-limited next page counts down and waits', (
    tester,
  ) async {
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (r) => r.queryParameters['cursor'] == null
            ? FakeBackend.example(200, 'History of checks', '200 First page')
            : apiError(429, 'rate_limited', retryAfter: 10),
      },
    );
    expect(find.text('1000001'), findsOneWidget);
    final pageRequests = checksSent(app).where((q) => q['cursor'] != null);
    expect(pageRequests, hasLength(1));
    expect(find.text('Too many attempts. Try again in 10 s.'), findsOneWidget);

    // Retry during the countdown sends nothing; nothing is retried by itself.
    await app.tapText('Try again');
    await tester.pump(const Duration(seconds: 5));
    expect(checksSent(app).where((q) => q['cursor'] != null), hasLength(1));

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    await app.tapText('Try again');
    final retried = checksSent(app).where((q) => q['cursor'] != null);
    expect(retried, hasLength(2));
    expect(retried.last['cursor'], '3255');
  });

  testWidgets('TC-HIST-036 totals missing: rows without a totals line', (
    tester,
  ) async {
    await openHistory(
      tester,
      overrides: {
        'GET checks': always(page([check('MA-2026-000301')])),
      },
    );
    expect(find.text('1000001'), findsOneWidget);
    expect(find.textContaining(' checks · '), findsNothing);
  });

  // Guide section 5: "A full page always gives a cursor, so the page
  // after it may be empty" (test-server integration, step 5).
  testWidgets('TC-HIST-050 a cursor, then an empty last page: the list '
      'ends, no error', (tester) async {
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (r) => r.queryParameters['cursor'] == null
            ? page(
                [
                  check('MA-2026-000401'),
                  check('MA-2026-000402', serial: '1000002'),
                ],
                totals: totals,
                next: 'c-2',
              )
            : page([]),
      },
    );
    await tester.pumpAndSettle();
    final sent = app.backend.sent('GET', 'checks');
    expect(sent, hasLength(2));
    expect(sent.last.queryParameters['cursor'], 'c-2');
    expect(find.text('1000001'), findsOneWidget);
    expect(find.text('1000002'), findsOneWidget);
    expect(find.text(general), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Nothing more is asked for.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(app.backend.sent('GET', 'checks'), hasLength(2));
  });

  testWidgets('TC-HIST-037 a first-page error, then Try again', (
    tester,
  ) async {
    var calls = 0;
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (_) => calls++ == 0
            ? apiError(500, 'internal_error', requestId: 'req-h')
            : page([check('MA-2026-000302')], totals: totals),
      },
    );
    expect(find.text(general), findsOneWidget);
    expect(find.textContaining('req-h'), findsOneWidget);
    await app.tapText('Try again');
    expect(find.text('1000001'), findsOneWidget);
  });

  testWidgets('TC-HIST-038 History offline', (tester) async {
    var online = false;
    final app = await openHistory(
      tester,
      overrides: {
        'GET checks': (r) =>
            online ? page([check('MA-2026-000303')]) : offline()(r),
      },
    );
    expect(
      find.text('No connection. Check the internet and try again.'),
      findsOneWidget,
    );
    online = true;
    await app.tapText('Try again');
    expect(find.text('1000001'), findsOneWidget);
  });

  testWidgets('TC-HIST-039 rows without serial, product, or batch', (
    tester,
  ) async {
    await openHistory(
      tester,
      overrides: {
        'GET checks': always(
          page([
            check(
              'MA-2026-000304',
              result: 'not_found',
              serial: null,
              product: null,
              batch: null,
            ),
            check(
              'MA-2026-000305',
              result: 'unassigned',
              product: null,
              batch: null,
            ),
          ]),
        ),
      },
    );
    expect(find.text('MA-2026-000304'), findsWidgets);
    expect(find.textContaining('null'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-HIST-040 every reason on a row', (tester) async {
    await openHistory(
      tester,
      overrides: {
        'GET checks': always(
          page([
            check(
              'MA-2026-000306',
              result: 'warning',
              reasons: ['checked_before', 'expired'],
            ),
          ]),
        ),
      },
    );
    expect(find.textContaining('Checked before'), findsOneWidget);
    expect(find.textContaining('Expired'), findsOneWidget);
  });

  testWidgets('TC-HIST-045 no history left after logout', (tester) async {
    var who = 'R1';
    final app = await openHistory(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'GET checks': (_) => page([
          check('MA-$who-0001', serial: who == 'R1' ? '7000001' : '8000001'),
        ]),
      },
    );
    expect(find.text('7000001'), findsOneWidget);

    await app.tap(tab('Profile'));
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log out'),
      ),
    );
    who = 'R2';
    app.backend.profile = Roles.fieldInspector;
    await logInWithCode(app);
    await app.tap(tab('History'));

    expect(find.text('8000001'), findsOneWidget);
    expect(find.text('7000001'), findsNothing);
    expect(find.textContaining('MA-R1'), findsNothing);
  });

  testWidgets('TC-HIST-046 nothing is kept on the phone', (tester) async {
    final first = await openHistory(tester);
    expect(find.text('1000001'), findsOneWidget);

    await startApp(
      tester,
      storage: first.storage,
      overrides: {'GET checks': offline()},
    );
    await tester.tap(tab('History'));
    await tester.pumpAndSettle();
    expect(find.text('1000001'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
  });
}
