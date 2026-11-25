import 'dart:typed_data';

import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/data/models/incident_dtos.dart';

/// Incident routes (final.md §15).
abstract interface class IncidentApiService {
  /// Files a report (app API guide §6.1); returns its `id`.
  Future<int> fileReport({
    required String note,
    String? checkRef,
    String? retailUserId,
  });

  /// Returns the photo's number `n` on the report.
  Future<int> addPhoto(int reportId, Uint8List bytes, String contentType);

  Future<ReportsPageDto> myReports(PageRequest page);
}

class DioIncidentApiService implements IncidentApiService {
  DioIncidentApiService(this._api);

  final ApiClient _api;

  @override
  Future<int> fileReport({
    required String note,
    String? checkRef,
    String? retailUserId,
  }) async => ApiData.intField(
    await _api.post(
      ApiRoutes.fileReport,
      body: {
        'note': note,
        // Optional fields are left out when not used.
        'check_ref': ?checkRef,
        'retail_user_id': ?retailUserId,
      },
    ),
    'id',
    ApiAnswer.incidentId,
  );

  @override
  Future<int> addPhoto(
    int reportId,
    Uint8List bytes,
    String contentType,
  ) async => ApiData.intField(
    // The body is the file itself, with its Content-Length (§6).
    await _api.postBytes(
      ApiRoutes.reportPhotos(reportId),
      bytes,
      contentType: contentType,
    ),
    'n',
    ApiAnswer.incidentN,
  );

  @override
  Future<ReportsPageDto> myReports(PageRequest page) async {
    final data = await _api.get(
      ApiRoutes.myReports,
      query: {'limit': page.limit, 'cursor': page.cursor},
    );
    return ReportsPageDto.fromJson(ApiData.map(data, ApiAnswer.reports));
  }
}
