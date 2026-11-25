import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';

sealed class MyReportsEvent {
  const MyReportsEvent();
}

final class MyReportsStarted extends MyReportsEvent {
  const MyReportsStarted({this.keepItems = false, this.done});

  /// Pull to refresh keeps the list until the new first page arrives.
  final bool keepItems;

  /// Completed once the load is handled, whatever it emitted: a pull to
  /// refresh waits on this, never on a next state (production audit P-26).
  final Completer<void>? done;
}

final class MyReportsNextPageRequested extends MyReportsEvent {
  const MyReportsNextPageRequested();
}

final class MyReportsRetried extends MyReportsEvent {
  const MyReportsRetried();
}

/// My reports (final.md §10, §13.5).
class MyReportsBloc extends Bloc<MyReportsEvent, PaginatedState<Report>> {
  MyReportsBloc(this._getReports) : super(const PaginatedState<Report>()) {
    on<MyReportsStarted>((e, emit) async {
      try {
        // Held while a 429 counts down (guide section 1).
        if (!state.isWaiting) await _first(emit, keepItems: e.keepItems);
      } finally {
        e.done?.complete();
      }
    }, transformer: restartable());
    on<MyReportsNextPageRequested>(
      (_, emit) => _next(emit),
      transformer: droppable(),
    );
    on<MyReportsRetried>(
      (_, emit) async {
        if (state.isWaiting) return;
        state.status == PaginationStatus.failureMore
            ? await _next(emit)
            : await _first(emit);
      },
      transformer: droppable(),
    );
  }

  final GetMyReports _getReports;
  int _generation = 0;

  Future<void> _first(
    Emitter<PaginatedState<Report>> emit, {
    bool keepItems = false,
  }) async {
    final generation = ++_generation;
    emit(state.loadingFirst(keepItems: keepItems));
    final result = await _getReports(const PageRequest());
    if (generation != _generation || emit.isDone) return;
    emit(switch (result) {
      Success(:final value) => state.firstPage(value),
      Err(:final failure) => state.failed(failure),
    });
  }

  Future<void> _next(Emitter<PaginatedState<Report>> emit) async {
    if (!state.canLoadMore) return;
    final generation = _generation;
    final cursor = state.nextCursor;
    emit(state.loadingMore());
    final result = await _getReports(PageRequest(cursor: cursor));
    if (generation != _generation || emit.isDone) return;
    emit(switch (result) {
      Success(:final value) => state.nextPage(value),
      Err(:final failure) => state.failed(failure),
    });
  }
}
