import 'package:json_annotation/json_annotation.dart';

part 'incident_dtos.g.dart';

/// `GET incidents` → `data` (app API guide §6.3). The list key is
/// `reports`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ReportsPageDto {
  const ReportsPageDto({required this.reports, this.nextCursor});

  factory ReportsPageDto.fromJson(Map<String, dynamic> json) =>
      _$ReportsPageDtoFromJson(json);

  final List<ReportDto> reports;
  final String? nextCursor;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ReportDto {
  const ReportDto({
    required this.id,
    required this.at,
    required this.note,
    required this.photos,
    this.checkRef,
    this.retailUser,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDtoFromJson(json);

  final int id;
  final String at;
  final String note;
  final int photos;
  final String? checkRef;
  final ReportRetailUserDto? retailUser;
}

@JsonSerializable(createToJson: false)
class ReportRetailUserDto {
  const ReportRetailUserDto({required this.id, required this.name});

  factory ReportRetailUserDto.fromJson(Map<String, dynamic> json) =>
      _$ReportRetailUserDtoFromJson(json);

  final String id;
  final String name;
}
