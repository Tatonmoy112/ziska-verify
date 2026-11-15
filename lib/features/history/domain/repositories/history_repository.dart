import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';

abstract interface class HistoryRepository {
  /// `GET checks` (final.md Section 13.4), paged as in Section 10.
  Future<Result<CheckPage>> getChecks(CheckQuery query, PageRequest page);
}
