import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';

import '../domain/input_preparation_test.dart' show formats;

class _MockRepo extends Mock implements VerificationRepository {}

const _valid = LookupResult(
  ref: 'MA-1',
  outcome: LookupOutcome.valid,
  reasons: [],
);

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(LookupWay.serial));

  setUp(() {
    repo = _MockRepo();
    when(repo.getFormats).thenAnswer((_) async => const Success(formats));
  });

  LookupBloc build() => LookupBloc(
    getFormats: GetFormats(repo),
    lookupItem: LookupItem(repo),
    now: () => DateTime(2026, 11, 10),
  );

  blocTest<LookupBloc, LookupState>(
    'loads the formats once',
    build: build,
    act: (bloc) => bloc
      ..add(const FormatsRequested())
      ..add(const FormatsRequested()),
    verify: (bloc) {
      expect(bloc.state.formats, isNotNull);
      verify(repo.getFormats).called(1);
    },
  );

  blocTest<LookupBloc, LookupState>(
    'input that matches no format is refused and never sent',
    build: build,
    act: (bloc) async {
      bloc.add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const LookupRequested(LookupWay.serial, '12AB'));
    },
    verify: (bloc) {
      expect(bloc.state.status, LookupStatus.refused);
      verifyNever(() => repo.lookup(any(), any()));
    },
  );

  blocTest<LookupBloc, LookupState>(
    'a second lookup while one is in flight is dropped',
    setUp: () {
      final gate = Completer<Result<LookupResult>>();
      when(() => repo.lookup(any(), any())).thenAnswer((_) => gate.future);
      Future<void>.delayed(
        const Duration(milliseconds: 20),
        () => gate.complete(const Success(_valid)),
      );
    },
    build: build,
    act: (bloc) async {
      bloc.add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const LookupRequested(LookupWay.serial, '1000001'))
        ..add(const LookupRequested(LookupWay.serial, '1000001'));
      await Future<void>.delayed(const Duration(milliseconds: 40));
    },
    verify: (bloc) {
      expect(bloc.state.status, LookupStatus.completed);
      expect(bloc.state.result!.ref, 'MA-1');
      verify(() => repo.lookup(LookupWay.serial, '1000001')).called(1);
    },
  );

  group('what was checked (final.md Section 13.1.4)', () {
    setUp(
      () => when(
        () => repo.lookup(any(), any()),
      ).thenAnswer((_) async => const Success(_valid)),
    );

    blocTest<LookupBloc, LookupState>(
      'a serial is kept with the check time',
      build: build,
      act: (bloc) async {
        bloc.add(const FormatsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LookupRequested(LookupWay.serial, '4815 1623-4200'));
      },
      verify: (bloc) {
        final checked = bloc.state.checked!;
        expect(checked.way, LookupWay.serial);
        expect(checked.shown, '481516234200');
        expect(checked.at, DateTime(2026, 11, 10));
      },
    );

    blocTest<LookupBloc, LookupState>(
      'a scanned QR shows the value sent, not the link',
      build: build,
      act: (bloc) async {
        bloc.add(const FormatsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const LookupRequested(
            LookupWay.qr,
            'https://www.ziskaverify.com/q/Q8F2KD91XA7M',
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.checked!.shown, 'Q8F2KD91XA7M');
      },
    );

    blocTest<LookupBloc, LookupState>(
      'cleared after the result is shown',
      build: build,
      act: (bloc) async {
        bloc.add(const FormatsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LookupRequested(LookupWay.serial, '1000001'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LookupCleared());
      },
      verify: (bloc) {
        expect(bloc.state.checked, isNull);
        expect(bloc.state.result, isNull);
      },
    );
  });

  blocTest<LookupBloc, LookupState>(
    '429 keeps when the next lookup may be sent',
    setUp: () => when(() => repo.lookup(any(), any())).thenAnswer(
      (_) async => const Err(
        Failure(RateLimitedException(retryAfter: Duration(seconds: 30))),
      ),
    ),
    build: build,
    act: (bloc) async {
      bloc.add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const LookupRequested(LookupWay.serial, '1000001'));
    },
    verify: (bloc) {
      expect(bloc.state.status, LookupStatus.failed);
      expect(bloc.state.retryAt, DateTime(2026, 11, 10, 0, 0, 30));
    },
  );
}
