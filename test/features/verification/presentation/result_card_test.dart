import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<void> pump(WidgetTester tester, LookupResult result) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerificationResultCard(result: result),
            ),
          ),
        ),
      );

  // TC-LOOK-007: Every result has its own display.
  testWidgets('every result shows its own title and the reference', (
    tester,
  ) async {
    final titles = {
      LookupOutcome.valid: 'Genuine product',
      LookupOutcome.warning: 'Genuine, needs attention',
      LookupOutcome.notFound: 'Not found',
      LookupOutcome.unassigned: 'Not in a batch',
      LookupOutcome.unknown: 'Unable to check',
    };
    for (final MapEntry(key: outcome, value: title) in titles.entries) {
      await pump(
        tester,
        LookupResult(ref: 'MA-$outcome', outcome: outcome, reasons: const []),
      );
      expect(find.text(title), findsOneWidget, reason: '$outcome');
      expect(find.text('MA-$outcome'), findsOneWidget);
    }
  });

  // TC-LOOK-009: Unknown result is never genuine.
  testWidgets('an unknown result is never shown as genuine', (tester) async {
    await pump(
      tester,
      const LookupResult(
        ref: 'R',
        outcome: LookupOutcome.unknown,
        reasons: [],
      ),
    );
    expect(find.text('Genuine product'), findsNothing);
    expect(find.text('Unable to check'), findsOneWidget);
  });

  // TC-LOOK-008: Every warning reason shown.
  testWidgets('a warning shows every reason, with the check count', (
    tester,
  ) async {
    await pump(
      tester,
      LookupResult(
        ref: 'R',
        outcome: LookupOutcome.warning,
        reasons: const [
          LookupReason.checkedBefore,
          LookupReason.recalled,
          LookupReason.expired,
          LookupReason.damaged,
          LookupReason.switchedOff,
          LookupReason.unknown,
        ],
        count: CheckCount(
          thisCheck: 3,
          lastAt: DateTime.utc(2026, 10, 12, 9, 14),
        ),
      ),
    );
    // `checked_before` is the badge and the check number; every other
    // reason is a row (final.md §13.1).
    expect(find.text('CHECKED BEFORE'), findsOneWidget);
    for (final label in [
      'Batch recalled',
      'Expired',
      'Marked damaged',
      'Batch switched off',
      'Needs attention',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // 09:14 UTC is 3:14 PM in Bangladesh (final.md §16).
    expect(find.textContaining('check number 3'), findsOneWidget);
    expect(find.textContaining('3:14'), findsOneWidget);
  });
}
