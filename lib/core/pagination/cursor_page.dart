import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor_page.freezed.dart';

/// One page of a cursor-paged list (final.md §10). Pure Dart.
@freezed
abstract class CursorPage<T> with _$CursorPage<T> {
  const factory CursorPage({
    required List<T> items,

    /// Opaque: never parsed, compared, or built (§10).
    String? nextCursor,
  }) = _CursorPage<T>;

  const CursorPage._();

  /// `next_cursor: null` ends the list. A full page always has a cursor, so
  /// the next page can be empty.
  bool get hasMore => nextCursor != null;
}
