import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paged_loader.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/utils/event_transformers.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/services/history_search.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';

part 'history_bloc.freezed.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

/// Filters changed (or the tab opened): start again from the first page.
final class HistoryQueryChanged extends HistoryEvent {
  const HistoryQueryChanged(this.query);
  final CheckQuery query;
}

/// A result chip was picked (`null`: All). The other filters stay.
final class HistoryResultPicked extends HistoryEvent {
  const HistoryResultPicked(this.result);
  final CheckResult? result;
}

/// The search text changed; debounced (final.md §8).
final class HistorySearchTyped extends HistoryEvent {
  const HistorySearchTyped(this.text);
  final String text;
}

final class HistoryNextPageRequested extends HistoryEvent {
  const HistoryNextPageRequested();
}

/// Pull to refresh: the list stays until the new first page arrives.
final class HistoryRefreshed extends HistoryEvent {
  const HistoryRefreshed({this.done});

  /// Completed once the refresh is handled, whatever it emitted: a pull to
  /// refresh waits on this, never on a next state, which an equal state
  /// does not bring (production audit P-26).
  final Completer<void>? done;
}

/// Retries whichever page failed.
final class HistoryRetried extends HistoryEvent {
  const HistoryRetried();
}

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default(CheckQuery()) CheckQuery query,
    @Default(PaginatedState<CheckRecord>()) PaginatedState<CheckRecord> list,

    /// From the first page; kept while later pages load (§10).
    CheckTotals? totals,

    /// The counts on the result chips: every check matching the search and
    /// the other filters, whatever result is picked, so picking a chip
    /// never changes them. `null` while unknown (the chips then show no
    /// count).
    CheckTotals? chipTotals,

    /// The search is neither a serial nor a reference number, so nothing
    /// was asked for (finding F-4): the list says what to type instead.
    @Default(false) bool searchRefused,
  }) = _HistoryState;
}

