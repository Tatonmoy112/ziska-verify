import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/utils/wire_value.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

part 'scan_session.freezed.dart';

/// Authoritative counters returned with a scan or serial stack.
class SessionTotals {
  const SessionTotals({
    required this.id,
    required this.scanned,
    required this.valid,
    required this.warning,
    required this.notFound,
    required this.unassigned,
    this.left,
  });
  final String id;
  final int scanned;
  final int valid;
  final int warning;
  final int notFound;
  final int unassigned;
  final int? left;
}

class ScanResult {
  const ScanResult({
    required this.result,
    required this.repeat,
    required this.session,
  });
  final LookupResult result;
  final bool repeat;
  final SessionTotals session;
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

class ScanSessionSummary {
  const ScanSessionSummary({
    required this.totals,
    required this.kind,
    required this.status,
    required this.startedAt,
    required this.lastScanAt,
  });
  final SessionTotals totals;
  final SessionKind kind;
  final ScanStatus status;
  final DateTime startedAt;
  final DateTime lastScanAt;
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
class RecoveredScan {
  const RecoveredScan({
    required this.ref,
    required this.outcome,
    this.serial,
    this.product,
  });
  final String ref;
  final LookupOutcome outcome;
  final String? serial;
  final String? product;
}

typedef RecoveredScans = CursorPage<RecoveredScan>;
