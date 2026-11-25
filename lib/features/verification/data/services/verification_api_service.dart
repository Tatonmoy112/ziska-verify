import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

abstract interface class VerificationApiService {
  Future<FormatsDto> getFormats();
  Future<LookupResultDto> lookup({required String way, required String value});
  Future<ScanResultDto> scan(String value, String sessionId);
  Future<SerialStackDto> serials(List<String> values);
  Future<void> endSession(String id);
  Future<SessionsPageDto> sessions(SessionQuery query, PageRequest page);
  Future<SessionSummaryDto> session(String id);
}

class DioVerificationApiService implements VerificationApiService {
  DioVerificationApiService(this._api);
  final ApiClient _api;
  @override
  Future<FormatsDto> getFormats() async =>
      FormatsDto.fromJson(_map(await _api.get(ApiRoutes.formats)));
  @override
  Future<LookupResultDto> lookup({
    required String way,
    required String value,
  }) async => LookupResultDto.fromJson(
    _map(
      await _api.post(ApiRoutes.lookups, body: {'way': way, 'value': value}),
    ),
  );
  @override
  Future<ScanResultDto> scan(String value, String sessionId) async =>
      ScanResultDto.fromJson(
        _map(
          await _api.post(
            ApiRoutes.lookups,
            body: {'way': 'qr', 'value': value, 'session_id': sessionId},
          ),
        ),
      );
  @override
  Future<SerialStackDto> serials(List<String> values) async =>
      SerialStackDto.fromJson(
        _map(await _api.post(ApiRoutes.serials, body: {'serials': values})),
      );
  @override
  Future<void> endSession(String id) => _api.post(ApiRoutes.endSession(id));
  @override
  Future<SessionSummaryDto> session(String id) async =>
      SessionSummaryDto.fromJson(
        _map(await _api.get(ApiRoutes.session(id))),
      );
  @override
  Future<SessionsPageDto> sessions(
    SessionQuery query,
    PageRequest page,
  ) async => SessionsPageDto.fromJson(
    _map(
      await _api.get(
        ApiRoutes.sessions,
        query: {
          'limit': page.limit,
          'cursor': page.cursor,
          'status': query.status?.name,
          'from': _day(query.from),
          'to': _day(query.to),
        },
      ),
    ),
  );
  static String? _day(DateTime? date) => date == null
      ? null
      : '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}';

  /// Every answer here is an object; the repository acts on this name
  /// (a serial stack recorded with an unreadable answer).
  static Map<String, dynamic> _map(Object? data) =>
      ApiData.map(data, ApiAnswer.verification);
}
