/// One page of a cursor-paged list (final.md §10). Pure Dart.
class CursorPage<T> {
  const CursorPage({required this.items, this.nextCursor});

  final List<T> items;

  /// Opaque: never parsed, compared, or built (§10).
  final String? nextCursor;

  /// `next_cursor: null` ends the list. A full page always has a cursor, so
  /// the next page can be empty.
  bool get hasMore => nextCursor != null;
}
