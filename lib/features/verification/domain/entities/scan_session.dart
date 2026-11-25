import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/utils/wire_value.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

part 'scan_session.freezed.dart';

/// Authoritative counters returned with a scan or serial stack.
@freezed
abstract class SessionTotals with _$SessionTotals {
  const factory SessionTotals({
    required String id,
    required int scanned,
    required int valid,
    required int warning,
    required int notFound,
    required int unassigned,
    int? left,
  }) = _SessionTotals;
}

@freezed
abstract class ScanResult with _$ScanResult {
  const factory ScanResult({
    required LookupResult result,
    required bool repeat,
    required SessionTotals session,
  }) = _ScanResult;
}

/// A session's `kind` (guide §4.5): a scanner session or a serial stack.
enum SessionKind implements WireValue {
  qr('qr'),
  serial('serial'),
  unknown('')
  ;

  const SessionKind(this.wire);
  @override
  final String wire;

  static SessionKind fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// A session's `status` (guide §4.5); also sent as a filter.
enum ScanStatus implements WireValue {
  open('open'),
  ended('ended'),
  unknown('')
  ;

  const ScanStatus(this.wire);
  @override
  final String wire;

  static ScanStatus fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

@freezed
abstract class ScanSessionSummary with _$ScanSessionSummary {
  const factory ScanSessionSummary({
    required SessionTotals totals,
    required SessionKind kind,
    required ScanStatus status,
    required DateTime startedAt,
    required DateTime lastScanAt,
  }) = _ScanSessionSummary;
}

/// The filters of `GET scan-sessions` (final.md §10): copied with
/// [copyWith], equal by value (production audit P-42).
@freezed
abstract class SessionQuery with _$SessionQuery {
  const factory SessionQuery({
    ScanStatus? status,

    /// Calendar days, both included.
    DateTime? from,
    DateTime? to,
  }) = _SessionQuery;
}

/// The history API cannot reconstruct a full lookup response.
@freezed
abstract class RecoveredScan with _$RecoveredScan {
  const factory RecoveredScan({
    required String ref,
    required LookupOutcome outcome,
    String? serial,
    String? product,
  }) = _RecoveredScan;
}

typedef RecoveredScans = CursorPage<RecoveredScan>;
