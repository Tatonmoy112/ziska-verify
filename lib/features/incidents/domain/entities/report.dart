/// One of the official's own reports (`GET incidents`, final.md 13.5.4).
class Report {
  const Report({
    required this.id,
    required this.at,
    required this.note,
    required this.photos,
    this.checkRef,
    this.retailUserName,
  });

  final int id;
  final DateTime at;
  final String note;

  /// How many photos the report has, 0 to 3. Photos cannot be downloaded.
  final int photos;

  /// The check the report points to.
  final String? checkRef;

  /// The retail user the report names.
  final String? retailUserName;
}

/// The rules of a report (final.md §13.5).
abstract final class ReportRules {
  static const noteMaxLength = 1000;
  static const maxPhotos = 3;

  /// Photos can be added only within this time after filing.
  static const photoWindow = Duration(hours: 1);
}
