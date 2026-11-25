import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/paged_loader.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/utils/event_transformers.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';

part 'retail_user_picker_bloc.freezed.dart';

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

@freezed
abstract class RetailUserPickerState with _$RetailUserPickerState {
  const factory RetailUserPickerState({
    String? search,
    @Default(PaginatedState<RetailUser>()) PaginatedState<RetailUser> list,
  }) = _RetailUserPickerState;
}

/// The retail user picker (final.md §10, §13.6), paged by [PagedLoader]
/// (P-27).
class RetailUserPickerBloc
    extends Bloc<RetailUserPickerEvent, RetailUserPickerState> {
  RetailUserPickerBloc(SearchRetailUsers search)
    : super(const RetailUserPickerState()) {
    _pages = PagedLoader.ofPages(
      search.call,
      onWaitOver: () {
        if (!isClosed) add(const PickerRetried());
      },
    );
    on<PickerStarted>(
      (_, emit) => _pages.first(_sink(emit), null),
      transformer: restartable(),
    );
    on<PickerSearchTyped>(
      (e, emit) {
        final text = e.text.trim();
        return _pages.first(_sink(emit), text.isEmpty ? null : text);
      },
      transformer: debounceRestartable(const Duration(milliseconds: 400)),
    );
    on<PickerNextPageRequested>(
      (_, emit) => _pages.next(_sink(emit), state.search),
      transformer: droppable(),
    );
    on<PickerRetried>(
      (_, emit) => _pages.retry(_sink(emit), state.search),
      transformer: droppable(),
    );
  }

  /// The list of one search (`null`: every retail user).
  late final PagedLoader<RetailUser, String?, CursorPage<RetailUser>> _pages;

  PageSink<RetailUser, String?, CursorPage<RetailUser>> _sink(
    Emitter<RetailUserPickerState> emit,
  ) => PageSink(
    read: () => state.list,
    put: (u) => emit(RetailUserPickerState(search: u.query, list: u.list)),
    alive: () => !emit.isDone,
  );

  @override
  Future<void> close() {
    _pages.dispose();
    return super.close();
  }
}
