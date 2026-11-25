import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/utils/local_days.dart';

/// A safety cap on pages read in a row that keep no row. With the stop at
/// the first day, only the hours after the last day (00:00 to 06:00 in
/// Dhaka) are skipped, so it is not reached in practice.
const localDayPagesCap = 50;

/// One page of a list on the official's Bangladesh days [from] to [to]
/// (production audit P-28). The backend's days are whole UTC days (guide
/// §4.5, §5), so [fetch] is asked for the UTC days they overlap, and only
/// the rows whose [keptBy] time falls inside the days are kept.
///
/// The list comes newest first, by [sortedBy]: a row before the first day
/// ends it. Pages that keep nothing are read through, at most
/// [localDayPagesCap] in a row; then the cursor is given to go on.
Future<CursorPage<T>> readLocalDayPages<T>({
  required DateTime? from,
  required DateTime? to,
  required PageRequest page,
  required Future<CursorPage<T>> Function(
    DateTime? from,
    DateTime? to,
    PageRequest page,
  )
  fetch,
  required DateTime Function(T row) keptBy,
  required DateTime Function(T row) sortedBy,
}) async {
  final days = LocalDays.utcDays(from: from, to: to);
  final kept = <T>[];
  var cursor = page.cursor;
  String? next;
  for (var read = 0; read < localDayPagesCap; read++) {
    final answer = await fetch(
      days.from,
      days.to,
      PageRequest(limit: page.limit, cursor: cursor),
    );
    final rows = answer.items;
    kept.addAll(
      rows.where((r) => LocalDays.contains(keptBy(r), from: from, to: to)),
    );
    next = answer.nextCursor;
    if (rows.isNotEmpty &&
        LocalDays.beforeFirstDay(sortedBy(rows.last), from)) {
      next = null;
    }
    if (kept.isNotEmpty || next == null) break;
    cursor = next;
  }
  return CursorPage(items: kept, nextCursor: next);
}
