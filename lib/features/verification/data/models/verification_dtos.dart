import 'package:json_annotation/json_annotation.dart';

part 'verification_dtos.g.dart';

/// `GET formats` → `data` (app API guide §4.1).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FormatsDto {
  const FormatsDto({
    required this.hiddenCode,
    required this.serial,
    required this.qr,
  });

  factory FormatsDto.fromJson(Map<String, dynamic> json) =>
      _$FormatsDtoFromJson(json);

  final List<CodeFormatDto> hiddenCode;
  final SerialFormatDto serial;
  final CodeFormatDto qr;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CodeFormatDto {
  const CodeFormatDto({required this.length, required this.characters});

  factory CodeFormatDto.fromJson(Map<String, dynamic> json) =>
      _$CodeFormatDtoFromJson(json);

  final int length;
  final String characters;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SerialFormatDto {
  const SerialFormatDto({required this.maxDigits});

  factory SerialFormatDto.fromJson(Map<String, dynamic> json) =>
      _$SerialFormatDtoFromJson(json);

  final int maxDigits;
}

/// `POST lookups` → `data` (app API guide §4.2). `count` and `item` are
/// missing for `not_found` and `unassigned`; `reasons` only with `warning`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LookupResultDto {
  const LookupResultDto({
    required this.ref,
    required this.result,
    this.reasons = const [],
    this.count,
    this.item,
  });

  factory LookupResultDto.fromJson(Map<String, dynamic> json) =>
      _$LookupResultDtoFromJson(json);

  final String ref;
  final String result;
  @JsonKey(defaultValue: <String>[])
  final List<String> reasons;
  final CountDto? count;
  final ItemDto? item;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CountDto {
  const CountDto({required this.thisCheck, this.lastAt, this.by});

  factory CountDto.fromJson(Map<String, dynamic> json) =>
      _$CountDtoFromJson(json);

  final int thisCheck;
  final String? lastAt;
  final List<String>? by;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ItemDto {
  const ItemDto({
    required this.serial,
    required this.code,
    required this.product,
    required this.batch,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItemDtoFromJson(json);

  final String serial;
  final String code;
  final ProductDto product;
  final BatchDto batch;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ProductDto {
  const ProductDto({
    required this.name,
    this.genericName,
    this.shortName,
    this.pictureUrl,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  final String name;
  final String? genericName;
  final String? shortName;
  final String? pictureUrl;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BatchDto {
  const BatchDto({required this.number, this.made, this.expires});

  factory BatchDto.fromJson(Map<String, dynamic> json) =>
      _$BatchDtoFromJson(json);

  final String number;
  final String? made;
  final String? expires;
}

/// `POST lookups/bulk` → `data` (app API guide §4.3).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BulkResponseDto {
  const BulkResponseDto({required this.summary, required this.results});

  factory BulkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BulkResponseDtoFromJson(json);

  final BulkSummaryDto summary;
  final List<LookupResultDto> results;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BulkSummaryDto {
  const BulkSummaryDto({
    required this.total,
    required this.valid,
    required this.warning,
    required this.byReason,
    required this.notFound,
    required this.unassigned,
  });

  factory BulkSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$BulkSummaryDtoFromJson(json);

  final int total;
  final int valid;
  final int warning;
  @JsonKey(defaultValue: <String, int>{})
  final Map<String, int> byReason;
  final int notFound;
  final int unassigned;
}
