import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

extension FormatsMapper on FormatsDto {
  InputFormats toEntity() => InputFormats(
    hiddenCodes: [
      for (final f in hiddenCode)
        CodeFormat(length: f.length, characters: f.characters),
    ],
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
            by: count!.by,
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

/// Unknown values fail safe: never valid (final.md Section 13.1.5).
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

extension BulkSummaryMapper on BulkSummaryDto {
  BulkSummary toEntity() {
    final reasons = <LookupReason, int>{};
    for (final MapEntry(:key, :value) in byReason.entries) {
      final reason = reasonFrom(key);
      reasons[reason] = (reasons[reason] ?? 0) + value;
    }
    return BulkSummary(
      total: total,
      valid: valid,
      warning: warning,
      byReason: reasons,
      notFound: notFound,
      unassigned: unassigned,
    );
  }
}
