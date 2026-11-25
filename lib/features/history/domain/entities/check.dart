import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/utils/wire_value.dart';

part 'check.freezed.dart';

/// How a check was made (`way`, guide §5). [unknown] is a way this app
/// does not know yet, shown as "Other".
enum CheckWay implements WireValue {
  serial('serial'),
  qr('qr'),
  hiddenCode('hidden_code'),
  unknown('')
  ;

  const CheckWay(this.wire);
  @override
  final String wire;

  static CheckWay fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// A check's `result`. [unknown] is never shown as valid (final.md 13.1.5).
enum CheckResult implements WireValue {
  valid('valid'),
  warning('warning'),
  notFound('not_found'),
  unassigned('unassigned'),
  unknown('')
  ;

  const CheckResult(this.wire);
  @override
  final String wire;

  static CheckResult fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// A warning's `reasons` (guide §5). [unknown] is shown as a generic
/// reason. The same values as verification's `LookupReason`, which History
/// may not import (rule R4).
enum CheckReason implements WireValue {
  checkedBefore('checked_before'),
  recalled('recalled'),
  expired('expired'),
  damaged('damaged'),
  switchedOff('switched_off'),
  unknown('')
  ;

  const CheckReason(this.wire);
  @override
  final String wire;

  static CheckReason fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// One check in History (final.md §13.4).
@freezed
abstract class CheckRecord with _$CheckRecord {
  const factory CheckRecord({
    required String ref,
    required DateTime at,
    required CheckWay way,
    required CheckResult result,

    /// Empty unless the result is `warning`.
    required List<CheckReason> reasons,

    /// Whoever made the check.
    required String official,

    /// `null` for `not_found`; [product] and [batch] also for `unassigned`.
    String? serial,
    String? product,
    String? batch,
    String? sessionId,
  }) = _CheckRecord;
}

/// Counts of every check matching the filters (first page only).
@freezed
abstract class CheckTotals with _$CheckTotals {
  const factory CheckTotals({
    required int total,
    required int valid,
    required int warning,
    required int notFound,
    required int unassigned,
  }) = _CheckTotals;
}

/// The filters of `GET checks` (final.md §13.4).
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
@freezed
abstract class CheckPage with _$CheckPage {
  const factory CheckPage({
    required CursorPage<CheckRecord> page,
    CheckTotals? totals,
  }) = _CheckPage;
}
