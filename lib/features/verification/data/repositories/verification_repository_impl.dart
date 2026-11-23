import 'dart:async';

import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/utils/local_days.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

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
  Future<Result<ScanResult>> scan(String value, String sessionId) =>
      guard(() async {
        final data = await _api.scan(value, sessionId);
        final scan = ScanResultDto.fromJson(data);
        if (scan.session.id != sessionId) {
          throw const InternalErrorException(message: 'session_mismatch');
        }
        return ScanResult(
          result: LookupResultDto.fromJson(data).toEntity(),
          repeat: scan.repeat,
          session: scan.session.toEntity(),
        );
      });

  @override
  Future<Result<SerialStackResult>> serials(List<String> values) =>
      guard(() async {
        // Each item once, as the server counts them (B5).
        final expected = distinctSerials(values);
        if (expected.isEmpty || expected.length > serialStackLimit) {
          throw const ValidationException(message: 'serial_stack_size');
        }
        final Map<String, dynamic> data;
        try {
          data = await _api.serials(List.unmodifiable(expected));
        } on InternalErrorException catch (e) {
          // A 200 that is not the documented answer: the stack was
          // recorded all the same (guide section 4.7, "when the answer is
          // not 200, nothing was recorded").
          if (e.message == 'verification_shape' || _success(e.statusCode)) {
            throw const InternalErrorException(
              message: 'serial_stack_mismatch',
            );
          }
          rethrow;
        }
        try {
          final dto = SerialStackDto.fromJson(data);
          final rawItems = (data['items'] as List).cast<Map<String, dynamic>>();
          if (dto.items.length != expected.length ||
              dto.session.scanned != expected.length ||
              dto.items.indexed.any(
                (entry) => entry.$2.serial != expected[entry.$1],
              )) {
            throw const InternalErrorException(
              message: 'serial_stack_mismatch',
            );
          }
          return SerialStackResult(
            session: dto.session.toEntity(),
            items: [
              for (final (i, item) in dto.items.indexed)
                SerialStackRow(
                  serial: item.serial,
                  result: LookupResultDto.fromJson(rawItems[i]).toEntity(),
                ),
            ],
          );
          // A 200 whose fields cannot be read is recorded too, never sent
          // again (final.md Section 13.3); the parsers report a wrong
          // field this way.
          // ignore: avoid_catching_errors
        } on TypeError {
          throw const InternalErrorException(message: 'serial_stack_mismatch');
        } on FormatException {
          throw const InternalErrorException(message: 'serial_stack_mismatch');
        }
      });

  static bool _success(int? status) =>
      status != null && status >= 200 && status < 300;

  @override
  Future<Result<void>> endSession(String id) =>
      guard(() => _api.endSession(id));
  @override
  Future<Result<ScanSessionSummary>> session(String id) =>
      guard(() async => (await _api.session(id)).toEntity());
  @override
  Future<Result<CursorPage<ScanSessionSummary>>> sessions(
    SessionQuery query,
    PageRequest page,
  ) => guard(() async {
    if (query.from == null && query.to == null) {
      final dto = await _api.sessions(query, page);
      return CursorPage(
        items: [for (final session in dto.sessions) session.toEntity()],
        nextCursor: dto.nextCursor,
      );
    }
    // Bangladesh days on the backend's UTC days (guide §4.5): ask for the
    // UTC days they overlap and keep the sessions that started inside them.
    final days = LocalDays.utcDays(from: query.from, to: query.to);
    final sent = SessionQuery(
      status: query.status,
      from: days.from,
      to: days.to,
    );
    final kept = <ScanSessionSummary>[];
    var cursor = page.cursor;
    String? next;
    for (var read = 0; read < _maxSkippedPages; read++) {
      final dto = await _api.sessions(
        sent,
        PageRequest(limit: page.limit, cursor: cursor),
      );
      final sessions = [for (final s in dto.sessions) s.toEntity()];
      kept.addAll(
        sessions.where(
          (s) => LocalDays.contains(
            s.startedAt,
            from: query.from,
            to: query.to,
          ),
        ),
      );
      next = dto.nextCursor;
      // Newest first: a session whose last scan is before the first day
      // also started before it, and so do the ones after it, whichever of
      // its times the list is sorted by.
      if (sessions.isNotEmpty &&
          LocalDays.beforeFirstDay(sessions.last.lastScanAt, query.from)) {
        next = null;
      }
      if (kept.isNotEmpty || next == null) break;
      cursor = next;
    }
    return CursorPage(items: kept, nextCursor: next);
  });

  /// A safety cap on pages read in a row that keep no session (see
  /// `HistoryRepositoryImpl`).
  static const _maxSkippedPages = 50;

  Future<void> dispose() => _subscription.cancel();
}
