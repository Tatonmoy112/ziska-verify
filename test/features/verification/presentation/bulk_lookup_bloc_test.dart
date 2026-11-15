import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/bulk_lookup_bloc.dart';

import '../domain/input_preparation_test.dart' show formats;

class _MockRepo extends Mock implements VerificationRepository {}

const _summary = BulkSummary(
  total: 1,
  valid: 1,
  warning: 0,
  byReason: {},
  notFound: 0,
  unassigned: 0,
);

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(<BulkEntry>[]));

  setUp(() {
    repo = _MockRepo();
    when(repo.getFormats).thenAnswer((_) async => const Success(formats));
  });

  BulkLookupBloc build() => BulkLookupBloc(
    getFormats: GetFormats(repo),
    bulkLookup: BulkLookup(repo),
    now: () => DateTime(2026, 11, 10),
  );

  Future<void> ready(BulkLookupBloc bloc) async {
    bloc.add(const BulkFormatsRequested());
    await Future<void>.delayed(Duration.zero);
  }

  blocTest<BulkLookupBloc, BulkLookupState>(
    'adds checked items in order; a QR keeps only the value after /q/',
    build: build,
    act: (bloc) async {
      await ready(bloc);
      bloc
        ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
        ..add(
          const BulkItemAdded(
            LookupWay.qr,
            'https://www.ziskaverify.com/q/Q8F2KD91XA7M',
          ),
        )
        ..add(const BulkItemAdded(LookupWay.hiddenCode, '4815 1623 4200'));
    },
    verify: (bloc) {
      final e = bloc.state.entries;
      expect(e.map((x) => x.value), [
        '1000001',
        'Q8F2KD91XA7M',
        '481516234200',
      ]);
      // A hidden code is shown masked in the list.
      expect(e[2].label, '*****200');
    },
  );

  blocTest<BulkLookupBloc, BulkLookupState>(
    'refuses a wrong format and a duplicate',
    build: build,
    act: (bloc) async {
      await ready(bloc);
      bloc
        ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
        ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
        ..add(const BulkItemAdded(LookupWay.qr, 'https://example.com/menu'));
    },
    verify: (bloc) {
      expect(bloc.state.entries, hasLength(1));
      expect(bloc.state.addProblemCount, 2);
      expect(bloc.state.addProblem, isA<AddRefused>());
    },
  );

  blocTest<BulkLookupBloc, BulkLookupState>(
    'stops at 500 items',
    build: build,
    act: (bloc) async {
      await ready(bloc);
      for (var i = 1; i <= bulkMaxItems + 1; i++) {
        bloc.add(BulkItemAdded(LookupWay.serial, '$i'));
      }
    },
    verify: (bloc) {
      expect(bloc.state.entries, hasLength(bulkMaxItems));
      expect(bloc.state.addProblem, isA<AddListFull>());
    },
  );

  blocTest<BulkLookupBloc, BulkLookupState>(
    'after the results the typed values are dropped',
    setUp: () => when(() => repo.bulkLookup(any())).thenAnswer(
      (_) async => const Success(BulkOutcome(summary: _summary, rows: [])),
    ),
    build: build,
    act: (bloc) async {
      await ready(bloc);
      bloc
        ..add(const BulkItemAdded(LookupWay.hiddenCode, '481516234200'))
        ..add(const BulkSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.status, BulkStatus.done);
      expect(bloc.state.entries, isEmpty);
      expect(bloc.state.outcome, isNotNull);
      // Every row's check time on its result screen (Section 13.1.4).
      expect(bloc.state.checkedAt, DateTime(2026, 11, 10));
    },
  );

  blocTest<BulkLookupBloc, BulkLookupState>(
    '503: nothing was checked, the same list stays to send again',
    setUp: () => when(() => repo.bulkLookup(any())).thenAnswer(
      (_) async => const Err(Failure(ServiceUnavailableException())),
    ),
    build: build,
    act: (bloc) async {
      await ready(bloc);
      bloc
        ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
        ..add(const BulkItemAdded(LookupWay.serial, '1000002'))
        ..add(const BulkSubmitted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const BulkSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.status, BulkStatus.failed);
      expect(bloc.state.entries, hasLength(2));
      final sent = verify(() => repo.bulkLookup(captureAny())).captured;
      expect(sent, hasLength(2));
      expect(
        (sent.last as List<BulkEntry>).map((e) => e.value),
        ['1000001', '1000002'],
      );
    },
  );

  // docs/test-cases/05-bulk.md: edge and worst cases.
  group('edge cases', () {
    void answer(Future<Result<BulkOutcome>> Function() reply) =>
        when(() => repo.bulkLookup(any())).thenAnswer((_) => reply());

    List<BulkEntry> sentList() =>
        verify(() => repo.bulkLookup(captureAny())).captured.last
            as List<BulkEntry>;

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-016 one item is sent in one request',
      setUp: () => answer(
        () async => const Success(BulkOutcome(summary: _summary, rows: [])),
      ),
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
          ..add(const BulkSubmitted());
      },
      verify: (_) => expect(sentList(), hasLength(1)),
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-017 exactly 500 items go in one request',
      setUp: () => answer(
        () async => const Success(BulkOutcome(summary: _summary, rows: [])),
      ),
      build: build,
      act: (bloc) async {
        await ready(bloc);
        for (var i = 1; i <= bulkMaxItems; i++) {
          bloc.add(BulkItemAdded(LookupWay.serial, '$i'));
        }
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.entries, hasLength(500));
        expect(bloc.state.addProblem, isNull);
        bloc.add(const BulkSubmitted());
      },
      verify: (_) => expect(sentList(), hasLength(500)),
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-019 the same hidden code with spaces is a duplicate',
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.hiddenCode, '4815 1623 4200'))
          ..add(const BulkItemAdded(LookupWay.hiddenCode, '481516234200'));
      },
      verify: (bloc) {
        expect(bloc.state.entries, hasLength(1));
        expect(bloc.state.addProblem, isA<AddDuplicate>());
      },
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-020 the same value in another way is not a duplicate',
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '123456789012'))
          ..add(const BulkItemAdded(LookupWay.hiddenCode, '123456789012'));
      },
      verify: (bloc) => expect(bloc.state.entries, hasLength(2)),
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-023 one press, one bulk request',
      setUp: () => answer(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const Success(BulkOutcome(summary: _summary, rows: []));
      }),
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
          ..add(const BulkSubmitted())
          ..add(const BulkSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (_) => verify(() => repo.bulkLookup(any())).called(1),
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-024 a lost connection is never resent by itself',
      setUp: () => answer(
        () async => const Err(Failure(NetworkException())),
      ),
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
          ..add(const BulkSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        verify(() => repo.bulkLookup(any())).called(1);
        expect(bloc.state.status, BulkStatus.failed);
      },
    );

    blocTest<BulkLookupBloc, BulkLookupState>(
      'TC-BULK-037 the list cannot change while it is sent',
      setUp: () => answer(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const Success(BulkOutcome(summary: _summary, rows: []));
      }),
      build: build,
      act: (bloc) async {
        await ready(bloc);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
          ..add(const BulkItemAdded(LookupWay.serial, '1000002'))
          ..add(const BulkSubmitted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(const BulkItemAdded(LookupWay.serial, '1000003'))
          ..add(const BulkItemRemoved(0));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        expect(sentList().map((e) => e.value), ['1000001', '1000002']);
        expect(bloc.state.status, BulkStatus.done);
      },
    );
  });

  blocTest<BulkLookupBloc, BulkLookupState>(
    '429: waits for Retry-After before the list can be sent again',
    setUp: () => when(() => repo.bulkLookup(any())).thenAnswer(
      (_) async => const Err(
        Failure(RateLimitedException(retryAfter: Duration(seconds: 42))),
      ),
    ),
    build: build,
    act: (bloc) async {
      await ready(bloc);
      bloc
        ..add(const BulkItemAdded(LookupWay.serial, '1000001'))
        ..add(const BulkSubmitted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const BulkSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.retryAt, DateTime(2026, 11, 10, 0, 0, 42));
      verify(() => repo.bulkLookup(any())).called(1);
    },
  );
}
