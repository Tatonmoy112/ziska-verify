import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// The most items in one bulk lookup (final.md Section 13.2).
const bulkMaxItems = 500;

/// One item in the list being built. [value] is already parsed, normalized,
/// and checked against the formats.
class BulkEntry {
  const BulkEntry({required this.id, required this.way, required this.value});

  /// A list key; not sent.
  final int id;
  final LookupWay way;
  final String value;

  /// What the list shows. A hidden code is shown masked like the API does
  /// (`*****7K2`), never in full (final.md Section 12.1).
  String get label =>
      way == LookupWay.hiddenCode ? maskHiddenCode(value) : value;
}

/// `data.summary` (final.md Section 13.2).
class BulkSummary {
  const BulkSummary({
    required this.total,
    required this.valid,
    required this.warning,
    required this.byReason,
    required this.notFound,
    required this.unassigned,
  });

  final int total;
  final int valid;
  final int warning;

  /// Items per reason; an item with two reasons counts in both.
  final Map<LookupReason, int> byReason;
  final int notFound;
  final int unassigned;
}

/// One sent item with its own result, matched by position.
class BulkRow {
  const BulkRow({required this.way, required this.label, required this.result});

  final LookupWay way;
  final String label;
  final LookupResult result;

  bool get needsAttention => result.outcome != LookupOutcome.valid;
}

class BulkOutcome {
  const BulkOutcome({required this.summary, required this.rows});

  final BulkSummary summary;

  /// In the order sent.
  final List<BulkRow> rows;
}
