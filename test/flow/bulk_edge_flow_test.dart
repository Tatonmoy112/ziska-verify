import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: bulk lookup edge, worst, and failure cases
/// (docs/test-cases/05-bulk.md, TC-BULK-015 and later). List rules that
/// need no screen are BLoC tests in `bulk_lookup_bloc_test.dart`.
void main() {
  var refs = 0;

  Map<String, Object?> row(String result, {List<String> reasons = const []}) {
    refs++;
    return {
      'ref': 'MA-2026-${'$refs'.padLeft(6, '0')}',
      'result': result,
      'reasons': reasons,
      if (result == 'valid' || result == 'warning') ...{
        'count': {'this_check': 1, 'last_at': null},
        'item': {
          'serial': '1000001',
          'code': '*****200',
          'product': {
            'name': 'Paracetamol 500',
            'generic_name': 'Paracetamol',
            'short_name': null,
            'picture_url': null,
          },
          'batch': {'number': 'B-1042', 'made': null, 'expires': null},
        },
      },
    };
  }

  /// A `POST lookups/bulk` answer with a summary that matches [rows].
  ScriptedAnswer bulk(List<Map<String, Object?>> rows) {
    int count(String r) => rows.where((x) => x['result'] == r).length;
    final byReason = <String, int>{
      for (final r in [
        'checked_before',
        'expired',
        'recalled',
        'damaged',
        'switched_off',
      ])
        r: rows.where((x) => (x['reasons']! as List).contains(r)).length,
    };
    return ok({
      'summary': {
        'total': rows.length,
        'valid': count('valid'),
        'warning': count('warning'),
        'by_reason': byReason,
        'not_found': count('not_found'),
        'unassigned': count('unassigned'),
      },
      'results': rows,
    });
  }

  Future<FlowApp> openBulk(
    WidgetTester tester, {
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, overrides: overrides);
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    return app;
  }

  Future<void> addSerials(FlowApp app, List<String> serials) async {
    for (final s in serials) {
      await app.enter(const Key('bulk.input'), s);
      await app.tap(find.byKey(const Key('bulk.add')));
    }
  }

  Future<void> send(FlowApp app) => app.tap(find.byKey(const Key('bulk.send')));

  List<Object?> items(FlowApp app, int index) =>
      (app.backend.sent('POST', 'lookups/bulk')[index].data
              as Map<String, dynamic>)['items']
          as List<Object?>;

  testWidgets('TC-BULK-015 an empty list cannot be sent', (tester) async {
    final app = await openBulk(tester);
    expect(
      find.text(
        'Scan QR codes or type serials and hidden codes to build the list.',
      ),
      findsOneWidget,
    );
    final sendButton = find.byKey(const Key('bulk.send'));
    if (sendButton.evaluate().isNotEmpty) {
      await tester.tap(sendButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    expect(app.backend.sent('POST', 'lookups/bulk'), isEmpty);
  });

  testWidgets('TC-BULK-018 mixed ways in one request, in the order added', (
    tester,
  ) async {
    final app = await openBulk(tester);
    await addSerials(app, ['1000001']);
    await app.tapText('Hidden code');
    await app.enter(const Key('bulk.input'), '481516234200');
    await app.tap(find.byKey(const Key('bulk.add')));
    await app.tap(find.byKey(const Key('bulk.scan')));
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    if (find.text('Stop scanning').evaluate().isNotEmpty) {
      await app.tapText('Stop scanning');
    }
    await send(app);

    expect(items(app, 0), [
      {'way': 'serial', 'value': '1000001'},
      {'way': 'hidden_code', 'value': '481516234200'},
      {'way': 'qr', 'value': 'Q8F2KD91XA7M'},
    ]);
  });

  testWidgets('TC-BULK-026 all not found: the switch hides nothing', (
    tester,
  ) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          bulk([row('not_found'), row('not_found'), row('not_found')]),
        ),
      },
    );
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);
    await app.tap(find.byKey(const Key('bulk.onlyAttention')));
    for (final p in ['1.', '2.', '3.']) {
      expect(find.textContaining(p), findsWidgets, reason: p);
    }
    expect(find.text('No item needs attention.'), findsNothing);
  });

  testWidgets('TC-BULK-027 all valid with the switch on', (tester) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          bulk([row('valid'), row('valid'), row('valid')]),
        ),
      },
    );
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);
    await app.tap(find.byKey(const Key('bulk.onlyAttention')));
    expect(find.text('No item needs attention.'), findsOneWidget);
  });

  testWidgets('TC-BULK-028 the summary counts each reason as answered', (
    tester,
  ) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          bulk([
            row('warning', reasons: ['checked_before', 'expired']),
            row('warning', reasons: ['checked_before']),
            row('valid'),
          ]),
        ),
      },
    );
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);

    Finder countFor(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
      matching: find.byType(Text),
    );
    expect(
      tester.widgetList<Text>(countFor('Checked before')).map((t) => t.data),
      contains('2'),
    );
    expect(
      tester.widgetList<Text>(countFor('Expired')).map((t) => t.data),
      contains('1'),
    );
  });

  testWidgets('TC-BULK-029 more results than items is never shown', (
    tester,
  ) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          bulk([row('valid'), row('valid'), row('valid'), row('valid')]),
        ),
      },
    );
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);
    expect(find.text('Summary'), findsNothing);
    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
  });

  testWidgets('TC-BULK-030 typed hidden codes are gone after the results', (
    tester,
  ) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(bulk([row('valid')])),
      },
    );
    await app.tapText('Hidden code');
    await app.enter(const Key('bulk.input'), '481516234200');
    await app.tap(find.byKey(const Key('bulk.add')));
    await send(app);

    expect(find.textContaining('*****200'), findsWidgets);
    expect(find.textContaining('481516234200'), findsNothing);
    await app.tapText('New list');
    expect(find.textContaining('*****200'), findsNothing);
    expect(
      find.text(
        'Scan QR codes or type serials and hidden codes to build the list.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('TC-BULK-031 an unknown result is never valid', (tester) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          bulk([row('valid'), row('something_new')]),
        ),
      },
    );
    await addSerials(app, ['1000001', '1000002']);
    await send(app);
    expect(find.textContaining('Unable to verify'), findsWidgets);
  });

  testWidgets('TC-BULK-032 a 400 answer', (tester) async {
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': always(apiError(400, 'validation_failed')),
      },
    );
    await addSerials(app, ['1000001']);
    await send(app);
    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
    expect(find.textContaining('req-1'), findsOneWidget);
  });

  testWidgets('TC-BULK-033 the same list is sent after the wait', (
    tester,
  ) async {
    var calls = 0;
    final app = await openBulk(
      tester,
      overrides: {
        'POST lookups/bulk': (_) => calls++ == 0
            ? apiError(429, 'rate_limited', retryAfter: 5)
            : bulk([row('valid'), row('valid'), row('valid')]),
      },
    );
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    final again = find.text('Send again');
    await app.tap(
      again.evaluate().isNotEmpty ? again : find.byKey(const Key('bulk.send')),
    );

    expect(app.backend.sent('POST', 'lookups/bulk'), hasLength(2));
    expect(items(app, 1), items(app, 0));
    expect(find.text('Summary'), findsOneWidget);
  });

  testWidgets('TC-BULK-034 back from a row keeps the switch', (tester) async {
    final app = await openBulk(tester);
    await addSerials(app, ['1000001', '1000002', '1000003']);
    await send(app);
    await app.tap(find.byKey(const Key('bulk.onlyAttention')));
    await app.tap(find.textContaining('2.').first);
    expect(find.text('Verification result'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('bulk.onlyAttention')),
    );
    expect(toggle.value, isTrue);
  });
}
