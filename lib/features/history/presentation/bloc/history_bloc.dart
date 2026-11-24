import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/pagination/wait_timer.dart';
import 'package:ziska_verify/core/utils/event_transformers.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/services/history_search.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';

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
  const HistoryRefreshed();
}

/// Retries whichever page failed.
final class HistoryRetried extends HistoryEvent {
  const HistoryRetried();
}

class HistoryState {
  const HistoryState({
    this.query = const CheckQuery(),
    this.list = const PaginatedState<CheckRecord>(),
    this.totals,
    this.chipTotals,
    this.searchRefused = false,
  });

  final CheckQuery query;

  /// The search is neither a serial nor a reference number, so nothing was
  /// asked for (finding F-4): the list says what to type instead.
  final bool searchRefused;
  final PaginatedState<CheckRecord> list;

  /// From the first page; kept while later pages load (§10).
  final CheckTotals? totals;

  /// The counts on the result chips: every check matching the search and
  /// the other filters, whatever result is picked, so picking a chip never
  /// changes them. `null` while unknown (the chips then show no count).
  final CheckTotals? chipTotals;

  HistoryState copyWith({
    CheckQuery? query,
    PaginatedState<CheckRecord>? list,
    CheckTotals? Function()? totals,
    CheckTotals? Function()? chipTotals,
    bool? searchRefused,
  }) => HistoryState(
    query: query ?? this.query,
    list: list ?? this.list,
    totals: totals == null ? this.totals : totals(),
    chipTotals: chipTotals == null ? this.chipTotals : chipTotals(),
    searchRefused: searchRefused ?? this.searchRefused,
  );
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
    on<HistoryRefreshed>(
      (_, emit) => _loadFirst(state.query, emit, keepItems: true),
      transformer: restartable(),
    );
    on<HistoryNextPageRequested>(
      (_, emit) => _loadNext(emit),
      transformer: droppable(),
    );
    on<HistoryRetried>((_, emit) {
      if (state.list.isWaiting) return null;
      // The failed next page is asked again only for the list it belongs
      // to; a filter changed meanwhile starts its own list
      // (UI audit 2026-11-22, 7.1).
      if (state.list.status == PaginationStatus.failureMore &&
          state.query == _listQuery) {
        return _loadNext(emit);
      }
      return _loadFirst(state.query, emit);
    }, transformer: droppable());
  }

  final GetChecks _getChecks;

  /// Bumped by every first page; an answer for an older list is dropped.
  int _generation = 0;

  /// The query (without its result) that [HistoryState.chipTotals] count.
  CheckQuery? _chipBase;

  /// The query the list's rows and cursor belong to: a cursor goes back
  /// only to the list that gave it (guide §5).
  CheckQuery? _listQuery;

  /// A load asked for during a `429` wait, sent when the wait ends.
  final _deferred = WaitTimer();

  @override
  Future<void> close() {
    _deferred.cancel();
    return super.close();
  }

  Future<void> _loadFirst(
    CheckQuery query,
    Emitter<HistoryState> emit, {
    bool keepItems = false,
  }) async {
    // Not a serial or a reference number: the server would answer 400, so
    // nothing is asked for, by a search, a filter, or a refresh (F-4). An
    // answer still on its way is dropped; a 429 wait is kept.
    if (HistorySearch.read(query.search ?? '').status == SearchStatus.refused) {
      ++_generation;
      _listQuery = null;
      _chipBase = null;
      emit(
        state.copyWith(
          query: query,
          list: PaginatedState(
            status: PaginationStatus.empty,
            hasReachedEnd: true,
            retryAt: state.list.retryAt,
          ),
          totals: () => null,
          chipTotals: () => null,
          searchRefused: true,
        ),
      );
      return;
    }
    // A 429 is counting down (guide section 1): the filters follow the tap,
    // and the list is asked for once, when the wait ends.
    final wait = state.list.retryAt;
    if (state.list.isWaiting && wait != null) {
      emit(state.copyWith(query: query, searchRefused: false));
      _deferred.schedule(wait, () {
        if (!isClosed) add(const HistoryRetried());
      });
      return;
    }
    final generation = ++_generation;
    _listQuery = query;
    final base = query.copyWith(result: null);
    // The chip counts still hold when only the result changed; a refresh
    // counts again.
    final keepChips = !keepItems && base == _chipBase;
    _chipBase = base;
    // With dates and a result picked, nothing can count the chips again, so
    // a refresh clears them rather than keep counts that may be old.
    final dated = _dated(query);
    final refreshChips = keepItems && !(dated && query.result != null);
    emit(
      state.copyWith(
        query: query,
        list: state.list.loadingFirst(keepItems: keepItems),
        searchRefused: false,
        totals: keepItems ? null : () => null,
        chipTotals: keepChips || refreshChips ? null : () => null,
      ),
    );
    // With a result picked, the page's totals count that result only: the
    // chips are counted by one more request of a single check (`limit=1`)
    // without the result, sent alongside. With Bangladesh days the server
    // counts UTC days (guide §5), so nothing is asked: the kept checks are
    // counted instead (_counted).
    final counting = query.result != null && !keepChips && !dated
        ? _getChecks(base, const PageRequest(limit: 1))
        : null;
    final result = await _getChecks(query, const PageRequest());
    if (generation != _generation || emit.isDone) return;
    switch (result) {
      case Success(:final value):
        // With dates the server gives no totals: the counts already shown
        // stay until the kept checks are counted.
        emit(
          _counted(
            state.copyWith(
              list: state.list.firstPage(value.page),
              totals: dated ? null : () => value.totals,
              chipTotals: query.result == null && !dated
                  ? () => value.totals
                  : null,
            ),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(list: state.list.failed(failure)));
    }
    if (counting == null) return;
    final counts = await counting;
    if (generation != _generation || emit.isDone) return;
    if (counts case Success(:final value)) {
      emit(state.copyWith(chipTotals: () => value.totals));
    }
  }

  Future<void> _loadNext(Emitter<HistoryState> emit) async {
    // The filters changed since the list loaded (during a 429 wait): its
    // cursor is not theirs, so their own first page loads
    // (UI audit 2026-11-22, 7.1).
    if (_listQuery != null && state.query != _listQuery) {
      return _loadFirst(state.query, emit);
    }
    final list = state.list;
    if (!list.canLoadMore) return;
    final generation = _generation;
    emit(state.copyWith(list: list.loadingMore()));
    final result = await _getChecks(
      state.query,
      PageRequest(cursor: list.nextCursor),
    );
    if (generation != _generation || emit.isDone) return;
    switch (result) {
      case Success(:final value):
        emit(_counted(state.copyWith(list: state.list.nextPage(value.page))));
      case Err(:final failure):
        emit(state.copyWith(list: state.list.failed(failure)));
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
    if (query.result != null) return state.copyWith(totals: () => counts);
    return state.copyWith(totals: () => counts, chipTotals: () => counts);
  }
}
