import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';

extension FormatsMapper on FormatsDto {
  InputFormats toEntity() => InputFormats(
    serialMaxDigits: serial.maxDigits,
    qr: CodeFormat(length: qr.length, characters: qr.characters),
  );
}

extension LookupResultMapper on LookupResultDto {
  LookupResult toEntity() => LookupResult(
    ref: ref,
    outcome: outcomeFrom(result),
    reasons: [for (final r in reasons) reasonFrom(r)],
    count: count == null
        ? null
        : CheckCount(
            thisCheck: count!.thisCheck,
            lastAt: count!.lastAt == null
                ? null
                : DateTime.tryParse(count!.lastAt!)?.toUtc(),
          ),
    item: item == null
        ? null
        : ItemDetails(
            serial: item!.serial,
            maskedCode: item!.code,
            product: Product(
              name: item!.product.name,
              genericName: item!.product.genericName,
              shortName: item!.product.shortName,
              pictureUrl: item!.product.pictureUrl,
            ),
            batch: Batch(
              number: item!.batch.number,
              made: _date(item!.batch.made),
              expires: _date(item!.batch.expires),
            ),
          ),
  );
}

/// Unknown values fail safe: never valid (final.md §13.1).
LookupOutcome outcomeFrom(String value) => switch (value) {
  'valid' => LookupOutcome.valid,
  'warning' => LookupOutcome.warning,
  'not_found' => LookupOutcome.notFound,
  'unassigned' => LookupOutcome.unassigned,
  _ => LookupOutcome.unknown,
};

LookupReason reasonFrom(String value) => switch (value) {
  'checked_before' => LookupReason.checkedBefore,
  'recalled' => LookupReason.recalled,
  'expired' => LookupReason.expired,
  'damaged' => LookupReason.damaged,
  'switched_off' => LookupReason.switchedOff,
  _ => LookupReason.unknown,
};

DateTime? _date(String? value) =>
    value == null ? null : DateTime.tryParse(value);

extension SerialStackMapper on SerialStackDto {
  SerialStackResult toEntity() => SerialStackResult(
    session: session.toEntity(),
    items: [
      for (final item in items)
        SerialStackRow(serial: item.serial, result: item.result.toEntity()),
    ],
  );
}

extension SessionTotalsMapper on SessionTotalsDto {
  SessionTotals toEntity() => SessionTotals(
    id: id,
    scanned: scanned,
    valid: valid,
    warning: warning,
    notFound: notFound,
    unassigned: unassigned,
    left: left,
  );
}

extension SessionSummaryMapper on SessionSummaryDto {
  ScanSessionSummary toEntity() => ScanSessionSummary(
    totals: SessionTotals(
      id: id,
      scanned: scanned,
      valid: valid,
      warning: warning,
      notFound: notFound,
      unassigned: unassigned,
    ),
    kind: switch (kind) {
      'qr' => SessionKind.qr,
      'serial' => SessionKind.serial,
      _ => SessionKind.unknown,
    },
    status: switch (status) {
      'open' => ScanStatus.open,
      'ended' => ScanStatus.ended,
      _ => ScanStatus.unknown,
    },
    startedAt: DateTime.parse(startedAt).toUtc(),
    lastScanAt: DateTime.parse(lastScanAt).toUtc(),
  );
}
