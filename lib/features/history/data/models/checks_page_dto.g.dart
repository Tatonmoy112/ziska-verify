// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checks_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChecksPageDto _$ChecksPageDtoFromJson(Map<String, dynamic> json) =>
    ChecksPageDto(
      checks: (json['checks'] as List<dynamic>)
          .map((e) => CheckDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: json['totals'] == null
          ? null
          : TotalsDto.fromJson(json['totals'] as Map<String, dynamic>),
      nextCursor: json['next_cursor'] as String?,
    );

CheckDto _$CheckDtoFromJson(Map<String, dynamic> json) => CheckDto(
  ref: json['ref'] as String,
  at: json['at'] as String,
  way: json['way'] as String,
  result: json['result'] as String,
  official: json['official'] as String,
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  serial: json['serial'] as String?,
  product: json['product'] as String?,
  batch: json['batch'] as String?,
);

TotalsDto _$TotalsDtoFromJson(Map<String, dynamic> json) => TotalsDto(
  total: (json['total'] as num).toInt(),
  valid: (json['valid'] as num).toInt(),
  warning: (json['warning'] as num).toInt(),
  notFound: (json['not_found'] as num).toInt(),
  unassigned: (json['unassigned'] as num).toInt(),
);
