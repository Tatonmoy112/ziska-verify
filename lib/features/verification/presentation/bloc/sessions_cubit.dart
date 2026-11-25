import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/pagination/wait_timer.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

part 'sessions_cubit.freezed.dart';

@freezed
abstract class SessionsState with _$SessionsState {
  const factory SessionsState({
    @Default(SessionQuery()) SessionQuery query,
    @Default(PaginatedState<ScanSessionSummary>())
    PaginatedState<ScanSessionSummary> list,
  }) = _SessionsState;
}

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._getSessions) : super(const SessionsState());
  final GetSessions _getSessions;
  int _generation = 0;

  /// The query the list's rows and cursor belong to.
  SessionQuery? _listQuery;

  /// A load asked for during a `429` wait, sent when the wait ends.
  final _deferred = WaitTimer();

  @override
  Future<void> close() {
    _deferred.cancel();
    return super.close();
  }

  Future<void> load([SessionQuery? query]) async {
    final selected = query ?? state.query;
    // A 429 is counting down (guide section 1): the filters follow the tap,
    // and the list is asked for once, when the wait ends.
    final wait = state.list.retryAt;
    if (state.list.isWaiting && wait != null) {
      emit(SessionsState(query: selected, list: state.list));
      _deferred.schedule(wait, () {
        if (!isClosed) unawaited(load());
      });
      return;
    }
    final generation = ++_generation;
    _listQuery = selected;
    emit(SessionsState(query: selected, list: state.list.loadingFirst()));
    final result = await _getSessions(selected, const PageRequest());
    if (isClosed || generation != _generation) return;
    emit(
      SessionsState(
        query: selected,
        list: switch (result) {
          Success(:final value) => state.list.firstPage(value),
          Err(:final failure) => state.list.failed(failure),
        },
      ),
    );
  }

  /// Try again after a failure (production audit P-21): the failed next
  /// page, for the list it belongs to; otherwise the first page. Nothing
  /// while a `429` counts down.
  Future<void> retry() async {
    if (state.list.isWaiting) return;
    // A filter changed meanwhile starts its own list: a cursor goes back
    // only to the list that gave it (guide §4.5).
    if (state.list.status == PaginationStatus.failureMore &&
        identical(state.query, _listQuery)) {
      return more();
    }
    return load();
  }

  Future<void> more() async {
    final query = _listQuery;
    if (!state.list.canLoadMore || state.list.isWaiting || query == null) {
      return;
    }
    final generation = _generation;
    final cursor = state.list.nextCursor;
    emit(SessionsState(query: state.query, list: state.list.loadingMore()));
    final result = await _getSessions(query, PageRequest(cursor: cursor));
    if (isClosed || generation != _generation) return;
    emit(
      SessionsState(
        query: state.query,
        list: switch (result) {
          Success(:final value) => state.list.nextPage(value),
          Err(:final failure) => state.list.failed(failure),
        },
      ),
    );
  }
}
