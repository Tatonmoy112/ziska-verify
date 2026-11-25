import 'package:ziska_verify/core/network/api_dates.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/features/incidents/data/models/incident_dtos.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';

extension ReportsPageMapper on ReportsPageDto {
  CursorPage<Report> toEntity() => CursorPage(
    items: [for (final r in reports) r.toEntity()],
    nextCursor: nextCursor,
  );
}

extension ReportMapper on ReportDto {
  /// A time that is not one throws a `FormatException`, which the
  /// repository's `guard` turns into a failure.
  Report toEntity() => Report(
    id: id,
    at: ApiDates.instant(at),
    note: note,
    photos: photos,
    checkRef: checkRef,
    retailUserName: retailUser?.name,
  );
}
