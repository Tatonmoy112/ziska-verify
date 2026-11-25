import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';

class _Verification extends Mock implements VerificationRepository {}

ScanSessionSummary _session(String id) => ScanSessionSummary(
  totals: SessionTotals(
    id: id,
    scanned: 1,
    valid: 1,
    warning: 0,
    notFound: 0,
    unassigned: 0,
  ),
  kind: SessionKind.qr,
  status: ScanStatus.ended,
  startedAt: DateTime.utc(2026, 11, 20, 9),
  lastScanAt: DateTime.utc(2026, 11, 20, 10),
);

const _down = Err<Never>(Failure(InternalErrorException(statusCode: 500)));

/// The wait the server asks for; short, so the tests run in real time.
const _wait = Duration(milliseconds: 80);
const _limited = Err<Never>(
  Failure(RateLimitedException(retryAfter: _wait)),
);

/// TC-MIG-074 … -076 (docs/test-cases/16-mobile-migration.md): Sessions'
/// Try again asks for what failed, as History does (production audit P-21).
void main() {
  setUpAll(() {
    registerFallbackValue(const SessionQuery());
    registerFallbackValue(const PageRequest());
  });

  late _Verification repo;
  late List<(SessionQuery, String?)> sent;
  late List<Result<CursorPage<ScanSessionSummary>>> answers;
  late SessionsCubit cubit;

  setUp(() {
    repo = _Verification();
    sent = [];
    answers = [];
    when(() => repo.sessions(any(), any())).thenAnswer((inv) async {
      final page = inv.positionalArguments[1] as PageRequest;
      sent.add((inv.positionalArguments[0] as SessionQuery, page.cursor));
      return answers.removeAt(0);
    });
    cubit = SessionsCubit(GetSessions(repo));
  });
  tearDown(() => cubit.close());

  final page1 = Success(
    CursorPage(items: [_session('s1'), _session('s2')], nextCursor: 'c2'),
  );
  final page2 = Success(CursorPage(items: [_session('s3')]));

  test('TC-MIG-074 normal: a failed first page is asked for again', () async {
    answers.addAll([_down, page1]);
    await cubit.load();
    expect(cubit.state.list.status, PaginationStatus.failureFirst);

    await cubit.retry();
    expect(sent.map((s) => s.$2), [null, null]);
    expect(cubit.state.list.items.map((s) => s.totals.id), ['s1', 's2']);
  });

  test(
    'TC-MIG-075 edge: a failed page 2 is asked for again; page 1 stays',
    () async {
      answers.addAll([page1, _down, page2]);
      await cubit.load();
      await cubit.more();
      expect(cubit.state.list.status, PaginationStatus.failureMore);
      expect(cubit.state.list.items, hasLength(2));

      await cubit.retry();
      expect(sent.map((s) => s.$2), [null, 'c2', 'c2']);
      expect(cubit.state.list.items.map((s) => s.totals.id), [
        's1',
        's2',
        's3',
      ]);
      expect(cubit.state.list.hasReachedEnd, isTrue);
    },
  );

  group('TC-MIG-076 worst', () {
    test('Try again during a 429 wait sends nothing', () async {
      answers.addAll([page1, _limited]);
      await cubit.load();
      await cubit.more();
      expect(cubit.state.list.isWaiting, isTrue);

      await cubit.retry();
      expect(sent, hasLength(2));
      expect(cubit.state.list.items, hasLength(2));
    });

    test(
      'a filter changed during a page-2 wait: never the old cursor',
      () async {
        const ended = SessionQuery(status: ScanStatus.ended);
        answers.addAll([page1, _limited, page2, page2]);
        await cubit.load();
        await cubit.more();
        // Held until the wait ends: the filter shows Ended, the list is
        // still page 1 of All, with its failed page 2 and cursor.
        await cubit.load(ended);
        expect(cubit.state.list.status, PaginationStatus.failureMore);
        expect(cubit.state.list.nextCursor, 'c2');

        // The moment the wait is over, before the held load runs: Try
        // again starts the Ended list, never All's cursor with Ended.
        await withClock(
          Clock.fixed(clock.now().add(_wait * 2)),
          () => cubit.retry(),
        );
        expect(sent, hasLength(3));
        expect(sent[2].$1.status, ScanStatus.ended);
        expect(sent[2].$2, isNull, reason: 'a new list starts at page 1');

        await Future<void>.delayed(_wait * 2); // the held load, harmless
        for (final (query, cursor) in sent.skip(2)) {
          expect(query.status, ScanStatus.ended);
          expect(cursor, isNull, reason: "All's cursor sent with Ended");
        }
      },
    );
  });
}
