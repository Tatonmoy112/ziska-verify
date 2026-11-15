/// One page request (final.md Section 10.2). Pure Dart.
class PageRequest {
  const PageRequest({this.limit = defaultLimit, this.cursor});

  /// The app always sends 50 (the API allows 1 to 100).
  static const defaultLimit = 50;

  final int limit;

  /// `null` on the first page; afterwards the previous page's `next_cursor`,
  /// sent back unchanged.
  final String? cursor;
}
