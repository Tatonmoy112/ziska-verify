/// One page of a cursor-paged list (final.md Section 10.3). Pure Dart.
class CursorPage<T> {
  const CursorPage({required this.items, this.nextCursor});

  final List<T> items;

  /// Opaque: never parsed, compared, or built (Section 10.2).
  final String? nextCursor;

  /// `next_cursor: null` ends the list. A full page always has a cursor, so
  /// the next page can be empty.
  bool get hasMore => nextCursor != null;
}
