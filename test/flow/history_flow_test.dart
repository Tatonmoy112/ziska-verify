import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/shared/design_system/components/chips/count_chip.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: HIST (docs/test-cases/06-history.md).
void main() {
  Future<void> openHistory(FlowApp app) => app.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('History'),
    ),
  );

  testWidgets('TC-HIST-001 no checks: the empty state', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'GET checks': (_) => FakeBackend.example(
          200,
          'History of checks',
          '200 A later page',
        ),
      },
    );
    await openHistory(app);
    expect(find.text('No checks'), findsOneWidget);
  });

  testWidgets('first page: rows and totals (TC-HIST-002 on screen)', (
    tester,
  ) async {
    final app = await startApp(tester);
    await openHistory(app);
    expect(find.text('1000001'), findsOneWidget);
    expect(find.text('MA-2026-000124'), findsOneWidget);
    expectHistoryChipCounts(tester);
  });

  testWidgets('TC-HIST-008 searching a serial shows its tracking log', (
    tester,
  ) async {
    final app = await startApp(tester);
    await openHistory(app);
    await app.enter(const Key('history.search'), '1000001');
    await app.settleAfter(const Duration(milliseconds: 500));

    expectTrackingLog('1000001');
    expect(
      app.backend.sent('GET', 'checks').last.queryParameters['search'],
      '1000001',
    );
  });

  testWidgets('TC-HIST-011 a filter starts again; reset keeps the search', (
    tester,
  ) async {
    final app = await startApp(tester);
    await openHistory(app);
    await app.enter(const Key('history.search'), 'MA-2026');
    await app.settleAfter(const Duration(milliseconds: 500));

    // The first request after a filter change has no cursor. (The fake
    // first page is short, so the next page follows at once.)
    Map<String, dynamic> firstPageAfter(int index) => app.backend
        .sent('GET', 'checks')
        .skip(index)
        .firstWhere(
          (r) =>
              r.queryParameters['cursor'] == null &&
              '${r.queryParameters['limit']}' != '1',
        )
        .queryParameters;

    // A result chip: the first page again, with that result.
    var before = app.backend.sent('GET', 'checks').length;
    await app.tap(find.byKey(const Key('history.chip.warning')));
    final picked = firstPageAfter(before);
    expect(picked['result'], 'warning');
    expect(picked['search'], 'MA-2026');

    // A filter of the sheet: the first page again, with both.
    before = app.backend.sent('GET', 'checks').length;
    await app.tap(find.byKey(const Key('history.filters')));
    await app.tap(find.byKey(const Key('history.way.qr')));
    await app.tapText('Apply');
    final applied = firstPageAfter(before);
    expect(applied['way'], 'qr');
    expect(applied['result'], 'warning');

    // Reset clears the sheet's filters; the search and the chip stay.
    before = app.backend.sent('GET', 'checks').length;
    await app.tapText('Reset');
    final reset = firstPageAfter(before);
    expect(reset.containsKey('way'), isFalse);
    expect(reset['result'], 'warning');
    expect(reset['search'], 'MA-2026');
  });

  testWidgets('TC-HIST-047 the chips keep their counts when one is picked', (
    tester,
  ) async {
    final app = await startApp(tester);
    await openHistory(app);
    expectHistoryChipCounts(tester);
    // No extra request while All is picked: the page's totals are the
    // chips' counts.
    expect(
      app.backend
          .sent('GET', 'checks')
          .where(
            (r) => '${r.queryParameters['limit']}' == '1',
          ),
      isEmpty,
    );

    bool counting(RequestOptions r) => '${r.queryParameters['limit']}' == '1';

    // Another result, same search: the counts still hold and are kept.
    await app.tap(find.byKey(const Key('history.chip.valid')));
    final sent = app.backend.sent('GET', 'checks');
    expect(sent.last.queryParameters['result'], 'valid');
    expect(sent.where(counting), isEmpty);
    expectHistoryChipCounts(tester);
    expect(
      tester
          .widget<CountChip>(find.byKey(const Key('history.chip.valid')))
          .selected,
      isTrue,
    );

    // A new search with a result picked: the page counts that result only,
    // so the chips are counted once more, without the result, one check
    // long.
    await app.enter(const Key('history.search'), '1000001');
    await app.settleAfter(const Duration(milliseconds: 500));
    final counted = app.backend.sent('GET', 'checks').where(counting);
    expect(counted, hasLength(1));
    expect(counted.single.queryParameters.containsKey('result'), isFalse);
    expect(counted.single.queryParameters['search'], '1000001');
    expectHistoryChipCounts(tester);
  });

  testWidgets('TC-HIST-013 pull to refresh asks for the first page again', (
    tester,
  ) async {
    final app = await startApp(tester);
    await openHistory(app);
    final before = app.backend.sent('GET', 'checks').length;

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 500),
      1500,
    );
    await tester.pumpAndSettle();

    expect(app.backend.sent('GET', 'checks').length, greaterThan(before));
    expect(find.text('1000001'), findsOneWidget);
  });

  // Sellers see the history of their own checks only (history:own, the
  // default for retail roles, backend D53; final.md Section 7.2).
  for (final (name, profile) in [
    ('Retail seller', Roles.retailSeller),
    ('Senior seller', Roles.seniorSeller),
  ]) {
    testWidgets('TC-HIST-014 $name sees only their own checks', (
      tester,
    ) async {
      final app = await startApp(tester, profile: profile);
      await openHistory(app);

      // Their checks are listed, with the totals of the first page.
      expect(find.text('1000001'), findsOneWidget);
      expect(historyChipCount(tester, 'all'), 120);

      // Own checks only: no scope is sent, so the server answers "own".
      for (final request in app.backend.sent('GET', 'checks')) {
        expect(request.queryParameters.containsKey('scope'), isFalse);
      }

      // No other officials: no checker's name, no "Everyone's checks".
      expect(find.textContaining('by '), findsNothing);
      await app.tap(find.byKey(const Key('history.filters')));
      expect(find.byKey(const Key('history.scopeAll')), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Item tracking works for sellers too.
      await app.enter(const Key('history.search'), '1000001');
      await app.settleAfter(const Duration(milliseconds: 500));
      expectTrackingLog('1000001');
    });
  }
}
