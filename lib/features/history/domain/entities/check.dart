import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';

part 'check.freezed.dart';

/// How a check was made (`way`).
enum CheckWay {
  serial('serial'),
  qr('qr'),
  hiddenCode('hidden_code')
  ;

  const CheckWay(this.wire);
  final String wire;
}

/// A check's `result`. [unknown] is never shown as valid (final.md 13.1.5).
enum CheckResult {
  valid('valid'),
  warning('warning'),
  notFound('not_found'),
  unassigned('unassigned'),
  unknown('')
  ;

  const CheckResult(this.wire);
  final String wire;
}

/// One check in History (final.md Section 13.4).
class CheckRecord {
  const CheckRecord({
    required this.ref,
    required this.at,
    required this.way,
    required this.result,
    required this.reasons,
    required this.official,
    this.serial,
    this.product,
    this.batch,
    this.sessionId,
  });

  final String ref;
  final DateTime at;
  final CheckWay? way;
  final CheckResult result;

  /// The API's reason values; empty unless the result is `warning`.
  final List<String> reasons;

  /// Whoever made the check.
  final String official;

  /// `null` for `not_found`; [product] and [batch] also for `unassigned`.
  final String? serial;
  final String? product;
  final String? batch;
  final String? sessionId;
}

/// Counts of every check matching the filters (first page only).
class CheckTotals {
  const CheckTotals({
    required this.total,
    required this.valid,
    required this.warning,
    required this.notFound,
    required this.unassigned,
  });

  final int total;
  final int valid;
  final int warning;
  final int notFound;
  final int unassigned;
}

/// The filters of `GET checks` (final.md Section 13.4).
@freezed
abstract class CheckQuery with _$CheckQuery {
  const factory CheckQuery({
    CheckResult? result,
    CheckWay? way,

    /// Calendar days, both included.
    DateTime? from,
    DateTime? to,

    /// A serial or a reference number.
    String? search,
    String? sessionId,
  }) = _CheckQuery;

  const CheckQuery._();

  bool get hasFilters =>
      result != null || way != null || from != null || to != null;
}

/// A page of checks; [totals] only on the first page.
class CheckPage {
  const CheckPage({required this.page, this.totals});

  final CursorPage<CheckRecord> page;
  final CheckTotals? totals;
}
