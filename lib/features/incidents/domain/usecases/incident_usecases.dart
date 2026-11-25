import 'dart:typed_data';

import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';

/// Files a report (guide §6.1). The note, without the spaces around it,
/// is 1 to [ReportRules.noteMaxLength] characters, counted as code points
/// as the server counts them (production audit P-33).
class FileReport {
  const FileReport(this._repository);
  final IncidentRepository _repository;

  Future<Result<int>> call({
    required String note,
    String? checkRef,
    String? retailUserId,
  }) async {
    final text = note.trim();
    if (text.isEmpty || text.runes.length > ReportRules.noteMaxLength) {
      return const Err(Failure(ValidationException()));
    }
    return _repository.fileReport(
      note: text,
      checkRef: checkRef,
      retailUserId: retailUserId,
    );
  }
}

/// Sends a photo of a filed report (guide §6.2): a JPEG or PNG of at most
/// 1 MB. How many a report has, and its hour, are the report's state: the
/// screen asks [ReportRules] before it sends (production audit P-33).
class AddReportPhoto {
  const AddReportPhoto(this._repository);
  final IncidentRepository _repository;

  Future<Result<int>> call(
    int reportId,
    Uint8List bytes, {
    required String contentType,
  }) async {
    if (reportId < 1 ||
        bytes.isEmpty ||
        bytes.length > PreparedPhoto.maxBytes ||
        !PreparedPhoto.types.contains(contentType)) {
      return const Err(Failure(ValidationException()));
    }
    return _repository.addPhoto(reportId, bytes, contentType: contentType);
  }
}

class GetMyReports {
  const GetMyReports(this._repository);
  final IncidentRepository _repository;

  Future<Result<CursorPage<Report>>> call(PageRequest page) =>
      _repository.myReports(page);
}
