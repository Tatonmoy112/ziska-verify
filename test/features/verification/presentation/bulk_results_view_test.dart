import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/bulk_results_view.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

BulkRow _row(String label, LookupOutcome outcome, String ref) => BulkRow(
  way: LookupWay.serial,
  label: label,
  result: LookupResult(ref: ref, outcome: outcome, reasons: const []),
);

void main() {
  final outcome = BulkOutcome(
    summary: const BulkSummary(
      total: 3,
      valid: 1,
      warning: 1,
      byReason: {LookupReason.expired: 1},
      notFound: 1,
      unassigned: 0,
    ),
    rows: [
      _row('1000001', LookupOutcome.valid, 'MA-1'),
      _row('1000002', LookupOutcome.warning, 'MA-2'),
      _row('1000003', LookupOutcome.notFound, 'MA-3'),
    ],
  );

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BulkResultsView(
          outcome: outcome,
          onOpen: (_) {},
          onNewList: () {},
        ),
      ),
    ),
  );

  testWidgets('shows the summary and every row in the order sent', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('1. 1000001'), findsOneWidget);
    expect(find.text('2. 1000002'), findsOneWidget);
    expect(find.text('3. 1000003'), findsOneWidget);
  });

  testWidgets('can show only the items that need attention', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('bulk.onlyAttention')));
    await tester.pumpAndSettle();
    expect(find.text('1. 1000001'), findsNothing);
    expect(find.text('2. 1000002'), findsOneWidget);
    expect(find.text('3. 1000003'), findsOneWidget);
  });
}
