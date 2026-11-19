import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/pagination/wait_timer.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';

class SessionsState {
  const SessionsState({
    this.query = const SessionQuery(),
    this.list = const PaginatedState<ScanSessionSummary>(),
  });
  final SessionQuery query;
  final PaginatedState<ScanSessionSummary> list;
}

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repository) : super(const SessionsState());
  final VerificationRepository _repository;
  int _generation = 0;

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
    emit(SessionsState(query: selected, list: state.list.loadingFirst()));
    final result = await _repository.sessions(selected, const PageRequest());
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

  Future<void> more() async {
    if (!state.list.canLoadMore || state.list.isWaiting) return;
    final generation = _generation;
    final cursor = state.list.nextCursor;
    emit(SessionsState(query: state.query, list: state.list.loadingMore()));
    final result = await _repository.sessions(
      state.query,
      PageRequest(cursor: cursor),
    );
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
