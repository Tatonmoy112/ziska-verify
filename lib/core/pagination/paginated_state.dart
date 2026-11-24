import 'package:clock/clock.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';

/// The status of a paged list (final.md §10).
enum PaginationStatus {
  initial,
  loadingFirst,
  success,
  loadingMore,
  empty,
  failureFirst,
  failureMore,
}

/// A paged list in a BLoC state (final.md §10). Pure Dart.
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.nextCursor,
    this.status = PaginationStatus.initial,
    this.hasReachedEnd = false,
    this.failure,
    this.retryAt,
  });

  final List<T> items;
  final String? nextCursor;
  final PaginationStatus status;
  final bool hasReachedEnd;
  final Failure? failure;

  /// After a `429`: Retry sends nothing before this time (final.md
  /// §10: a countdown, never a retry in a loop).
  final DateTime? retryAt;

  /// A `429` countdown is still running.
  bool get isWaiting => retryAt != null && clock.now().isBefore(retryAt!);

  bool get isLoading =>
      status == PaginationStatus.loadingFirst ||
      status == PaginationStatus.loadingMore;

  /// A next page may be requested now.
  bool get canLoadMore =>
      !hasReachedEnd &&
      nextCursor != null &&
      (status == PaginationStatus.success ||
          status == PaginationStatus.failureMore);

  /// The first page has started: the list is cleared, unless [keepItems]
  /// (pull to refresh keeps the list until the new page arrives).
  PaginatedState<T> loadingFirst({bool keepItems = false}) => PaginatedState(
    items: keepItems ? items : const [],
    status: PaginationStatus.loadingFirst,
  );

  PaginatedState<T> loadingMore() => PaginatedState(
    items: items,
    nextCursor: nextCursor,
    status: PaginationStatus.loadingMore,
  );

  /// The first page arrived; it replaces the list.
  PaginatedState<T> firstPage(CursorPage<T> page) => PaginatedState(
    items: page.items,
    nextCursor: page.nextCursor,
    status: page.items.isEmpty && !page.hasMore
        ? PaginationStatus.empty
        : PaginationStatus.success,
    hasReachedEnd: !page.hasMore,
  );

  /// A later page arrived; it is appended.
  PaginatedState<T> nextPage(CursorPage<T> page) {
    final all = [...items, ...page.items];
    return PaginatedState(
      items: all,
      nextCursor: page.nextCursor,
      status: all.isEmpty ? PaginationStatus.empty : PaginationStatus.success,
      hasReachedEnd: !page.hasMore,
    );
  }

  PaginatedState<T> failed(Failure failure) => PaginatedState(
    items: items,
    nextCursor: nextCursor,
    status: status == PaginationStatus.loadingMore
        ? PaginationStatus.failureMore
        : PaginationStatus.failureFirst,
    failure: failure,
    retryAt: failure.exception is RateLimitedException
        ? failure.retryAtFrom(clock.now())
        : null,
  );
}
