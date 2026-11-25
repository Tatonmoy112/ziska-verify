import 'package:json_annotation/json_annotation.dart';

part 'verification_dtos.g.dart';

/// `GET formats` → `data` (app API guide §4.1).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FormatsDto {
  const FormatsDto({
    required this.serial,
    required this.qr,
  });

  factory FormatsDto.fromJson(Map<String, dynamic> json) =>
      _$FormatsDtoFromJson(json);

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
  const CountDto({required this.thisCheck, this.lastAt});

  factory CountDto.fromJson(Map<String, dynamic> json) =>
      _$CountDtoFromJson(json);

  final int thisCheck;
  final String? lastAt;
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

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SessionTotalsDto {
  const SessionTotalsDto({
    required this.id,
    required this.scanned,
    required this.valid,
    required this.warning,
    required this.notFound,
    required this.unassigned,
    this.left,
  });
  factory SessionTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$SessionTotalsDtoFromJson(json);
  final String id;
  final int scanned;
  final int valid;
  final int warning;
  final int notFound;
  final int unassigned;
  final int? left;
}

/// One read of scanner mode (app API guide §4.3): the lookup and, beside
/// it in the same object, the session's totals and `repeat`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ScanResultDto {
  const ScanResultDto({
    required this.session,
    required this.repeat,
    required this.result,
  });
  factory ScanResultDto.fromJson(Map<String, dynamic> json) =>
      _$ScanResultDtoFromJson(json);
  final SessionTotalsDto session;
  final bool repeat;

  /// The lookup, read from the whole object (production audit P-31).
  @JsonKey(readValue: _whole)
  final LookupResultDto result;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SessionSummaryDto {
  const SessionSummaryDto({
    required this.id,
    required this.kind,
    required this.status,
    required this.startedAt,
    required this.lastScanAt,
    required this.scanned,
    required this.valid,
    required this.warning,
    required this.notFound,
    required this.unassigned,
  });
  factory SessionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryDtoFromJson(json);
  final String id;
  final String kind;
  final String status;
  final String startedAt;
  final String lastScanAt;
  final int scanned;
  final int valid;
  final int warning;
  final int notFound;
  final int unassigned;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SessionsPageDto {
  const SessionsPageDto({required this.sessions, this.nextCursor});
  factory SessionsPageDto.fromJson(Map<String, dynamic> json) =>
      _$SessionsPageDtoFromJson(json);
  final List<SessionSummaryDto> sessions;
  final String? nextCursor;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SerialStackDto {
  const SerialStackDto({required this.session, required this.items});
  factory SerialStackDto.fromJson(Map<String, dynamic> json) =>
      _$SerialStackDtoFromJson(json);
  final SessionTotalsDto session;
  final List<SerialStackItemDto> items;
}

/// One row of a serial stack (app API guide §4.7): the serial as sent
/// and, in the same object, its lookup.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SerialStackItemDto {
  const SerialStackItemDto({required this.serial, required this.result});
  factory SerialStackItemDto.fromJson(Map<String, dynamic> json) =>
      _$SerialStackItemDtoFromJson(json);
  final String serial;

  /// The lookup, read from the whole row (production audit P-31).
  @JsonKey(readValue: _whole)
  final LookupResultDto result;
}

/// A field read from the whole object it sits in, not from one key.
Object? _whole(Map<dynamic, dynamic> json, String _) => json;
