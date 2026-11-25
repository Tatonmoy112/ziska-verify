import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';

import '../../../fakes/fake_secure_storage_service.dart';
import '../../../fakes/fake_session_service.dart';

class _Verification extends Mock implements VerificationRepository {}

const _formats = InputFormats(
  serialMaxDigits: 19,
  qr: CodeFormat(
    length: 12,
    characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  ),
);
const _saved = '7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33';

/// A QR the session reads, by its 12 characters.
String _qr(String code) => 'https://example.test/q/$code';

RecoveredScan _row(String ref) =>
    RecoveredScan(ref: ref, outcome: LookupOutcome.valid);

CursorPage<RecoveredScan> _page(List<String> refs, {String? next}) =>
    CursorPage(items: [for (final r in refs) _row(r)], nextCursor: next);

/// TC-ARCH-074 … -076 (docs/test-cases/18-architecture.md): a scanner
/// session's rows, paged by hand on purpose (production audit P-45): each
/// answered scan goes first, and later pages never repeat a row.
void main() {
  late _Verification repo;
  late FakeSessionService auth;
  late ActiveScanStore store;
  const totals = SessionTotals(
    id: _saved,
    scanned: 3,
    valid: 3,
    warning: 0,
    notFound: 0,
    unassigned: 0,
  );

  setUp(() async {
    repo = _Verification();
    auth = FakeSessionService();
    addTearDown(auth.dispose);
    store = ActiveScanStore(
      FakeSecureStorageService(),
      client: 'x',
      official: 'o',
    );
    await store.save(_saved);
    when(repo.getFormats).thenAnswer((_) async => const Success(_formats));
    when(() => repo.endSession(any())).thenAnswer(
      (_) async => const Success(null),
    );
    when(() => repo.session(_saved)).thenAnswer(
      (_) async => Success(
        ScanSessionSummary(
          totals: totals,
          kind: SessionKind.qr,
          status: ScanStatus.open,
          startedAt: DateTime.utc(2026),
          lastScanAt: DateTime.utc(2026),
        ),
      ),
    );
  });

  /// Each scan answered with the next of [refs].
  void answersScans(List<String> refs) {
    final left = [...refs];
    when(() => repo.scan(any(), any())).thenAnswer(
      (_) async => Success(
        ScanResult(
          result: LookupResult(
            ref: left.removeAt(0),
            outcome: LookupOutcome.valid,
            reasons: const [],
          ),
          repeat: false,
          session: totals,
        ),
      ),
    );
  }

  ScanSessionCubit session(LoadRecoveredScans checks) {
    final cubit = ScanSessionCubit(
      getFormats: GetFormats(repo),
      getSession: GetSession(repo),
      scan: ScanItem(repo),
      endSession: EndSession(repo),
      store: store,
      authStates: auth.states,
      loadChecks: checks,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  List<String> refs(ScanSessionCubit c) => [
    for (final r in c.state.rows) r.ref,
  ];

  group('TC-ARCH-074 normal: pages in order, scans first', () {
    test('a resumed session pages its scans by their cursors', () async {
      final cursors = <String?>[];
      final cubit = session((_, cursor) async {
        cursors.add(cursor);
        return Success(
          cursor == null ? _page(['R3', 'R2'], next: 'c2') : _page(['R1']),
        );
      });
      await cubit.start();
      await cubit.more();
      expect(cursors, [null, 'c2']);
      expect(refs(cubit), ['R3', 'R2', 'R1']);
      expect(cubit.state.nextCursor, isNull);
    });

    test('an answered scan goes first', () async {
      answersScans(['R4']);
      final cubit = session((_, _) async => Success(_page(['R3', 'R2'])));
      await cubit.start();
      await cubit.scan(_qr('A1B2C3D4E5F6'));
      expect(refs(cubit), ['R4', 'R3', 'R2']);
    });
  });

  group('TC-ARCH-075 edge: never a row twice', () {
    test('a scanned row a later page brings again is shown once', () async {
      answersScans(['R9']);
      final cubit = session(
        (_, cursor) async => Success(
          cursor == null ? _page(['R3'], next: 'c2') : _page(['R9', 'R2']),
        ),
      );
      await cubit.start();
      await cubit.scan(_qr('A1B2C3D4E5F6'));
      await cubit.more();
      expect(refs(cubit), ['R9', 'R3', 'R2']);
    });

    test('nothing more to read: no request', () async {
      var calls = 0;
      final cubit = session((_, _) async {
        calls++;
        return Success(_page(['R1']));
      });
      await cubit.start();
      await cubit.more();
      expect(calls, 1);
    });

    test('a scan answered while the first page reloads is kept', () async {
      answersScans(['R9']);
      var calls = 0;
      final reload = Completer<Result<RecoveredScans>>();
      final cubit = session((_, _) {
        calls++;
        // The first read fails; Try again waits for [reload].
        return calls == 1
            ? Future.value(const Err(Failure(NetworkException())))
            : reload.future;
      });
      await cubit.start();
      expect(cubit.state.rowsFailed, isTrue);

      final reloading = cubit.reloadRows();
      await cubit.scan(_qr('A1B2C3D4E5F6'));
      expect(refs(cubit), ['R9']);
      // The page was read before the scan was recorded.
      reload.complete(Success(_page(['R2', 'R1'])));
      await reloading;
      expect(refs(cubit), ['R9', 'R2', 'R1']);
      expect(cubit.state.rowsFailed, isFalse);
    });
  });

  group('TC-ARCH-076 worst: a 429 on the rows', () {
    test('is waited out, and scanning goes on meanwhile', () async {
      var now = DateTime.utc(2026, 11, 25, 10);
      await withClock(Clock(() => now), () async {
        answersScans(['R9']);
        final cursors = <String?>[];
        final cubit = session((_, cursor) async {
          cursors.add(cursor);
          if (cursor == null) return Success(_page(['R3'], next: 'c2'));
          return cursors.length == 2
              ? const Err(
                  Failure(
                    RateLimitedException(retryAfter: Duration(seconds: 30)),
                  ),
                )
              : Success(_page(['R2']));
        });
        await cubit.start();
        await cubit.more();
        expect(cubit.state.rowsRetryAt, isNotNull);

        // During the wait: no request for rows, but a scan is answered.
        await cubit.more();
        expect(cursors, [null, 'c2']);
        await cubit.scan(_qr('A1B2C3D4E5F6'));
        expect(refs(cubit), ['R9', 'R3']);

        // After it: the same page, asked once.
        now = now.add(const Duration(seconds: 31));
        await cubit.more();
        expect(cursors, [null, 'c2', 'c2']);
        expect(refs(cubit), ['R9', 'R3', 'R2']);
      });
    });

    test('the cubit says why its rows are not a PagedLoader', () {
      final source = File(
        'lib/features/verification/presentation/bloc/scan_session_cubit.dart',
      ).readAsStringSync();
      expect(source, contains('not a `PagedLoader`'));
    });
  });
}
