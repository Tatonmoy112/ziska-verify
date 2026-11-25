import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/paged_loader.dart';
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

/// My reports (final.md §10, §13.5), paged by [PagedLoader] (P-27).
class MyReportsBloc extends Bloc<MyReportsEvent, PaginatedState<Report>> {
  MyReportsBloc(GetMyReports getReports)
    : super(const PaginatedState<Report>()) {
    _pages = PagedLoader.ofPages(
      (_, page) => getReports(page),
      onWaitOver: () {
        if (!isClosed) add(const MyReportsRetried());
      },
    );
    on<MyReportsStarted>((e, emit) async {
      try {
        await _pages.first(_sink(emit), null, keepItems: e.keepItems);
      } finally {
        e.done?.complete();
      }
    }, transformer: restartable());
    on<MyReportsNextPageRequested>(
      (_, emit) => _pages.next(_sink(emit), null),
      transformer: droppable(),
    );
    on<MyReportsRetried>(
      (_, emit) => _pages.retry(_sink(emit), null),
      transformer: droppable(),
    );
  }

  /// One list, without a query.
  late final PagedLoader<Report, Object?, CursorPage<Report>> _pages;

  PageSink<Report, Object?, CursorPage<Report>> _sink(
    Emitter<PaginatedState<Report>> emit,
  ) => PageSink(
    read: () => state,
    put: (u) => emit(u.list),
    alive: () => !emit.isDone,
  );

  @override
  Future<void> close() {
    _pages.dispose();
    return super.close();
  }
}
