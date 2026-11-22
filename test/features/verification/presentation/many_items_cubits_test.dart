import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/serial_stack_cubit.dart';

import '../../../fakes/fake_secure_storage_service.dart';
import '../../../fakes/fake_session_service.dart';

class MockVerification extends Mock implements VerificationRepository {}

const formats = InputFormats(
  serialMaxDigits: 19,
  qr: CodeFormat(
    length: 12,
    characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  ),
);
const raw = 'https://example.test/q/Q8F2KD91XA7M';
const savedId = '7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33';
SessionTotals totals(String id, [int scanned = 1]) => SessionTotals(
  id: id,
  scanned: scanned,
  valid: scanned,
  warning: 0,
  notFound: 0,
  unassigned: 0,
  left: 5000 - scanned,
);
ScanResult scanResult(String id, {bool repeat = false, String ref = 'R1'}) =>
    ScanResult(
      result: LookupResult(
        ref: ref,
        outcome: LookupOutcome.valid,
        reasons: const [],
      ),
      repeat: repeat,
      session: totals(id),
    );
void main() {
  late MockVerification repo;
  late FakeSecureStorageService storage;
  late FakeSessionService auth;
  late ActiveScanStore store;
  setUp(() {
    repo = MockVerification();
    storage = FakeSecureStorageService();
    auth = FakeSessionService();
    store = ActiveScanStore(storage, client: 'x', official: 'official');
    when(repo.getFormats).thenAnswer((_) async => const Success(formats));
    when(
      () => repo.endSession(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => repo.scan(any(), any())).thenAnswer(
      (i) async => Success(scanResult(i.positionalArguments[1] as String)),
    );
    addTearDown(auth.dispose);
  });
  ScanSessionCubit scanner({LoadRecoveredScans? checks}) {
    final cubit = ScanSessionCubit(
      repository: repo,
      store: store,
      authStates: auth.states,
      loadChecks: checks,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  SerialStackCubit stack() {
    final cubit = SerialStackCubit(repo);
    addTearDown(cubit.close);
    return cubit;
  }

  test('new scanner persists only a UUID v4 under the account key', () async {
    final cubit = scanner();
    await cubit.start();
    expect(
      cubit.state.id,
      matches(
        RegExp(
          '^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-'
          r'[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ),
      ),
    );
    expect(storage.values, {'scan_session:x:official': cubit.state.id});
    await cubit.finish();
    expect(storage.values, isEmpty);
  });
  test('duplicate frames and backend repeats do not duplicate rows', () async {
    final cubit = scanner();
    await cubit.start();
    await cubit.scan(raw);
    expect(cubit.state.checked!.shown, 'Q8F2KD91XA7M');
    await cubit.scan(raw);
    verify(() => repo.scan(any(), any())).called(1);
    when(() => repo.scan(any(), any())).thenAnswer(
      (i) async =>
          Success(scanResult(i.positionalArguments[1] as String, repeat: true)),
    );
    await cubit.scan('https://example.test/q/A1B2C3D4E5F6');
    expect(cubit.state.repeat, isTrue);
    expect(cubit.state.rows, hasLength(1));
    expect(cubit.state.totals!.scanned, 1);
  });
  // TC-MIG-045 (data-flow audit E19): without history:own a resumed
  // session has no totals until a scan answers; it never shows zeros.
  test(
    'TC-MIG-045 a resumed session without its totals waits for a scan',
    () async {
      await store.save('11111111-1111-4111-8111-111111111111');
      final cubit = scanner();
      await cubit.start();
      expect(cubit.state.id, '11111111-1111-4111-8111-111111111111');
      expect(cubit.state.resumed, isTrue);
      expect(cubit.state.totals, isNull);
      await cubit.scan(raw);
      expect(cubit.state.totals, isNotNull);

      final fresh = ScanSessionCubit(
        repository: repo,
        store: ActiveScanStore(storage, client: 'x', official: 'new'),
        authStates: auth.states,
      );
      addTearDown(fresh.close);
      await fresh.start();
      expect(fresh.state.resumed, isFalse);
    },
  );

  test('a network failure can be rescanned without an offline queue', () async {
    final cubit = scanner();
    await cubit.start();
    when(
      () => repo.scan(any(), any()),
    ).thenAnswer((_) async => const Err(Failure(NetworkException())));
    await cubit.scan(raw);
    expect(cubit.state.rows, isEmpty);
    expect(cubit.state.latest, isNull);
    when(() => repo.scan(any(), any())).thenAnswer(
      (i) async => Success(scanResult(i.positionalArguments[1] as String)),
    );
    await cubit.scan(raw);
    expect(cubit.state.rows, hasLength(1));
  });
  for (final code in ['session_full', 'session_ended']) {
    test('$code rolls over and retries once', () async {
      var calls = 0;
      final sent = <String>[];
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        final id = i.positionalArguments[1] as String;
        sent.add(id);
        return ++calls == 1
            ? Err(Failure(ScanSessionException(code: code)))
            : Success(scanResult(id));
      });
      final cubit = scanner();
      await cubit.start();
      await cubit.scan(raw);
      expect(calls, 2);
      expect(sent[0], isNot(sent[1]));
      expect(cubit.state.id, sent.last);
      expect(cubit.state.rows, hasLength(1));
    });
  }
  test('another official session is discarded without replaying', () async {
    final cubit = scanner();
    await cubit.start();
    final old = cubit.state.id;
    when(() => repo.scan(any(), any())).thenAnswer(
      (_) async =>
          const Err(Failure(ScanSessionException(code: 'session_not_yours'))),
    );
    await cubit.scan(raw);
    expect(cubit.state.id, isNot(old));
    // TC-MIG-034: the official is told a new session started.
    expect(cubit.state.restarted, isTrue);
    verify(() => repo.scan(any(), any())).called(1);
  });

  // TC-MIG-035 (audit): a failed scan clears the previous product's card,
  // which would otherwise read as this product's result.
  test('TC-MIG-035 a failed scan clears the previous result card', () async {
    final cubit = scanner();
    await cubit.start();
    await cubit.scan(raw);
    expect(cubit.state.latest, isNotNull);
    when(
      () => repo.scan(any(), any()),
    ).thenAnswer((_) async => const Err(Failure(NetworkException())));
    await cubit.scan('https://example.test/q/A1B2C3D4E5F6');
    expect(cubit.state.failure, isNotNull);
    expect(cubit.state.latest, isNull);
    expect(cubit.state.repeat, isFalse);
  });
  test(
    'finish ignores a late scan answer and deletes recovery state',
    () async {
      final pending = Completer<Result<ScanResult>>();
      when(() => repo.scan(any(), any())).thenAnswer((_) => pending.future);
      final cubit = scanner();
      await cubit.start();
      final id = cubit.state.id!;
      final request = cubit.scan(raw);
      await cubit.finish();
      pending.complete(Success(scanResult(id)));
      await request;
      expect(storage.values, isEmpty);
      expect(cubit.state.rows, isEmpty);
      expect(cubit.state.id, isNull);
    },
  );
  test(
    'logout during initialization cannot save an identifier afterwards',
    () async {
      final pending = Completer<Result<InputFormats>>();
      when(repo.getFormats).thenAnswer((_) => pending.future);
      final cubit = scanner();
      final starting = cubit.start();
      await cubit.finish();
      pending.complete(const Success(formats));
      await starting;
      expect(storage.values, isEmpty);
    },
  );
  test('logout clears an active session', () async {
    final cubit = scanner();
    await cubit.start();
    auth.emitState(const SessionUnauthenticated());
    await Future<void>.delayed(Duration.zero);
    expect(storage.values, isEmpty);
    expect(cubit.state.id, isNull);
  });
  test(
    'recovery reads summaries and pages without fabricating full results',
    () async {
      await store.save(savedId);
      when(() => repo.session(savedId)).thenAnswer(
        (_) async => Success(
          ScanSessionSummary(
            totals: totals(savedId, 8),
            kind: SessionKind.qr,
            status: ScanStatus.open,
            startedAt: DateTime.utc(2026),
            lastScanAt: DateTime.utc(2026),
          ),
        ),
      );
      final cursors = <String?>[];
      final cubit = scanner(
        checks: (id, cursor) async {
          expect(id, savedId);
          cursors.add(cursor);
          return Success(
            CursorPage(
              items: [
                RecoveredScan(
                  ref: cursor == null ? 'R1' : 'R2',
                  outcome: LookupOutcome.warning,
                ),
              ],
              nextCursor: cursor == null ? 'next' : null,
            ),
          );
        },
      );
      await cubit.start();
      expect(cubit.state.totals!.scanned, 8);
      expect(cubit.state.latest, isNull);
      await cubit.more();
      expect(cursors, [null, 'next']);
      expect(cubit.state.rows, hasLength(2));
    },
  );
  test('bulk-only role resumes without history calls', () async {
    await store.save(savedId);
    final cubit = scanner();
    await cubit.start();
    expect(cubit.state.id, savedId);
    verifyNever(() => repo.session(any()));
    await cubit.scan(raw);
    expect(cubit.state.totals, isNotNull);
  });
  // TC-MIG-062 (test-server integration, step 7): after a crash the app
  // reads the saved session (guide section 4.6). Only an open scanner
  // session goes on; anything else starts a new one, and a failure to read
  // it keeps the ID for the next try.
  group('TC-MIG-062 a saved session that cannot go on', () {
    ScanSessionSummary summary(ScanStatus status, SessionKind kind) =>
        ScanSessionSummary(
          totals: totals(savedId, 3),
          kind: kind,
          status: status,
          startedAt: DateTime.utc(2026),
          lastScanAt: DateTime.utc(2026),
        );

    Future<void> expectNewSession(
      Result<ScanSessionSummary> saved,
    ) async {
      await store.save(savedId);
      when(() => repo.session(savedId)).thenAnswer((_) async => saved);
      var reads = 0;
      final cubit = scanner(
        checks: (_, _) async {
          reads++;
          return const Success(CursorPage<RecoveredScan>(items: []));
        },
      );
      await cubit.start();
      expect(cubit.state.id, isNotNull);
      expect(cubit.state.id, isNot(savedId));
      expect(cubit.state.resumed, isFalse);
      expect(cubit.state.totals, isNull);
      expect(cubit.state.rows, isEmpty);
      expect(reads, 0, reason: "the old session's checks are not read");
      expect(await store.read(), cubit.state.id);
      await cubit.scan(raw);
      verify(() => repo.scan('Q8F2KD91XA7M', cubit.state.id!)).called(1);
    }

    test('an ended session', () async {
      await expectNewSession(
        Success(summary(ScanStatus.ended, SessionKind.qr)),
      );
    });

    test('a stack of serials, not a scanner session', () async {
      await expectNewSession(
        Success(summary(ScanStatus.open, SessionKind.serial)),
      );
    });

    test("404: no such session, or another official's", () async {
      await expectNewSession(
        const Err(
          Failure(NotFoundException(statusCode: 404, code: 'not_found')),
        ),
      );
    });

    test(
      'no connection: the ID is kept, and the next try goes on in it',
      () async {
        await store.save(savedId);
        when(
          () => repo.session(savedId),
        ).thenAnswer((_) async => const Err(Failure(NetworkException())));
        final cubit = scanner(
          checks: (_, _) async =>
              const Success(CursorPage<RecoveredScan>(items: [])),
        );
        await cubit.start();
        expect(cubit.state.failure?.exception, isA<NetworkException>());
        expect(cubit.state.id, isNull);
        await cubit.scan(raw);
        verifyNever(() => repo.scan(any(), any()));
        expect(await store.read(), savedId);

        when(() => repo.session(savedId)).thenAnswer(
          (_) async => Success(summary(ScanStatus.open, SessionKind.qr)),
        );
        await cubit.start();
        expect(cubit.state.id, savedId);
        expect(cubit.state.resumed, isTrue);
        expect(cubit.state.totals!.scanned, 3);
      },
    );
  });

  test('TC-MIG-063 a 503 on a scan: "scan again"; nothing kept, nothing '
      'sent again by itself', () async {
    final cubit = scanner();
    await cubit.start();
    await cubit.scan(raw);
    expect(cubit.state.rows, hasLength(1));
    when(() => repo.scan(any(), any())).thenAnswer(
      (_) async => const Err(
        Failure(
          ServiceUnavailableException(
            statusCode: 503,
            code: 'service_unavailable',
          ),
        ),
      ),
    );
    const next = 'https://example.test/q/Q8F2KD91XA7N';
    await cubit.scan(next);
    expect(
      cubit.state.failure?.exception,
      isA<ServiceUnavailableException>(),
    );
    expect(cubit.state.latest, isNull, reason: "the last product's card goes");
    expect(cubit.state.retryAt, isNull);
    expect(cubit.state.rows, hasLength(1));
    expect(cubit.state.totals!.scanned, 1);
    verify(() => repo.scan(any(), any())).called(2);

    when(() => repo.scan(any(), any())).thenAnswer(
      (i) async => Success(
        scanResult(i.positionalArguments[1] as String, ref: 'R2'),
      ),
    );
    await cubit.scan(next);
    verify(() => repo.scan('Q8F2KD91XA7N', cubit.state.id!)).called(1);
    expect(cubit.state.rows.map((r) => r.ref), ['R2', 'R1']);
  });

  group('TC-MIG-064 an end that fails still leaves', () {
    for (final (what, failure) in [
      (
        '404',
        const Failure(NotFoundException(statusCode: 404, code: 'not_found')),
      ),
      ('no connection', const Failure(NetworkException())),
    ]) {
      test(what, () async {
        when(
          () => repo.endSession(any()),
        ).thenAnswer((_) async => Err(failure));
        final cubit = scanner();
        await cubit.start();
        await cubit.scan(raw);
        final id = cubit.state.id!;
        await cubit.finish();
        verify(() => repo.endSession(id)).called(1);
        expect(await store.read(), isNull, reason: 'the ID is forgotten');
        expect(cubit.state.rows, isEmpty);
      });
    }
  });
  test('invalid stored UUID is discarded before any API request', () async {
    await store.save('corrupt-id');
    final cubit = scanner();
    await cubit.start();
    expect(cubit.state.id, isNot('corrupt-id'));
    verifyNever(() => repo.session(any()));
  });
  test('another account cannot read the recovery identifier', () async {
    await store.save(savedId);
    expect(
      await ActiveScanStore(storage, client: 'x', official: 'another').read(),
      isNull,
    );
    expect(
      await ActiveScanStore(
        storage,
        client: 'other',
        official: 'official',
      ).read(),
      isNull,
    );
  });
  test(
    'TC-MIG-048 a 429 holds the line, sends the scan again, then the next',
    () async {
      final sent = <String>[];
      final cubit = scanner();
      await cubit.start();
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        sent.add(i.positionalArguments[0] as String);
        return sent.length == 1
            ? const Err(
                Failure(
                  RateLimitedException(retryAfter: Duration(milliseconds: 50)),
                ),
              )
            : Success(
                scanResult(
                  i.positionalArguments[1] as String,
                  ref: i.positionalArguments[0] as String,
                ),
              );
      });
      await cubit.scan(raw);
      unawaited(cubit.scan('https://x/q/A1B2C3D4E5F6'));
      expect(sent, hasLength(1));
      expect(cubit.state.pending, 2, reason: 'the 429 scan and the next');
      // The wait (50 ms) and the spacing from the first send (500 ms).
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(sent, ['Q8F2KD91XA7M', 'Q8F2KD91XA7M']);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(sent, ['Q8F2KD91XA7M', 'Q8F2KD91XA7M', 'A1B2C3D4E5F6']);
      expect(cubit.state.rows, hasLength(2));
    },
  );

  test(
    'TC-MIG-046 reads during a check wait in line: each sent once, in order',
    () async {
      final sent = <String>[];
      final gate = Completer<void>();
      final cubit = scanner();
      await cubit.start();
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        sent.add(i.positionalArguments[0] as String);
        if (sent.length == 1) await gate.future;
        return Success(
          scanResult(
            i.positionalArguments[1] as String,
            ref: i.positionalArguments[0] as String,
          ),
        );
      });
      final first = cubit.scan(raw);
      final others = [
        cubit.scan('https://x/q/A1B2C3D4E5F6'),
        cubit.scan('https://x/q/B1B2C3D4E5F6'),
        // The one being checked, read again: not sent twice.
        cubit.scan('https://x/q/Q8F2KD91XA7M?again'),
        cubit.scan('https://x/q/C1B2C3D4E5F6'),
      ];
      expect(cubit.state.pending, 3);
      gate.complete();
      await first;
      await Future.wait(others);
      expect(sent, [
        'Q8F2KD91XA7M',
        'A1B2C3D4E5F6',
        'B1B2C3D4E5F6',
        'C1B2C3D4E5F6',
      ]);
      expect(cubit.state.rows, hasLength(4));
      expect(cubit.state.answered, 4);
      expect(cubit.state.pending, 0);
    },
  );

  test('TC-MIG-047 sends start at least 500 ms apart', () async {
    final starts = <DateTime>[];
    final cubit = scanner();
    await cubit.start();
    when(() => repo.scan(any(), any())).thenAnswer((i) async {
      starts.add(DateTime.now());
      return Success(scanResult(i.positionalArguments[1] as String));
    });
    await Future.wait([
      for (final v in ['A1B2C3D4E5F6', 'B1B2C3D4E5F6', 'C1B2C3D4E5F6'])
        cubit.scan('https://x/q/$v'),
    ]);
    expect(starts, hasLength(3));
    for (var k = 1; k < starts.length; k++) {
      expect(
        starts[k].difference(starts[k - 1]).inMilliseconds,
        // The timer may fire a few milliseconds early on some systems.
        greaterThanOrEqualTo(ScanSessionCubit.scanSpacing.inMilliseconds - 20),
      );
    }
  });

  test(
    'TC-MIG-048 offline with reads waiting: they are let go and counted',
    () async {
      final sent = <String>[];
      final gate = Completer<void>();
      final cubit = scanner();
      await cubit.start();
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        sent.add(i.positionalArguments[0] as String);
        await gate.future;
        return const Err(Failure(NetworkException()));
      });
      final first = cubit.scan(raw);
      final others = [
        cubit.scan('https://x/q/A1B2C3D4E5F6'),
        cubit.scan('https://x/q/B1B2C3D4E5F6'),
      ];
      gate.complete();
      await first;
      await Future.wait(others);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(sent, ['Q8F2KD91XA7M'], reason: 'nothing queued for later');
      expect(cubit.state.notChecked, 2);
      expect(cubit.state.pending, 0);
    },
  );
  test(
    'stack parser preserves zeros and order and rejects overflow atomically',
    () async {
      final cubit = stack();
      await cubit.load();
      expect(cubit.compose('001, 2\n001 3'), isTrue);
      expect(cubit.state.serials, ['001', '2', '3']);
      expect(cubit.compose(List.generate(51, (i) => '$i').join(',')), isFalse);
      expect(cubit.state.serials, ['001', '2', '3']);
      expect(cubit.compose('bad'), isFalse);
      expect(cubit.compose(''), isFalse);
      expect(cubit.compose(List.generate(50, (i) => '$i').join(',')), isTrue);
    },
  );
  // TC-MIG-061 (test-server integration, step 6): the server takes 001
  // and 1 for one serial (one row, "001" as sent first). The app does the
  // same, so the stack's answer matches and is shown.
  test('TC-MIG-061 serials that differ only by leading zeros are one serial, '
      'kept as typed first', () async {
    final cubit = stack();
    await cubit.load();
    expect(cubit.compose('001, 1, 0001\n2, 02 0'), isTrue);
    expect(cubit.state.serials, ['001', '2', '0']);
    final parsed = const ParseStack()('001, 1, 2', formats);
    expect(parsed.serials, ['001', '2']);
    expect(parsed.typed, 3);
    expect(parsed.repeats, 1);
    // A serial of zeros only is the serial 0.
    expect(const ParseStack()('0, 000', formats).serials, ['0']);
  });
  // TC-MIG-068 (recheck against ProtectB-DOCS, DEC-371): a serial padded
  // with zeros past 19 characters is still the serial; up to 40.
  test('TC-MIG-068 a stack takes serials padded with zeros, up to 40 '
      'characters', () {
    final padded20 = '${'0' * 19}1';
    final padded40 = '${'0' * 38}12';
    final parsed = const ParseStack()(
      '$padded20, 1, $padded40, 1000001, 0',
      formats,
    );
    expect(parsed.serials, [padded20, padded40, '1000001', '0']);
    expect(parsed.repeats, 1, reason: '1 is serial 1 again');
    final over = const ParseStack()('${'0' * 40}1, 1000001', formats);
    expect(over.serials, isNot(contains('${'0' * 40}1')));
  });
  test('503 retries once with the identical stack', () async {
    final sent = <List<String>>[];
    when(() => repo.serials(any())).thenAnswer((i) async {
      sent.add(i.positionalArguments[0] as List<String>);
      return const Err(Failure(ServiceUnavailableException()));
    });
    final cubit = stack();
    await cubit.load();
    cubit.compose('001,2');
    await cubit.submit();
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(sent, [
      ['001', '2'],
      ['001', '2'],
    ]);
    expect(() => sent.first.add('3'), throwsUnsupportedError);
    expect(cubit.compose('3'), isFalse);
    await cubit.close();
  });
  test('transport loss never automatically replays a stack', () async {
    when(
      () => repo.serials(any()),
    ).thenAnswer((_) async => const Err(Failure(NetworkException())));
    final cubit = stack();
    await cubit.load();
    cubit.compose('1');
    await cubit.submit();
    expect(cubit.state.uncertain, isTrue);
    expect(cubit.compose('2'), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    verify(() => repo.serials(any())).called(1);
    await cubit.submit();
    verify(() => repo.serials(['1'])).called(1);
    await cubit.close();
  });
  test('backgrounding cancels a scheduled stack replay', () async {
    when(() => repo.serials(any())).thenAnswer(
      (_) async => const Err(Failure(ServiceUnavailableException())),
    );
    final cubit = stack();
    await cubit.load();
    cubit.compose('1');
    await cubit.submit();
    cubit.pause();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    cubit.resume();
    verify(() => repo.serials(any())).called(1);
    await cubit.close();
  });
  test('a completed stack clears the draft and cannot be resent', () async {
    when(() => repo.serials(any())).thenAnswer(
      (_) async =>
          Success(SerialStackResult(session: totals('stack'), items: const [])),
    );
    final cubit = stack();
    await cubit.load();
    cubit.compose('1');
    await cubit.submit();
    await cubit.submit();
    expect(cubit.state.serials, isEmpty);
    expect(cubit.state.result, isNotNull);
    verify(() => repo.serials(any())).called(1);
  });

  // Audit H1: a 200 whose answer does not match what was sent was still
  // recorded (app API guide §4.7: all or nothing applies to non-200 only),
  // so sending the same stack again would record every serial twice.
  test('TC-MIG-032 a recorded stack with an unreadable answer is never '
      'sent again', () async {
    when(() => repo.serials(any())).thenAnswer(
      (_) async => const Err(
        Failure(InternalErrorException(message: 'serial_stack_mismatch')),
      ),
    );
    final cubit = stack();
    await cubit.load();
    cubit.compose('1');
    await cubit.submit();
    expect(cubit.state.recorded, isTrue);
    expect(cubit.state.busy, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await cubit.submit();
    expect(cubit.compose('2'), isFalse);
    verify(() => repo.serials(any())).called(1);
    // A new stack starts clean.
    cubit.reset();
    expect(cubit.state.recorded, isFalse);
    await cubit.close();
  });

  // TC-MIG-036 (audit): no connection means nothing was sent, so the stack
  // is not "uncertain"; a lost answer stays uncertain (guide §4.7).
  test(
    'TC-MIG-036 a stack that never left the phone is not uncertain',
    () async {
      when(() => repo.serials(any())).thenAnswer(
        (_) async => const Err(
          Failure(NetworkException(message: NetworkException.notSent)),
        ),
      );
      final cubit = stack();
      await cubit.load();
      cubit.compose('1');
      await cubit.submit();
      expect(cubit.state.uncertain, isFalse);
      expect(cubit.state.failure, isNotNull);
    },
  );

  // TC-MIG-037 (audit): one bad value among 50 is named by its place.
  test('TC-MIG-037 a bad serial is named by its place and value', () async {
    final cubit = stack();
    await cubit.load();
    expect(cubit.compose('1000001, 12a45, 1000003'), isFalse);
    expect(cubit.state.badSerial, (position: 2, value: '12a45'));
    expect(cubit.compose('1000001 1000002'), isTrue);
    expect(cubit.state.badSerial, isNull);
  });

  // TC-MIG-041 (data-flow audit A3, guide 4.6): a resumed session whose scans
  // failed to load gets them on Try again; scanning is not blocked.
  test('TC-MIG-041 a resumed session reloads its scans on Try again', () async {
    await store.save(savedId);
    when(() => repo.session(savedId)).thenAnswer(
      (_) async => Success(
        ScanSessionSummary(
          totals: totals(savedId, 2),
          kind: SessionKind.qr,
          status: ScanStatus.open,
          startedAt: DateTime.utc(2026),
          lastScanAt: DateTime.utc(2026),
        ),
      ),
    );
    var calls = 0;
    final cubit = scanner(
      checks: (id, cursor) async => calls++ == 0
          ? const Err(Failure(NetworkException()))
          : const Success(
              CursorPage(
                items: [RecoveredScan(ref: 'R1', outcome: LookupOutcome.valid)],
              ),
            ),
    );
    await cubit.start();
    expect(cubit.state.rowsFailed, isTrue);
    expect(cubit.state.id, savedId);
    await cubit.reloadRows();
    expect(cubit.state.rowsFailed, isFalse);
    expect(cubit.state.rows.single.ref, 'R1');
  });

  group('Finish (TC-MIG-053, -054)', () {
    /// Each QR answered with its own reference: the value itself.
    void answerByValue({Completer<void>? hold}) {
      var first = true;
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        if (first && hold != null) {
          first = false;
          await hold.future;
        }
        return Success(
          scanResult(
            i.positionalArguments[1] as String,
            ref: i.positionalArguments[0] as String,
          ),
        );
      });
    }

    test('TC-MIG-053 Finish answers the reads already taken, then ends the '
        'session and keeps every row for the summary', () async {
      final hold = Completer<void>();
      answerByValue(hold: hold);
      final cubit = scanner();
      await cubit.start();
      final id = cubit.state.id!;
      final reads = [
        cubit.scan(raw),
        cubit.scan('https://x/q/A1B2C3D4E5F6'),
        cubit.scan('https://x/q/B1B2C3D4E5F6'),
      ];
      final finished = cubit.complete();
      expect(cubit.state.finishing, isTrue);
      expect(cubit.state.done, isFalse);
      // No new read once Finish is pressed.
      await cubit.scan('https://x/q/C1B2C3D4E5F6');
      verifyNever(() => repo.endSession(any()));

      hold.complete();
      await Future.wait(reads);
      await finished;
      expect(cubit.state.done, isTrue);
      expect(cubit.state.finishing, isFalse);
      expect(cubit.state.id, id);
      expect(
        cubit.state.rows.map((r) => r.ref),
        ['B1B2C3D4E5F6', 'A1B2C3D4E5F6', 'Q8F2KD91XA7M'],
      );
      expect(cubit.state.answers.keys.toSet(), {
        'Q8F2KD91XA7M',
        'A1B2C3D4E5F6',
        'B1B2C3D4E5F6',
      });
      expect(
        cubit.state.answers['A1B2C3D4E5F6']!.checked.shown,
        'A1B2C3D4E5F6',
      );
      expect(cubit.state.totals, isNotNull);
      verify(() => repo.endSession(id)).called(1);
      verify(() => repo.scan(any(), any())).called(3);
      expect(storage.values, isEmpty, reason: 'the session is forgotten');

      // The summary stays when the screen is left.
      await cubit.finish();
      expect(cubit.state.rows, hasLength(3));
      verifyNever(() => repo.endSession(any()));
    });

    test('Finish keeps the count of reads let go by a failure', () async {
      final gate = Completer<void>();
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        await gate.future;
        return const Err(Failure(NetworkException()));
      });
      final cubit = scanner();
      await cubit.start();
      final reads = [
        cubit.scan(raw),
        cubit.scan('https://x/q/A1B2C3D4E5F6'),
        cubit.scan('https://x/q/B1B2C3D4E5F6'),
      ];
      final finished = cubit.complete();
      gate.complete();
      await Future.wait(reads);
      await finished;
      expect(cubit.state.done, isTrue);
      expect(cubit.state.notChecked, 2);
      expect(cubit.state.rows, isEmpty);
    });

    test('Finish waits out a 429, then sends the held read', () async {
      var calls = 0;
      when(() => repo.scan(any(), any())).thenAnswer((i) async {
        if (calls++ == 0) {
          return const Err(
            Failure(RateLimitedException(retryAfter: Duration(seconds: 1))),
          );
        }
        return Success(
          scanResult(
            i.positionalArguments[1] as String,
            ref: i.positionalArguments[0] as String,
          ),
        );
      });
      final cubit = scanner();
      await cubit.start();
      unawaited(cubit.scan(raw));
      await Future<void>.delayed(Duration.zero);
      final watch = Stopwatch()..start();
      await cubit.complete();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(900));
      expect(calls, 2);
      expect(cubit.state.done, isTrue);
      expect(cubit.state.rows.single.ref, 'Q8F2KD91XA7M');
    });

    test(
      'TC-MIG-054 Scan more starts a new session from an empty screen',
      () async {
        answerByValue();
        final cubit = scanner();
        await cubit.start();
        final old = cubit.state.id!;
        await cubit.scan(raw);
        await cubit.complete();
        expect(cubit.state.done, isTrue);

        await cubit.restart();
        expect(cubit.state.done, isFalse);
        expect(cubit.state.id, isNot(old));
        expect(cubit.state.rows, isEmpty);
        expect(cubit.state.answers, isEmpty);
        expect(storage.values.values, [cubit.state.id]);
        // The same QR counts again in the new session.
        await cubit.scan(raw);
        expect(cubit.state.rows.single.ref, 'Q8F2KD91XA7M');
        verify(() => repo.scan('Q8F2KD91XA7M', cubit.state.id!)).called(1);
      },
    );

    test('nothing to finish: Finish before the session or twice', () async {
      final cubit = scanner();
      await cubit.complete();
      expect(cubit.state.done, isFalse);
      await cubit.start();
      await cubit.complete();
      await cubit.complete();
      verify(() => repo.endSession(any())).called(1);
      await cubit.restart();
      await cubit.restart();
      expect(cubit.state.done, isFalse);
    });
  });
}
