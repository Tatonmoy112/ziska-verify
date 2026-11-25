import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/session_summary_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_summary_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

final _session = ScanSessionSummary(
  totals: const SessionTotals(
    id: 'S-1',
    scanned: 3,
    valid: 3,
    warning: 0,
    notFound: 0,
    unassigned: 0,
  ),
  kind: SessionKind.qr,
  status: ScanStatus.ended,
  startedAt: DateTime.utc(2026, 11, 25, 9),
  lastScanAt: DateTime.utc(2026, 11, 25, 10),
);

const _limited = Err<ScanSessionSummary>(
  Failure(RateLimitedException(retryAfter: Duration(seconds: 30))),
);

/// TC-MIG-089 … -091 (docs/test-cases/16-mobile-migration.md): one
/// session's summary loads through a cubit, and a `429` is waited out like
/// every other load (guide §1; production audit P-39).
void main() {
  late List<Result<ScanSessionSummary>> answers;
  late int asked;
  SessionSummaryCubit cubit() {
    final c = SessionSummaryCubit(() async {
      asked++;
      return answers.removeAt(0);
    });
    addTearDown(c.close);
    return c;
  }

  setUp(() {
    answers = [];
    asked = 0;
  });

  group('TC-MIG-089 normal: the summary loads', () {
    test('loading, then the session', () async {
      answers.add(Success(_session));
      final c = cubit();
      expect(c.state.status, SessionSummaryStatus.loading);
      await c.load();
      expect(c.state.status, SessionSummaryStatus.ready);
      expect(c.state.session, same(_session));
    });
  });

  group('TC-MIG-090 edge: Try again, and a load that runs', () {
    test('a failure, then Try again', () async {
      answers.addAll([
        const Err(Failure(InternalErrorException(statusCode: 500))),
        Success(_session),
      ]);
      final c = cubit();
      await c.load();
      expect(c.state.status, SessionSummaryStatus.failed);
      expect(c.state.isWaiting, isFalse);
      await c.load();
      expect(c.state.status, SessionSummaryStatus.ready);
    });

    test('a second load while one runs is not sent', () async {
      final held = Completer<Result<ScanSessionSummary>>();
      final c = SessionSummaryCubit(() {
        asked++;
        return held.future;
      });
      addTearDown(c.close);
      final first = c.load();
      await c.load();
      expect(asked, 1);
      held.complete(Success(_session));
      await first;
    });
  });

  group('TC-MIG-091 worst: a 429 is waited out', () {
    test('Try again during the wait sends nothing; after it, it does', () {
      var now = DateTime.utc(2026, 11, 25, 9);
      return withClock(Clock(() => now), () async {
        answers.addAll([_limited, Success(_session)]);
        final c = cubit();
        await c.load();
        expect(c.state.status, SessionSummaryStatus.failed);
        expect(c.state.isWaiting, isTrue);
        await c.load();
        expect(asked, 1, reason: 'nothing during the wait');
        now = now.add(const Duration(seconds: 31));
        await c.load();
        expect(asked, 2);
        expect(c.state.status, SessionSummaryStatus.ready);
      });
    });

    testWidgets('the card counts the wait down on Try again', (tester) async {
      answers.add(_limited);
      final c = cubit();
      await tester.runAsync(c.load);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider.value(
              value: c,
              child: const SessionSummaryCard(),
            ),
          ),
        ),
      );
      final retry = find.byKey(const Key('session.summary.retry'));
      expect(retry, findsOneWidget);
      expect(tester.widget<TextButton>(retry).onPressed, isNull);
      // The button counts the wait, as the banner says it.
      expect(
        find.descendant(of: retry, matching: find.textContaining('30')),
        findsOneWidget,
      );
    });
  });
}
