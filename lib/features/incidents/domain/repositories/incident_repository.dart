import 'dart:typed_data';

import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';

abstract interface class IncidentRepository {
  /// `POST incidents`: returns the report's `id`. Never called twice for one
  /// report (final.md §13.5).
  Future<Result<int>> fileReport({
    required String note,
    String? checkRef,
    String? retailUserId,
  });

  /// `POST incidents/{id}/photos` with the raw file. Sending the same photo
  /// again is safe: it answers its number once more. Returns `n`.
  Future<Result<int>> addPhoto(
    int reportId,
    Uint8List bytes, {
    required String contentType,
  });

  /// `GET incidents`: the official's own reports, newest first.
  Future<Result<CursorPage<Report>>> myReports(PageRequest page);
}
