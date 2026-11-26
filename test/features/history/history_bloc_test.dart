import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/check_usecases.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';

class _MockRepo extends Mock implements HistoryRepository {}

CheckRecord _check(String ref) => CheckRecord(
  ref: ref,
  at: DateTime.utc(2026, 10, 28),
  way: CheckWay.qr,
  result: CheckResult.valid,
  reasons: const [],
  official: 'Asha Rao',
);

const _totals = CheckTotals(
  total: 3,
  valid: 3,
  warning: 0,
  notFound: 0,
  unassigned: 0,
);

void main() {
  late _MockRepo repo;
  late List<(CheckQuery, String?)> calls;

  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const PageRequest());
  });

  /// Answers pages by cursor: null → page 1 (cursor "c1"), "c1" → page 2
  /// (empty, end), as a full page followed by an empty one (§10).
  void pages({Result<CheckPage>? second}) {
    calls = [];
    when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
      final query = inv.positionalArguments[0] as CheckQuery;
      final page = inv.positionalArguments[1] as PageRequest;
      calls.add((query, page.cursor));
      if (page.cursor == null) {
        return Success(
          CheckPage(
            page: CursorPage(
              items: [_check('A'), _check('B')],
              nextCursor: 'c1',
            ),
            totals: _totals,
          ),
        );
      }
      return second ?? const Success(CheckPage(page: CursorPage(items: [])));
    });
  }

  setUp(() => repo = _MockRepo());

  HistoryBloc build() => HistoryBloc(GetChecks(repo));

  // TC-HIST-052 and TC-HIST-054: with Bangladesh days chosen, the server's
  // totals count UTC days (guide §5), so the repository gives none. The
  // counts are the kept checks', once the whole list is in, and kept
  // through a refresh; nothing is asked with `limit=1` to count.
  group('Bangladesh days: the counts', () {
    final day = DateTime(2026, 11, 23);
    CheckRecord record(String ref, CheckResult result) => CheckRecord(
      ref: ref,
      at: DateTime.utc(2026, 11, 23, 5),
      way: CheckWay.serial,
      result: result,
      reasons: const [],
      official: 'Asha Rao',
    );

    void datedPages() {
      calls = [];
      when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
        final page = inv.positionalArguments[1] as PageRequest;
        calls.add((inv.positionalArguments[0] as CheckQuery, page.cursor));
        return page.cursor == null
            ? Success(
                CheckPage(
                  page: CursorPage(
                    items: [
                      record('A', CheckResult.valid),
                      record('B', CheckResult.warning),
                    ],
                    nextCursor: 'c1',
                  ),
                ),
              )
            : Success(
                CheckPage(
                  page: CursorPage(
                    items: [record('C', CheckResult.notFound)],
                  ),
                ),
              );
      });
    }

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-052 no counts until the list is complete, then the kept '
      'checks counted',
      setUp: datedPages,
      build: build,
      act: (bloc) async {
        bloc.add(HistoryQueryChanged(CheckQuery(from: day, to: day)));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.chipTotals, isNull);
        bloc.add(const HistoryNextPageRequested());
      },
      verify: (bloc) {
        expect(bloc.state.list.hasReachedEnd, isTrue);
        final counts = bloc.state.chipTotals!;
        expect(counts.total, 3);
        expect(counts.valid, 1);
        expect(counts.warning, 1);
        expect(counts.notFound, 1);
        expect(counts.unassigned, 0);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-052 a result picked with dates: no limit=1 request to count',
      setUp: datedPages,
      build: build,
      act: (bloc) => bloc.add(
        HistoryQueryChanged(
          CheckQuery(from: day, to: day, result: CheckResult.valid),
        ),
      ),
      verify: (bloc) {
        expect(calls, hasLength(1));
        expect(calls.single.$1.result, CheckResult.valid);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-054 a refresh keeps the counts until the list is complete '
      'again',
      setUp: datedPages,
      build: build,
      act: (bloc) async {
        bloc.add(HistoryQueryChanged(CheckQuery(from: day, to: day)));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryNextPageRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.chipTotals?.total, 3);
        bloc.add(const HistoryRefreshed());
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) {
        expect(bloc.state.list.hasReachedEnd, isFalse);
        expect(bloc.state.chipTotals?.total, 3, reason: 'kept, not blanked');
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-054 a result picked with dates: its checks counted once '
      'complete; a refresh clears chip counts it cannot count again',
      setUp: datedPages,
      build: build,
      act: (bloc) async {
        bloc.add(HistoryQueryChanged(CheckQuery(from: day, to: day)));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryNextPageRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryResultPicked(CheckResult.valid));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.chipTotals?.total, 3, reason: 'same filters');
        bloc.add(const HistoryNextPageRequested());
        await Future<void>.delayed(Duration.zero);
        // A result picked: the chips keep every result's counts.
        expect(bloc.state.chipTotals?.total, 3, reason: 'the chips kept');
        bloc.add(const HistoryRefreshed());
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) => expect(bloc.state.chipTotals, isNull),
    );
  });

  blocTest<HistoryBloc, HistoryState>(
    'first page: items and totals',
    setUp: pages,
    build: build,
    act: (bloc) => bloc.add(const HistoryQueryChanged(CheckQuery())),
    verify: (bloc) {
      expect(bloc.state.list.items.map((c) => c.ref), ['A', 'B']);
      expect(bloc.state.chipTotals, _totals);
      expect(bloc.state.list.nextCursor, 'c1');
      expect(calls.single.$2, isNull);
    },
  );

  // TC-HIST-003: Paging to the end.
  // TC-HIST-004: Cursor sent back unchanged.
  // TC-HIST-029: Empty page after a full page ends the list.
  // TC-HIST-035: Totals kept while later pages load.
  blocTest<HistoryBloc, HistoryState>(
    'next page sends the cursor unchanged; an empty last page ends the list '
    'and the totals stay',
    setUp: pages,
    build: build,
    act: (bloc) async {
      bloc.add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const HistoryNextPageRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const HistoryNextPageRequested());
    },
    verify: (bloc) {
      expect(calls.map((c) => c.$2), [null, 'c1']);
      expect(bloc.state.list.hasReachedEnd, isTrue);
      expect(bloc.state.list.items, hasLength(2));
      expect(bloc.state.chipTotals, _totals);
    },
  );

  // TC-HIST-005: Filter starts from page 1.
  blocTest<HistoryBloc, HistoryState>(
    'a filter change drops the cursor and starts from the first page',
    setUp: pages,
    build: build,
    act: (bloc) async {
      bloc.add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const HistoryQueryChanged(CheckQuery(result: CheckResult.warning)),
      );
    },
    verify: (bloc) {
      expect(calls.map((c) => c.$2), [null, null]);
      expect(calls.last.$1.result, CheckResult.warning);
    },
  );

  // TC-HIST-006: Next-page failure keeps items.
  blocTest<HistoryBloc, HistoryState>(
    'a next-page failure keeps the loaded items',
    setUp: () =>
        pages(second: const Err(Failure(ServiceUnavailableException()))),
    build: build,
    act: (bloc) async {
      bloc.add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const HistoryNextPageRequested());
    },
    verify: (bloc) {
      expect(bloc.state.list.status, PaginationStatus.failureMore);
      expect(bloc.state.list.items, hasLength(2));
      expect(bloc.state.list.canLoadMore, isTrue);
    },
  );

  // TC-HIST-007: Search waits for typing to stop.
  blocTest<HistoryBloc, HistoryState>(
    'search waits until typing stops, then sends one request',
    setUp: pages,
    build: build,
    act: (bloc) async {
      bloc
        ..add(const HistorySearchTyped('1'))
        ..add(const HistorySearchTyped('10'))
        ..add(const HistorySearchTyped('1000001'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(calls, hasLength(1));
      expect(calls.single.$1.search, '1000001');
    },
  );

  // docs/test-cases/06-history.md: paging races and broken answers.
  group('edge cases', () {
    /// Page answers by cursor, each after [delay].
    void slowPages(
      Map<String?, CheckPage> byCursor, {
      Duration delay = const Duration(milliseconds: 30),
    }) {
      calls = [];
      when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
        final query = inv.positionalArguments[0] as CheckQuery;
        final page = inv.positionalArguments[1] as PageRequest;
        calls.add((query, page.cursor));
        await Future<void>.delayed(delay);
        return Success(byCursor[page.cursor]!);
      });
    }

    CheckPage page(List<String> refs, {String? next, CheckTotals? totals}) =>
        CheckPage(
          page: CursorPage(
            items: [for (final r in refs) _check(r)],
            nextCursor: next,
          ),
          totals: totals,
        );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-031 the same cursor again: no request without a scroll',
      setUp: () => slowPages({
        null: page(['A'], next: 'c1', totals: _totals),
        'c1': page(['B'], next: 'c1'),
      }, delay: Duration.zero),
      build: build,
      act: (bloc) async {
        bloc.add(const HistoryQueryChanged(CheckQuery()));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HistoryNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (_) => expect(calls.map((c) => c.$2), [null, 'c1']),
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-033 a filter change while a page loads: the old page never '
      'shows',
      setUp: () => slowPages({
        null: page(['A', 'B'], next: 'c1', totals: _totals),
        'c1': page(['OLD'], next: 'c2'),
      }),
      build: build,
      act: (bloc) async {
        bloc.add(const HistoryQueryChanged(CheckQuery()));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const HistoryNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(
          const HistoryQueryChanged(CheckQuery(result: CheckResult.warning)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        expect(bloc.state.list.items.map((c) => c.ref), ['A', 'B']);
        expect(calls.last.$1.result, CheckResult.warning);
        expect(calls.last.$2, isNull);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-034 a refresh while the first page loads: one list',
      setUp: () => slowPages({
        null: page(['A', 'B'], totals: _totals),
      }),
      build: build,
      act: (bloc) async {
        bloc.add(const HistoryQueryChanged(CheckQuery()));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(const HistoryRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) =>
          expect(bloc.state.list.items.map((c) => c.ref), ['A', 'B']),
    );

    blocTest<HistoryBloc, HistoryState>(
      'TC-HIST-036 totals missing on the first page: rows, no totals',
      setUp: () => slowPages({
        null: page(['A']),
      }, delay: Duration.zero),
      build: build,
      act: (bloc) => bloc.add(const HistoryQueryChanged(CheckQuery())),
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        expect(bloc.state.list.items, hasLength(1));
        expect(bloc.state.chipTotals, isNull);
      },
    );
  });

  group('result chips (TC-HIST-047)', () {
    /// Every check matching the search and the way, whatever the result.
    const all = CheckTotals(
      total: 120,
      valid: 80,
      warning: 30,
      notFound: 9,
      unassigned: 1,
    );

    /// A page's totals with `result=valid`: that result only.
    const onlyValid = CheckTotals(
      total: 80,
      valid: 80,
      warning: 0,
      notFound: 0,
      unassigned: 0,
    );

    late List<(CheckQuery, int)> asked;

    /// A first page whose totals follow the query's result; a one-check
    /// request (the chip counts) answers [counts].
    void answers({Result<CheckPage>? counts}) {
      asked = [];
      when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
        final query = inv.positionalArguments[0] as CheckQuery;
        final page = inv.positionalArguments[1] as PageRequest;
        asked.add((query, page.limit));
        if (page.limit == 1) {
          return counts ??
              Success(
                CheckPage(
                  page: CursorPage(items: [_check('X')]),
                  totals: all,
                ),
              );
        }
        return Success(
          CheckPage(
            page: CursorPage(items: [_check('A')]),
            totals: query.result == null ? all : onlyValid,
          ),
        );
      });
    }

    Iterable<(CheckQuery, int)> counting() => asked.where((a) => a.$2 == 1);

    blocTest<HistoryBloc, HistoryState>(
      'All: the page totals are the chip counts; nothing more is asked',
      setUp: answers,
      build: build,
      act: (bloc) => bloc.add(const HistoryQueryChanged(CheckQuery())),
      verify: (bloc) {
        expect(bloc.state.chipTotals, all);
        expect(counting(), isEmpty);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'a picked result: the list is filtered, the counts are kept',
      setUp: answers,
      build: build,
      act: (bloc) async {
        bloc.add(const HistoryQueryChanged(CheckQuery()));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryResultPicked(CheckResult.valid));
      },
      verify: (bloc) {
        expect(bloc.state.query.result, CheckResult.valid);
        expect(bloc.state.chipTotals, all);
        expect(counting(), isEmpty);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'All again after a result: the counts come from the page',
      setUp: answers,
      build: build,
      act: (bloc) async {
        bloc.add(const HistoryResultPicked(CheckResult.valid));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryResultPicked(null));
      },
      verify: (bloc) {
        expect(bloc.state.query.result, isNull);
        expect(bloc.state.chipTotals, all);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'a new search with a result picked: counted once, without the result',
      setUp: answers,
      build: build,
      seed: () => const HistoryState(
        query: CheckQuery(result: CheckResult.valid),
      ),
      act: (bloc) => bloc.add(
        const HistoryQueryChanged(
          CheckQuery(result: CheckResult.valid, search: '1000001'),
        ),
      ),
      verify: (bloc) {
        final (query, _) = counting().single;
        expect(query.result, isNull);
        expect(query.search, '1000001');
        expect(bloc.state.chipTotals, all);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'the counts fail: the list still shows; the chips show no counts',
      setUp: () => answers(
        counts: const Err(Failure(NetworkException())),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const HistoryQueryChanged(CheckQuery(result: CheckResult.warning)),
      ),
      verify: (bloc) {
        expect(bloc.state.list.items, hasLength(1));
        expect(bloc.state.chipTotals, isNull);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'pull to refresh with a result picked counts again',
      setUp: answers,
      build: build,
      act: (bloc) async {
        bloc.add(
          const HistoryQueryChanged(CheckQuery(result: CheckResult.valid)),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoryRefreshed());
      },
      verify: (bloc) {
        expect(counting(), hasLength(2));
        expect(bloc.state.chipTotals, all);
      },
    );
  });
}
