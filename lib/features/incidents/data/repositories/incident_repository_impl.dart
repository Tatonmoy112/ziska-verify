import 'dart:typed_data';

import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/data/mappers/incident_mappers.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  IncidentRepositoryImpl(this._api);

  final IncidentApiService _api;

  @override
  Future<Result<int>> fileReport({
    required String note,
    String? checkRef,
    String? retailUserId,
  }) => guard(
    () => _api.fileReport({
      'note': note,
      // Optional fields are left out when not used.
      'check_ref': ?checkRef,
      'retail_user_id': ?retailUserId,
    }),
  );

  @override
  Future<Result<int>> addPhoto(
    int reportId,
    Uint8List bytes, {
    required String contentType,
  }) => guard(() => _api.addPhoto(reportId, bytes, contentType));

  @override
  Future<Result<CursorPage<Report>>> myReports(PageRequest page) =>
      guard(() async => (await _api.myReports(page)).toEntity());
}
