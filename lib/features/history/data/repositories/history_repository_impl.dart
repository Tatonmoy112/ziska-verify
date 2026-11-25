import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/local_day_pages.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/data/mappers/check_mappers.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._api);

  final HistoryApiService _api;

  @override
  Future<Result<CheckPage>> getChecks(CheckQuery query, PageRequest page) =>
      guard(() async {
        if (query.from == null && query.to == null) {
          return (await _api.getChecks(query, page)).toEntity();
        }
        // Bangladesh days on the backend's UTC days (guide §5). The totals
        // count the UTC days asked, so none are given.
        final kept = await readLocalDayPages<CheckRecord>(
          from: query.from,
          to: query.to,
          page: page,
          fetch: (from, to, page) async => (await _api.getChecks(
            query.copyWith(from: from, to: to),
            page,
          )).toEntity().page,
          keptBy: (c) => c.at,
          sortedBy: (c) => c.at,
        );
        return CheckPage(page: kept);
      });
}
