import 'package:json_annotation/json_annotation.dart';

part 'checks_page_dto.g.dart';

/// `GET checks` → `data` (app API guide §5). The list key is `checks`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ChecksPageDto {
  const ChecksPageDto({required this.checks, this.totals, this.nextCursor});

  factory ChecksPageDto.fromJson(Map<String, dynamic> json) =>
      _$ChecksPageDtoFromJson(json);

  final List<CheckDto> checks;

  /// First page only; `null` on later pages.
  final TotalsDto? totals;

  /// Opaque; `null` when the page is not full.
  final String? nextCursor;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CheckDto {
  const CheckDto({
    required this.ref,
    required this.at,
    required this.way,
    required this.result,
    required this.official,
    this.reasons = const [],
    this.serial,
    this.product,
    this.batch,
  });

  factory CheckDto.fromJson(Map<String, dynamic> json) =>
      _$CheckDtoFromJson(json);

  final String ref;
  final String at;
  final String way;
  final String result;
  @JsonKey(defaultValue: <String>[])
  final List<String> reasons;
  final String official;
  final String? serial;
  final String? product;
  final String? batch;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TotalsDto {
  const TotalsDto({
    required this.total,
    required this.valid,
    required this.warning,
    required this.notFound,
    required this.unassigned,
  });

  factory TotalsDto.fromJson(Map<String, dynamic> json) =>
      _$TotalsDtoFromJson(json);

  final int total;
  final int valid;
  final int warning;
  final int notFound;
  final int unassigned;
}
