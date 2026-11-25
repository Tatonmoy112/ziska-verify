import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_dates.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/data/models/check_dtos.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';

/// `GET checks` (final.md §15).
abstract interface class HistoryApiService {
  Future<ChecksPageDto> getChecks(CheckQuery query, PageRequest page);
}

class DioHistoryApiService implements HistoryApiService {
  DioHistoryApiService(this._api);

  final ApiClient _api;

  @override
  Future<ChecksPageDto> getChecks(CheckQuery query, PageRequest page) async {
    final data = await _api.get(
      ApiRoutes.checks,
      query: checksQuery(query, page),
    );
    return ChecksPageDto.fromJson(ApiData.map(data, ApiAnswer.checks));
  }

  /// Only documented parameters; empty filters are left out, and so is
  /// No scope parameter is supported. Session filters are explicit.
  static Map<String, Object?> checksQuery(CheckQuery query, PageRequest page) {
    final search = query.search?.trim();
    return {
      'limit': page.limit,
      'cursor': page.cursor,
      'result': query.result?.wire,
      'way': query.way?.wire,
      'from': query.from == null ? null : ApiDates.dayText(query.from!),
      'to': query.to == null ? null : ApiDates.dayText(query.to!),
      'search': search == null || search.isEmpty ? null : search,
      'session_id': query.sessionId,
    };
  }
}
