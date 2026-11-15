import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/utils/event_transformers.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';

sealed class RetailUserPickerEvent {
  const RetailUserPickerEvent();
}

final class PickerStarted extends RetailUserPickerEvent {
  const PickerStarted();
}

/// Debounced: a new search starts again from the first page.
final class PickerSearchTyped extends RetailUserPickerEvent {
  const PickerSearchTyped(this.text);
  final String text;
}

final class PickerNextPageRequested extends RetailUserPickerEvent {
  const PickerNextPageRequested();
}

final class PickerRetried extends RetailUserPickerEvent {
  const PickerRetried();
}

class RetailUserPickerState {
  const RetailUserPickerState({
    this.search,
    this.list = const PaginatedState<RetailUser>(),
  });

  final String? search;
  final PaginatedState<RetailUser> list;
}

/// The retail user picker (final.md Sections 10, 13.6).
class RetailUserPickerBloc
    extends Bloc<RetailUserPickerEvent, RetailUserPickerState> {
  RetailUserPickerBloc(this._search) : super(const RetailUserPickerState()) {
    on<PickerStarted>(
      (_, emit) => _first(null, emit),
      transformer: restartable(),
    );
    on<PickerSearchTyped>(
      (e, emit) => _first(e.text, emit),
      transformer: debounceRestartable(const Duration(milliseconds: 400)),
    );
    on<PickerNextPageRequested>(
      (_, emit) => _next(emit),
      transformer: droppable(),
    );
    on<PickerRetried>(
      (_, emit) async {
        if (state.list.isWaiting) return;
        state.list.status == PaginationStatus.failureMore
            ? await _next(emit)
            : await _first(state.search, emit);
      },
      transformer: droppable(),
    );
  }

  final SearchRetailUsers _search;
  int _generation = 0;

  Future<void> _first(String? text, Emitter<RetailUserPickerState> emit) async {
    final generation = ++_generation;
    final search = text?.trim().isEmpty ?? true ? null : text!.trim();
    emit(
      RetailUserPickerState(search: search, list: state.list.loadingFirst()),
    );
    final result = await _search(search, const PageRequest());
    if (generation != _generation || emit.isDone) return;
    emit(
      RetailUserPickerState(
        search: search,
        list: switch (result) {
          Success(:final value) => state.list.firstPage(value),
          Err(:final failure) => state.list.failed(failure),
        },
      ),
    );
  }

  Future<void> _next(Emitter<RetailUserPickerState> emit) async {
    final list = state.list;
    if (!list.canLoadMore) return;
    final generation = _generation;
    emit(RetailUserPickerState(search: state.search, list: list.loadingMore()));
    final result = await _search(
      state.search,
      PageRequest(cursor: list.nextCursor),
    );
    if (generation != _generation || emit.isDone) return;
    emit(
      RetailUserPickerState(
        search: state.search,
        list: switch (result) {
          Success(:final value) => state.list.nextPage(value),
          Err(:final failure) => state.list.failed(failure),
        },
      ),
    );
  }
}
