import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

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

enum SessionKind { qr, serial, unknown }

enum ScanStatus { open, ended, unknown }

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

class SessionQuery {
  const SessionQuery({this.status, this.from, this.to});
  final ScanStatus? status;
  final DateTime? from;
  final DateTime? to;
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
