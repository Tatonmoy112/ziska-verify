import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

class _MockRepo extends Mock implements VerificationRepository {}

/// TC-ARCH-012 … -014 (docs/test-cases/18-architecture.md): the use cases
/// through which scanner mode, the serial stack and the sessions list reach
/// the server (production audit P-3). Each one calls its repository method
/// once, with the arguments unchanged, and returns its answer untouched.
void main() {
  late _MockRepo repo;
  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(const SessionQuery());
    registerFallbackValue(const PageRequest());
  });
  setUp(() => repo = _MockRepo());

  const formats = InputFormats(
    serialMaxDigits: 19,
    qr: CodeFormat(
      length: 12,
      characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
    ),
  );
  const totals = SessionTotals(
    id: 'S-1',
    scanned: 1,
    valid: 1,
    warning: 0,
    notFound: 0,
    unassigned: 0,
    left: 4999,
  );
  const lookup = LookupResult(
    ref: 'MA-2026-000001',
    outcome: LookupOutcome.valid,
    reasons: [],
  );
  const scan = ScanResult(result: lookup, repeat: false, session: totals);
  final summary = ScanSessionSummary(
    totals: totals,
    kind: SessionKind.qr,
    status: ScanStatus.open,
    startedAt: DateTime.utc(2026, 11, 24, 4),
    lastScanAt: DateTime.utc(2026, 11, 24, 5),
  );
  const stack = SerialStackResult(
    session: totals,
    items: [SerialStackRow(serial: '0001000001', result: lookup)],
  );

  /// Each use case, called the way the cubits call it, with the one
  /// repository call it must make; typed, so a stub answers what the
  /// repository really returns.
  ({
    Future<Result<Object?>> Function() run,
    void Function(Failure? failure) stub,
    void Function() verifyOnce,
    Object? answer,
  })
  useCase<T>({
    required Future<Result<T>> Function() run,
    required Future<Result<T>> Function() call,
    required T answer,
  }) => (
    run: run,
    stub: (failure) => when(call).thenAnswer(
      (_) async => failure == null ? Success<T>(answer) : Err<T>(failure),
    ),
    verifyOnce: () => verify(call).called(1),
    answer: answer,
  );

  final calls = {
    'GetFormats': useCase(
      run: () => GetFormats(repo)(),
      call: () => repo.getFormats(),
      answer: formats,
    ),
    'GetSession': useCase(
      run: () => GetSession(repo)('S-1'),
      call: () => repo.session('S-1'),
      answer: summary,
    ),
    'ScanItem': useCase(
      run: () => ScanItem(repo)('Q8F2KD91XA7M', sessionId: 'S-1'),
      call: () => repo.scan('Q8F2KD91XA7M', 'S-1'),
      answer: scan,
    ),
    'CheckSerials': useCase(
      run: () => CheckSerials(repo)(const ['1000001', '1000002']),
      call: () => repo.serials(const ['1000001', '1000002']),
      answer: stack,
    ),
    'EndSession': useCase<void>(
      run: () => EndSession(repo)('S-1'),
      call: () => repo.endSession('S-1'),
      answer: null,
    ),
    'GetSessions': useCase(
      run: () => GetSessions(repo)(
        const SessionQuery(status: ScanStatus.open),
        const PageRequest(limit: 20, cursor: 'c-2'),
      ),
      call: () => repo.sessions(
        const SessionQuery(status: ScanStatus.open),
        const PageRequest(limit: 20, cursor: 'c-2'),
      ),
      answer: CursorPage(items: [summary], nextCursor: 'c-3'),
    ),
  };

  group('TC-ARCH-012 normal: each use case makes its one call', () {
    for (final MapEntry(key: name, value: c) in calls.entries) {
      test(name, () async {
        c.stub(null);
        final result = await c.run();
        expect(result, isA<Success<Object?>>());
        expect((result as Success).value, same(c.answer));
        c.verifyOnce();
        verifyNoMoreInteractions(repo);
      });
    }
  });

  group('TC-ARCH-013 edge: arguments pass unchanged', () {
    test('ScanItem: the value as read, trimmed by no one, and the '
        "session's ID", () async {
      const read = ' https://x.test/q/q8f2kd91xa7m ';
      const id = '7F3C2A10-5b1e-4c8e-9d4a-2e6f0b9c1d33';
      when(
        () => repo.scan(read, id),
      ).thenAnswer((_) async => const Success(scan));
      await ScanItem(repo)(read, sessionId: id);
      verify(() => repo.scan(read, id)).called(1);
    });

    // Each item once, the first typed kept, as typed (P-29: the stack's
    // rule is the use case's, TC-MIG-080 … -082).
    test(
      'CheckSerials: order and leading zeros kept, each item once',
      () async {
        final serials = ['0001', '1', '0001', '9' * 19];
        when(
          () => repo.serials(any()),
        ).thenAnswer((_) async => const Success(stack));
        await CheckSerials(repo)(serials);
        final sent = verify(() => repo.serials(captureAny())).captured.single;
        expect(sent, ['0001', '9' * 19]);
        expect(serials, ['0001', '1', '0001', '9' * 19], reason: 'not changed');
      },
    );

    test(
      'GetSessions: the same query and page objects, no cursor made up',
      () async {
        final query = SessionQuery(
          from: DateTime.utc(2026, 11, 20),
          to: DateTime.utc(2026, 11, 24),
        );
        const first = PageRequest();
        when(() => repo.sessions(query, first)).thenAnswer(
          (_) async => const Success(CursorPage<ScanSessionSummary>(items: [])),
        );
        await GetSessions(repo)(query, first);
        final captured = verify(
          () => repo.sessions(captureAny(), captureAny()),
        ).captured;
        expect(captured[0], same(query));
        expect(captured[1], same(first));
        expect((captured[1] as PageRequest).cursor, isNull);
      },
    );

    test('EndSession and GetSession: the ID as given', () async {
      const id = 'a-b-c';
      when(
        () => repo.endSession(id),
      ).thenAnswer((_) async => const Success(null));
      when(() => repo.session(id)).thenAnswer((_) async => Success(summary));
      await EndSession(repo)(id);
      await GetSession(repo)(id);
      verify(() => repo.endSession(id)).called(1);
      verify(() => repo.session(id)).called(1);
    });
  });

  group('TC-ARCH-014 worst: a failure comes back untouched', () {
    const limited = Failure(
      RateLimitedException(
        retryAfter: Duration(seconds: 30),
        statusCode: 429,
        code: 'rate_limited',
        requestId: 'req-429',
      ),
    );
    const lost = Failure(NetworkException());

    for (final MapEntry(key: name, value: c) in calls.entries) {
      for (final (label, failure) in [('429', limited), ('lost', lost)]) {
        test('$name: $label', () async {
          c.stub(failure);
          final result = await c.run();
          expect(result, isA<Err<Object?>>());
          final got = (result as Err).failure;
          expect(got, same(failure));
          expect(got.requestId, failure.requestId);
          expect(got.retryAfter, failure.retryAfter);
          c.verifyOnce();
          verifyNoMoreInteractions(repo);
        });
      }
    }
  });
}
