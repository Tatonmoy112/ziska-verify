import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';

/// One of the official's own reports (`GET incidents`, final.md 13.5.4).
@freezed
abstract class Report with _$Report {
  const factory Report({
    required int id,
    required DateTime at,
    required String note,

    /// How many photos the report has, 0 to 3. Photos cannot be downloaded.
    required int photos,

    /// The check the report points to.
    String? checkRef,

    /// The retail user the report names.
    String? retailUserName,
  }) = _Report;
}

/// The rules of a report (final.md §13.5).
abstract final class ReportRules {
  static const noteMaxLength = 1000;
  static const maxPhotos = 3;

  /// Photos can be added only within this time after filing.
  static const photoWindow = Duration(hours: 1);

  /// Whether a photo may still be added at [now] to a report filed at
  /// [filedAt]; a report not filed yet may take photos (guide §6.2).
  static bool withinPhotoWindow(DateTime? filedAt, DateTime now) =>
      filedAt == null || now.isBefore(filedAt.add(photoWindow));
}
