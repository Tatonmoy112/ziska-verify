import 'dart:typed_data';

import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';

class FileReport {
  const FileReport(this._repository);
  final IncidentRepository _repository;

  Future<Result<int>> call({
    required String note,
    String? checkRef,
    String? retailUserId,
  }) => _repository.fileReport(
    note: note.trim(),
    checkRef: checkRef,
    retailUserId: retailUserId,
  );
}

class AddReportPhoto {
  const AddReportPhoto(this._repository);
  final IncidentRepository _repository;

  Future<Result<int>> call(
    int reportId,
    Uint8List bytes, {
    required String contentType,
  }) => _repository.addPhoto(reportId, bytes, contentType: contentType);
}

class GetMyReports {
  const GetMyReports(this._repository);
  final IncidentRepository _repository;

  Future<Result<CursorPage<Report>>> call(PageRequest page) =>
      _repository.myReports(page);
}
