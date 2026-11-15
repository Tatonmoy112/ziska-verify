import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

abstract interface class VerificationRepository {
  /// The client's formats, loaded once per login and kept in memory
  /// (final.md Section 13.1.3).
  Future<Result<InputFormats>> getFormats();

  /// `POST lookups`. Every call is a recorded check.
  Future<Result<LookupResult>> lookup(LookupWay way, String value);

  /// `POST lookups/bulk`, 1 to 500 items. Results are matched to [entries]
  /// by position (final.md Section 13.2).
  Future<Result<BulkOutcome>> bulkLookup(List<BulkEntry> entries);
}
