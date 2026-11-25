import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/pagination/wait_timer.dart';

/// Asks for one page of a list of [Q].
typedef PageFetch<Q, P> = Future<Result<P>> Function(Q query, PageRequest page);

/// The step a [PageUpdate] comes from.
enum PagePhase {
  /// A query that is never sent ([PageSink.refuses]): an empty list.
  refused,

  /// Asked for during a `429` wait: nothing was sent, the query is shown.
  held,
  loadingFirst,
  first,
  loadingNext,
  next,
}

/// One change of a paged list, for its owner to put in its state.
class PageUpdate<T, Q, P> {
  const PageUpdate(
    this.phase,
    this.list,
    this.query, {
    this.answer,
    this.keepItems = false,
  });

  final PagePhase phase;
  final PaginatedState<T> list;

  /// A first page that keeps the rows shown until it arrives (a pull to
  /// refresh).
  final bool keepItems;

  /// The query the list now shows.
  final Q query;

  /// The answer of a page that arrived ([PagePhase.first],
  /// [PagePhase.next]); `null` when it failed, and in every other phase.
  final P? answer;
}

/// Where a [PagedLoader] reads and puts its list: the owner's state.
class PageSink<T, Q, P> {
  const PageSink({
    required this.read,
    required this.put,
    required this.alive,
    this.refuses,
  });

  final PaginatedState<T> Function() read;
  final void Function(PageUpdate<T, Q, P> update) put;

  /// `false` once the owner takes no more (closed, or its handler done).
  final bool Function() alive;

  /// A query that must never be sent (History's search that is not a
  /// serial or a reference: the server would answer 400).
  final bool Function(Q query)? refuses;
}

/// The paging rules every list follows, written once (final.md §10;
/// production audit P-27):
/// - the first page, then each next page by the cursor of the one before;
/// - an answer for an older list is dropped;
/// - a cursor goes back only to the list that gave it: a next page or a
///   retry for another query loads that query's first page;
/// - Try again asks for what failed: the next page, or the first;
/// - during a `429` wait nothing is sent: a load asked for meanwhile shows
///   its query, and `onWaitOver` runs once, when the wait ends, for the
///   owner to try again (guide §1);
/// - a query the owner refuses is never sent, by any path: it shows an
///   empty list, and a running wait is kept.
class PagedLoader<T, Q, P> {
  PagedLoader(
    this._fetch, {
    required CursorPage<T> Function(P answer) page,
    required void Function() onWaitOver,
  }) : _page = page,
       _onWaitOver = onWaitOver;

  /// A loader whose answers are the pages themselves.
  static PagedLoader<T, Q, CursorPage<T>> ofPages<T, Q>(
    PageFetch<Q, CursorPage<T>> fetch, {
    required void Function() onWaitOver,
  }) => PagedLoader(fetch, page: (p) => p, onWaitOver: onWaitOver);

  final PageFetch<Q, P> _fetch;
  final CursorPage<T> Function(P answer) _page;
  final void Function() _onWaitOver;
  final _deferred = WaitTimer();

  int _generation = 0;
  bool _hasList = false;
  late Q _listQuery;

  /// Bumped by every first page sent: an owner's own request sent
  /// alongside it is dropped when it no longer matches.
  int get generation => _generation;

  /// Forgets the list: an answer still on its way is dropped.
  void _drop() {
    _generation++;
    _hasList = false;
  }

  void dispose() => _deferred.cancel();

  /// The first page of [query]; [keepItems] keeps the rows shown until it
  /// arrives (pull to refresh).
  Future<void> first(
    PageSink<T, Q, P> to,
    Q query, {
    bool keepItems = false,
  }) async {
    final list = to.read();
    if (to.refuses?.call(query) ?? false) {
      _drop();
      to.put(
        PageUpdate(
          PagePhase.refused,
          PaginatedState(
            status: PaginationStatus.empty,
            hasReachedEnd: true,
            retryAt: list.retryAt,
          ),
          query,
        ),
      );
      return;
    }
    final wait = list.retryAt;
    if (list.isWaiting && wait != null) {
      to.put(PageUpdate(PagePhase.held, list, query));
      _deferred.schedule(wait, _onWaitOver);
      return;
    }
    final generation = ++_generation;
    _hasList = true;
    _listQuery = query;
    to.put(
      PageUpdate(
        PagePhase.loadingFirst,
        list.loadingFirst(keepItems: keepItems),
        query,
        keepItems: keepItems,
      ),
    );
    final result = await _fetch(query, const PageRequest());
    if (generation != _generation || !to.alive()) return;
    final now = to.read();
    to.put(switch (result) {
      Success(:final value) => PageUpdate(
        PagePhase.first,
        now.firstPage(_page(value)),
        query,
        answer: value,
      ),
      Err(:final failure) => PageUpdate(
        PagePhase.first,
        now.failed(failure),
        query,
      ),
    });
  }

  /// The next page of the list [query] shows.
  Future<void> next(PageSink<T, Q, P> to, Q query) async {
    if (!_isListOf(query)) return first(to, query);
    final list = to.read();
    if (!list.canLoadMore || list.isWaiting) return;
    final generation = _generation;
    final listQuery = _listQuery;
    to.put(PageUpdate(PagePhase.loadingNext, list.loadingMore(), listQuery));
    final result = await _fetch(
      listQuery,
      PageRequest(cursor: list.nextCursor),
    );
    if (generation != _generation || !to.alive()) return;
    final now = to.read();
    to.put(switch (result) {
      Success(:final value) => PageUpdate(
        PagePhase.next,
        now.nextPage(_page(value)),
        listQuery,
        answer: value,
      ),
      Err(:final failure) => PageUpdate(
        PagePhase.next,
        now.failed(failure),
        listQuery,
      ),
    });
  }

  /// Try again: the next page that failed, for the list it belongs to;
  /// otherwise the first page of [query]. Nothing during a `429` wait.
  Future<void> retry(PageSink<T, Q, P> to, Q query) async {
    final list = to.read();
    if (list.isWaiting) return;
    if (list.status == PaginationStatus.failureMore && _isListOf(query)) {
      return next(to, query);
    }
    return first(to, query);
  }

  bool _isListOf(Q query) => _hasList && query == _listQuery;
}
