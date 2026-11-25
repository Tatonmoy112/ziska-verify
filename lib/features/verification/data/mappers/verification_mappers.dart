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
    // Unknown values fail safe: never valid (final.md §13.1).
    outcome: LookupOutcome.fromWire(result),
    reasons: List.unmodifiable(reasons.map(LookupReason.fromWire)),
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
    kind: SessionKind.fromWire(kind),
    status: ScanStatus.fromWire(status),
    startedAt: DateTime.parse(startedAt).toUtc(),
    lastScanAt: DateTime.parse(lastScanAt).toUtc(),
  );
}
