import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

/// A resumed scan session's scans, read from History's checks of that
/// session (final.md §13.2). History and verification never import each
/// other (rule R4), so this mapping lives in `app/`, the one place that
/// knows both, beside the routes rather than in them (production audit
/// P-30).
class RecoveredScansBridge {
  const RecoveredScansBridge(this._getChecks);

  final GetChecks _getChecks;

  /// One page of the session [sessionId]'s scans, from [cursor]; the API's
  /// most per page, so a long session comes back in fewer requests.
  Future<Result<RecoveredScans>> call(String sessionId, String? cursor) async =>
      (await _getChecks(
        CheckQuery(sessionId: sessionId),
        PageRequest(limit: PageRequest.maxLimit, cursor: cursor),
      )).map(
        (value) => CursorPage(
          items: [for (final check in value.page.items) scanOf(check)],
          nextCursor: value.page.nextCursor,
        ),
      );

  static RecoveredScan scanOf(CheckRecord check) => RecoveredScan(
    ref: check.ref,
    outcome: outcomeOf(check.result),
    serial: check.serial,
    product: check.product,
  );

  /// The same four results, by their names in each feature; one not known
  /// stays unknown, never a valid one.
  static LookupOutcome outcomeOf(CheckResult result) => switch (result) {
    CheckResult.valid => LookupOutcome.valid,
    CheckResult.warning => LookupOutcome.warning,
    CheckResult.notFound => LookupOutcome.notFound,
    CheckResult.unassigned => LookupOutcome.unassigned,
    CheckResult.unknown => LookupOutcome.unknown,
  };
}
