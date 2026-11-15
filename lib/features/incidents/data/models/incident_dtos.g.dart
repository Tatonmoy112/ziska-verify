// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportsPageDto _$ReportsPageDtoFromJson(Map<String, dynamic> json) =>
    ReportsPageDto(
      reports: (json['reports'] as List<dynamic>)
          .map((e) => ReportDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

ReportDto _$ReportDtoFromJson(Map<String, dynamic> json) => ReportDto(
  id: (json['id'] as num).toInt(),
  at: json['at'] as String,
  note: json['note'] as String,
  photos: (json['photos'] as num).toInt(),
  checkRef: json['check_ref'] as String?,
  retailUser: json['retail_user'] == null
      ? null
      : ReportRetailUserDto.fromJson(
          json['retail_user'] as Map<String, dynamic>,
        ),
);

ReportRetailUserDto _$ReportRetailUserDtoFromJson(Map<String, dynamic> json) =>
    ReportRetailUserDto(id: json['id'] as String, name: json['name'] as String);
