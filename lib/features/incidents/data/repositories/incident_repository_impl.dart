import 'dart:typed_data';

import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/data/mappers/incident_mappers.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/failure_reasons.dart';
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
  }) => guard(() async {
    try {
      return await _api.fileReport(
        note: note,
        checkRef: checkRef,
        retailUserId: retailUserId,
      );
    } on NotFoundException catch (e) {
      throw e.withReason(
        _gone(e.message, check: checkRef != null, retail: retailUserId != null),
      );
    }
  });

  /// What a 404 on filing says is gone (guide §6.1): by the server's text,
  /// "Check not found." or "Retail user not found.", the one place it is
  /// read (P-25); else by the one link sent; else nothing (the route).
  static IncidentReason? _gone(
    String? message, {
    required bool check,
    required bool retail,
  }) {
    final text = message?.toLowerCase() ?? '';
    if (text.contains('retail user')) return IncidentReason.retailUserGone;
    if (text.contains('check')) return IncidentReason.checkGone;
    if (check && !retail) return IncidentReason.checkGone;
    if (retail && !check) return IncidentReason.retailUserGone;
    return null;
  }

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
