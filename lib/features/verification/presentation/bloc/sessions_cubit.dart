import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/paged_loader.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
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

/// The official's scan sessions (final.md §8), paged by [PagedLoader]
/// (P-21, P-27).
class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(GetSessions getSessions) : super(const SessionsState()) {
    _pages = PagedLoader.ofPages(
      getSessions.call,
      onWaitOver: () {
        if (!isClosed) unawaited(retry());
      },
    );
  }

  late final PagedLoader<
    ScanSessionSummary,
    SessionQuery,
    CursorPage<ScanSessionSummary>
  >
  _pages;

  PageSink<ScanSessionSummary, SessionQuery, CursorPage<ScanSessionSummary>>
  get _sink => PageSink(
    read: () => state.list,
    put: (u) => emit(SessionsState(query: u.query, list: u.list)),
    alive: () => !isClosed,
  );

  @override
  Future<void> close() {
    _pages.dispose();
    return super.close();
  }

  /// The first page of [query] (the filters shown when `null`).
  Future<void> load([SessionQuery? query]) =>
      _pages.first(_sink, query ?? state.query);

  Future<void> more() => _pages.next(_sink, state.query);

  /// Try again after a failure: the failed next page for the list it
  /// belongs to, otherwise the first page; nothing during a `429` wait.
  Future<void> retry() => _pages.retry(_sink, state.query);
}
