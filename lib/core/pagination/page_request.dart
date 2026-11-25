/// One page request (final.md §10). Pure Dart.
class PageRequest {
  const PageRequest({this.limit = defaultLimit, this.cursor});

  /// The app sends 50 (the API allows 1 to 100).
  static const defaultLimit = 50;

  /// The API's most: only a resumed scan session reads its rows this way,
  /// so a long session comes back in fewer requests (production audit
  /// P-27).
  static const maxLimit = 100;

  final int limit;

  /// `null` on the first page; afterwards the previous page's `next_cursor`,
  /// sent back unchanged.
  final String? cursor;
}
