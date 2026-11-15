import 'dart:async';

import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(this._api, SessionService session) {
    // Formats belong to one login; a new login loads them again.
    _subscription = session.states.listen((state) {
      if (state is! SessionAuthenticated) _formats = null;
    });
  }

  final VerificationApiService _api;
  late final StreamSubscription<SessionState> _subscription;
  InputFormats? _formats;

  @override
  Future<Result<InputFormats>> getFormats() async {
    final cached = _formats;
    if (cached != null) return Success(cached);
    return guard(() async => _formats = (await _api.getFormats()).toEntity());
  }

  @override
  Future<Result<LookupResult>> lookup(LookupWay way, String value) => guard(
    () async => (await _api.lookup(way: way.wire, value: value)).toEntity(),
  );

  @override
  Future<Result<BulkOutcome>> bulkLookup(List<BulkEntry> entries) =>
      guard(() async {
        final dto = await _api.lookupBulk([
          for (final e in entries) {'way': e.way.wire, 'value': e.value},
        ]);
        // Results come back in the order sent; nothing else links them to
        // the items (final.md Section 13.2). A different count is a broken
        // answer, never shown.
        if (dto.results.length != entries.length) {
          throw const InternalErrorException(message: 'bulk_count_mismatch');
        }
        return BulkOutcome(
          summary: dto.summary.toEntity(),
          rows: [
            for (final (i, entry) in entries.indexed)
              BulkRow(
                way: entry.way,
                label: entry.label,
                result: dto.results[i].toEntity(),
              ),
          ],
        );
      });

  Future<void> dispose() => _subscription.cancel();
}
