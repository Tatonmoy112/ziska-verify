import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 5 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): History and the sessions list, on the server's real
/// answers replayed offline through the whole app (TC-STG-026 … -029).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  Map<String, Answer> server({Answer? checks}) => {
    'GET me': real('me_200.json'),
    'GET formats': real('formats_200.json'),
    'GET checks': checks ?? real('checks_first_page_200.json'),
    'GET lookups/sessions': real('sessions_empty_200.json'),
  };

  Future<FlowApp> openHistory(WidgetTester tester, {Answer? checks}) async {
    final app = await startApp(tester, overrides: server(checks: checks));
    await app.tap(tab('History'));
    return app;
  }

  testWidgets('TC-STG-026 the real first page: the counts, the rows, who '
      'checked, Bangladesh time', (tester) async {
    await openHistory(tester);
    // 13 checks: 1 genuine, 2 need attention, 5 not found, 5 not in a batch.
    expect(historyChipCount(tester, 'all'), 13);
    expect(historyChipCount(tester, 'valid'), 1);
    expect(historyChipCount(tester, 'warning'), 2);
    expect(historyChipCount(tester, 'not_found'), 5);
    expect(historyChipCount(tester, 'unassigned'), 5);
    // The newest: not found, so its reference stands for the serial.
    expect(find.text('MA-2026-000013'), findsWidgets);
    expect(find.text('Checked by Test Official'), findsWidgets);
    // 06:36:39 UTC is 12:36 PM in Dhaka.
    final times = find.byKey(const Key('checkTile.when'));
    expect(
      tester.widget<Text>(times.first).data,
      contains('12:36 PM'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-STG-026 the real "valid" filter: its one check, the '
      'chips still counting every result', (tester) async {
    final app = await openHistory(
      tester,
      // The page for the filter; the chips are counted without it.
      checks: (r) => stagingScripted(
        r.queryParameters['result'] == 'valid'
            ? 'checks_result_valid_200.json'
            : 'checks_first_page_200.json',
      ),
    );
    await app.tap(find.byKey(const Key('history.chip.valid')));
    expect(
      app.backend.sent('GET', 'checks').map((r) => r.queryParameters['result']),
      contains('valid'),
    );
    expect(find.text('MA-2026-000013'), findsNothing);
    // Only the real valid check is listed.
    expect(find.byKey(const Key('checkTile.ref')), findsOneWidget);
    expect(find.text('MA-2026-000005'), findsOneWidget);
    expect(historyChipCount(tester, 'all'), 13);
    expect(historyChipCount(tester, 'valid'), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-STG-027 the real pages and cursors: every check once, '
      'then no more', (tester) async {
    final app = await openHistory(
      tester,
      checks: (r) => stagingScripted(switch (r.queryParameters['cursor']) {
        null => 'checks_by5_page1_200.json',
        '9' => 'checks_by5_page2_200.json',
        _ => 'checks_by5_page3_200.json',
      }),
    );
    // Scroll through to the end.
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await tester.pumpAndSettle();
    }
    final cursors = [
      for (final r in app.backend.sent('GET', 'checks'))
        r.queryParameters['cursor'],
    ];
    expect(cursors, [null, '9', '4']);
    expect(find.text('MA-2026-000001'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-STG-028 a serial search: the real tracking log of serial '
      '1', (tester) async {
    final semantics = tester.ensureSemantics();
    final app = await openHistory(
      tester,
      checks: (r) => stagingScripted(
        r.queryParameters['search'] == '1'
            ? 'checks_search_serial_1_200.json'
            : 'checks_first_page_200.json',
      ),
    );
    await app.enter(const Key('history.search'), '1');
    await app.settleAfter(const Duration(milliseconds: 500));
    expectTrackingLog('1');
    // The heading as TalkBack reads it: always the official's own.
    expect(
      find.bySemanticsLabel(RegExp('Your checks of serial 1')),
      findsOneWidget,
    );
    expect(find.text('Napa Extra 500'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('TC-STG-029 no sessions yet: the real empty list', (
    tester,
  ) async {
    final app = await openHistory(tester);
    await app.tap(find.byKey(const Key('history.view.sessions')));
    expect(find.text('No sessions found.'), findsOneWidget);
    expect(app.backend.sent('GET', 'lookups/sessions'), hasLength(1));
  });
}