/// History (final.md §10, §13.4). A filter or search change starts
/// again from the first page and drops the cursor; one next page at a time.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._getChecks, {CheckQuery initialQuery = const CheckQuery()})
    : super(HistoryState(query: initialQuery)) {
    on<HistoryQueryChanged>(
      (e, emit) => _loadFirst(e.query, emit),
      transformer: restartable(),
    );
    on<HistoryResultPicked>(
      (e, emit) => _loadFirst(state.query.copyWith(result: e.result), emit),
      transformer: restartable(),
    );
    on<HistorySearchTyped>(
      (e, emit) {
        // A serial or a reference number goes as the server reads it;
        // anything else is kept as typed, and never sent (finding F-4).
        final search = HistorySearch.read(e.text);
        return _loadFirst(
          state.query.copyWith(
            search: switch (search.status) {
              SearchStatus.empty => null,
              SearchStatus.ok => search.value,
              SearchStatus.refused => e.text,
            },
          ),
          emit,
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 400)),
    );
    on<HistoryRefreshed>((e, emit) async {
      try {
        await _loadFirst(state.query, emit, keepItems: true);
      } finally {
        e.done?.complete();
      }
    }, transformer: restartable());
    // A next page or a retry for filters changed meanwhile (during a 429
    // wait) loads their own first page (UI audit 2026-11-22, 7.1).
    on<HistoryNextPageRequested>((_, emit) async {
      await _pages.next(_sink(emit), state.query);
      await _countChips(emit);
    }, transformer: droppable());
    on<HistoryRetried>((_, emit) async {
      await _pages.retry(_sink(emit), state.query);
      await _countChips(emit);
    }, transformer: droppable());
  }

  final GetChecks _getChecks;

  /// The list's paging (P-27): its first and next pages, retries, 429
  /// waits, and the rule that a cursor goes back only to the list that
  /// gave it (guide §5).
  late final PagedLoader<CheckRecord, CheckQuery, CheckPage> _pages =
      PagedLoader(
        _getChecks.call,
        page: (answer) => answer.page,
        onWaitOver: () {
          if (!isClosed) add(const HistoryRetried());
        },
      );

  /// The query (without its result) that [HistoryState.chipTotals] count.
  CheckQuery? _chipBase;

  /// The chip counts asked for alongside a first page, for the list of
  /// that `generation`.
  ({int generation, Future<Result<CheckPage>> answer})? _counting;

  @override
  Future<void> close() {
    _pages.dispose();
    return super.close();
  }

  PageSink<CheckRecord, CheckQuery, CheckPage> _sink(
    Emitter<HistoryState> emit,
  ) => PageSink(
    read: () => state.list,
    put: (u) => _put(u, emit),
    alive: () => !emit.isDone,
    // Not a serial or a reference number: the server would answer 400, so
    // nothing is asked for, by a search, a filter, a refresh or a retry
    // (F-4). An answer still on its way is dropped; a 429 wait is kept.
    refuses: (q) =>
        HistorySearch.read(q.search ?? '').status == SearchStatus.refused,
  );

  Future<void> _loadFirst(
    CheckQuery query,
    Emitter<HistoryState> emit, {
    bool keepItems = false,
  }) async {
    await _pages.first(_sink(emit), query, keepItems: keepItems);
    await _countChips(emit);
  }

  /// Each step of the list into the state, with History's counts.
  void _put(
    PageUpdate<CheckRecord, CheckQuery, CheckPage> u,
    Emitter<HistoryState> emit,
  ) {
    final query = u.query;
    final dated = _dated(query);
    switch (u.phase) {
      case PagePhase.refused:
        _chipBase = null;
        _counting = null;
        emit(
          state.copyWith(
            query: query,
            list: u.list,
            totals: null,
            chipTotals: null,
            searchRefused: true,
          ),
        );
      // A 429 is counting down (guide section 1): the filters follow the
      // tap, and the list is asked for once, when the wait ends.
      case PagePhase.held:
        emit(state.copyWith(query: query, searchRefused: false));
      case PagePhase.loadingFirst:
        final base = query.copyWith(result: null);
        // The chip counts still hold when only the result changed; a
        // refresh counts again.
        final keepChips = !u.keepItems && base == _chipBase;
        _chipBase = base;
        // With dates and a result picked, nothing can count the chips
        // again, so a refresh clears them rather than keep counts that may
        // be old.
        final refreshChips = u.keepItems && !(dated && query.result != null);
        emit(
          state.copyWith(
            query: query,
            list: u.list,
            searchRefused: false,
            totals: u.keepItems ? state.totals : null,
            chipTotals: keepChips || refreshChips ? state.chipTotals : null,
          ),
        );
        // With a result picked, the page's totals count that result only:
        // the chips are counted by one more request of a single check
        // (`limit=1`) without the result, sent alongside. With Bangladesh
        // days the server counts UTC days (guide §5), so nothing is asked:
        // the kept checks are counted instead (_counted).
        _counting = query.result != null && !keepChips && !dated
            ? (
                generation: _pages.generation,
                answer: _getChecks(base, const PageRequest(limit: 1)),
              )
            : null;
      case PagePhase.first:
        final answer = u.answer;
        // With dates the server gives no totals: the counts already shown
        // stay until the kept checks are counted.
        emit(
          answer == null
              ? state.copyWith(list: u.list)
              : _counted(
                  state.copyWith(
                    list: u.list,
                    totals: dated ? state.totals : answer.totals,
                    chipTotals: query.result == null && !dated
                        ? answer.totals
                        : state.chipTotals,
                  ),
                ),
        );
      case PagePhase.loadingNext || PagePhase.next:
        emit(_counted(state.copyWith(list: u.list)));
    }
  }

  /// The chip counts sent alongside the first page, once it is in: shown
  /// only while that list is still the one shown.
  Future<void> _countChips(Emitter<HistoryState> emit) async {
    final counting = _counting;
    if (counting == null || emit.isDone) return;
    _counting = null;
    final counts = await counting.answer;
    if (counting.generation != _pages.generation || emit.isDone) return;
    if (counts case Success(:final value)) {
      emit(state.copyWith(chipTotals: value.totals));
    }
  }

  static bool _dated(CheckQuery query) =>
      query.from != null || query.to != null;

  /// With Bangladesh days chosen (guide §5), the counts are the kept
  /// checks', given once the whole list is in. With a result picked they
  /// count that result's checks only, so the chips are left as they are.
  static HistoryState _counted(HistoryState state) {
    final query = state.query;
    if (!_dated(query) || !state.list.hasReachedEnd) return state;
    final items = state.list.items;
    int count(CheckResult result) =>
        items.where((c) => c.result == result).length;
    final counts = CheckTotals(
      total: items.length,
      valid: count(CheckResult.valid),
      warning: count(CheckResult.warning),
      notFound: count(CheckResult.notFound),
      unassigned: count(CheckResult.unassigned),
    );
    if (query.result != null) return state.copyWith(totals: counts);
    return state.copyWith(totals: counts, chipTotals: counts);
  }
}
