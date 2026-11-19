// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormatsDto _$FormatsDtoFromJson(Map<String, dynamic> json) => FormatsDto(
  serial: SerialFormatDto.fromJson(json['serial'] as Map<String, dynamic>),
  qr: CodeFormatDto.fromJson(json['qr'] as Map<String, dynamic>),
);

CodeFormatDto _$CodeFormatDtoFromJson(Map<String, dynamic> json) =>
    CodeFormatDto(
      length: (json['length'] as num).toInt(),
      characters: json['characters'] as String,
    );

SerialFormatDto _$SerialFormatDtoFromJson(Map<String, dynamic> json) =>
    SerialFormatDto(maxDigits: (json['max_digits'] as num).toInt());

LookupResultDto _$LookupResultDtoFromJson(Map<String, dynamic> json) =>
    LookupResultDto(
      ref: json['ref'] as String,
      result: json['result'] as String,
      reasons:
          (json['reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      count: json['count'] == null
          ? null
          : CountDto.fromJson(json['count'] as Map<String, dynamic>),
      item: json['item'] == null
          ? null
          : ItemDto.fromJson(json['item'] as Map<String, dynamic>),
    );

CountDto _$CountDtoFromJson(Map<String, dynamic> json) => CountDto(
  thisCheck: (json['this_check'] as num).toInt(),
  lastAt: json['last_at'] as String?,
);

ItemDto _$ItemDtoFromJson(Map<String, dynamic> json) => ItemDto(
  serial: json['serial'] as String,
  code: json['code'] as String,
  product: ProductDto.fromJson(json['product'] as Map<String, dynamic>),
  batch: BatchDto.fromJson(json['batch'] as Map<String, dynamic>),
);

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  name: json['name'] as String,
  genericName: json['generic_name'] as String?,
  shortName: json['short_name'] as String?,
  pictureUrl: json['picture_url'] as String?,
);

BatchDto _$BatchDtoFromJson(Map<String, dynamic> json) => BatchDto(
  number: json['number'] as String,
  made: json['made'] as String?,
  expires: json['expires'] as String?,
);

SessionTotalsDto _$SessionTotalsDtoFromJson(Map<String, dynamic> json) =>
    SessionTotalsDto(
      id: json['id'] as String,
      scanned: (json['scanned'] as num).toInt(),
      valid: (json['valid'] as num).toInt(),
      warning: (json['warning'] as num).toInt(),
      notFound: (json['not_found'] as num).toInt(),
      unassigned: (json['unassigned'] as num).toInt(),
      left: (json['left'] as num?)?.toInt(),
    );

ScanResultDto _$ScanResultDtoFromJson(Map<String, dynamic> json) =>
    ScanResultDto(
      session: SessionTotalsDto.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      repeat: json['repeat'] as bool,
    );

SessionSummaryDto _$SessionSummaryDtoFromJson(Map<String, dynamic> json) =>
    SessionSummaryDto(
      id: json['id'] as String,
      kind: json['kind'] as String,
      status: json['status'] as String,
      startedAt: json['started_at'] as String,
      lastScanAt: json['last_scan_at'] as String,
      scanned: (json['scanned'] as num).toInt(),
      valid: (json['valid'] as num).toInt(),
      warning: (json['warning'] as num).toInt(),
      notFound: (json['not_found'] as num).toInt(),
      unassigned: (json['unassigned'] as num).toInt(),
    );

SessionsPageDto _$SessionsPageDtoFromJson(Map<String, dynamic> json) =>
    SessionsPageDto(
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => SessionSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

SerialStackDto _$SerialStackDtoFromJson(Map<String, dynamic> json) =>
    SerialStackDto(
      session: SessionTotalsDto.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => SerialStackItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

SerialStackItemDto _$SerialStackItemDtoFromJson(Map<String, dynamic> json) =>
    SerialStackItemDto(serial: json['serial'] as String);
