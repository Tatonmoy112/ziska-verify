import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/features/history/data/models/checks_page_dto.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';

extension ChecksPageMapper on ChecksPageDto {
  CheckPage toEntity() => CheckPage(
    page: CursorPage(
      items: [for (final c in checks) c.toEntity()],
      nextCursor: nextCursor,
    ),
    totals: totals == null
        ? null
        : CheckTotals(
            total: totals!.total,
            valid: totals!.valid,
            warning: totals!.warning,
            notFound: totals!.notFound,
            unassigned: totals!.unassigned,
          ),
  );
}

extension CheckMapper on CheckDto {
  CheckRecord toEntity() => CheckRecord(
    ref: ref,
    at: DateTime.parse(at).toUtc(),
    way: CheckWay.values.where((w) => w.wire == way).firstOrNull,
    // Unknown values fail safe: never valid (final.md Section 13.1.5).
    result:
        CheckResult.values
            .where((r) => r.wire == result && r != CheckResult.unknown)
            .firstOrNull ??
        CheckResult.unknown,
    reasons: reasons,
    official: official,
    serial: serial,
    product: product,
    batch: batch,
    sessionId: sessionId,
  );
}
