import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/utils/local_days.dart';
import 'package:ziska_verify/features/history/data/mappers/check_mappers.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._api);

  final HistoryApiService _api;

  /// A safety cap on pages read in a row that keep no check. With the stop
  /// at the first day, only the hours after the last day (00:00 to 06:00 in
  /// Dhaka) are skipped, so it is not reached in practice.
  static const _maxSkippedPages = 50;

  @override
  Future<Result<CheckPage>> getChecks(CheckQuery query, PageRequest page) =>
      guard(() async {
        if (query.from == null && query.to == null) {
          return (await _api.getChecks(query, page)).toEntity();
        }
        // Bangladesh days on the backend's UTC days (guide §5): ask for the
        // UTC days they overlap, keep the checks inside them. The totals
        // count the UTC days asked, so none are given.
        final days = LocalDays.utcDays(from: query.from, to: query.to);
        final sent = query.copyWith(from: days.from, to: days.to);
        final kept = <CheckRecord>[];
        var cursor = page.cursor;
        String? next;
        for (var read = 0; read < _maxSkippedPages; read++) {
          final answer = (await _api.getChecks(
            sent,
            PageRequest(limit: page.limit, cursor: cursor),
          )).toEntity();
          final items = answer.page.items;
          kept.addAll(
            items.where(
              (c) => LocalDays.contains(c.at, from: query.from, to: query.to),
            ),
          );
          next = answer.page.nextCursor;
          // Newest first: past the first day, nothing more can be kept.
          if (items.isNotEmpty &&
              LocalDays.beforeFirstDay(items.last.at, query.from)) {
            next = null;
          }
          if (kept.isNotEmpty || next == null) break;
          cursor = next;
        }
        return CheckPage(
          page: CursorPage(items: kept, nextCursor: next),
        );
      });
}
