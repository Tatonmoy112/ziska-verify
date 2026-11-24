import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/data/models/checks_page_dto.dart';
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
    final data = await _api.get('checks', query: checksQuery(query, page));
    if (data is! Map<String, dynamic>) {
      throw const InternalErrorException(message: 'checks_shape');
    }
    return ChecksPageDto.fromJson(data);
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
      'from': query.from == null ? null : _day(query.from!),
      'to': query.to == null ? null : _day(query.to!),
      'search': search == null || search.isEmpty ? null : search,
      'session_id': query.sessionId,
    };
  }

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
