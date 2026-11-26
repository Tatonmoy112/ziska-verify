import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/verify_code_bloc.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  var now = DateTime(2026, 11, 10, 12);

  VerifyCodeBloc build() => VerifyCodeBloc(
    verifyCode: VerifyCode(repo),
    resendCode: ResendCode(repo),
    cancelCode: CancelCode(repo),
    now: () => now,
  );

  setUp(() {
    repo = _MockRepo();
    now = DateTime(2026, 11, 10, 12);
  });

  // TC-AUTH-006: Resend waits one minute.
  test('the first resend waits a minute after the code was sent', () {
    final bloc = build();
    expect(
      bloc.state.resendAvailableAt,
      now.add(const Duration(minutes: 1)),
    );
    addTearDown(bloc.close);
  });

  blocTest<VerifyCodeBloc, VerifyCodeState>(
    'a resend before the minute is up is not sent',
    build: build,
    act: (bloc) => bloc.add(const ResendRequested()),
    expect: () => <VerifyCodeState>[],
    verify: (_) => verifyNever(() => repo.resendCode()),
  );

  blocTest<VerifyCodeBloc, VerifyCodeState>(
    'after a minute it resends and waits another minute',
    setUp: () => when(
      () => repo.resendCode(),
    ).thenAnswer((_) async => const Success<void>(null)),
    build: build,
    act: (bloc) {
      now = now.add(const Duration(minutes: 1, seconds: 1));
      bloc.add(const ResendRequested());
    },
    skip: 1,
    expect: () => [
      isA<VerifyCodeState>()
          .having((s) => s.resentCount, 'resentCount', 1)
          .having(
            (s) => s.resendAvailableAt,
            'resendAvailableAt',
            now.add(const Duration(minutes: 1)),
          ),
    ],
  );

  // TC-AUTH-007: Resend honours Retry-After.
  blocTest<VerifyCodeBloc, VerifyCodeState>(
    '429 waits for Retry-After',
    setUp: () => when(() => repo.resendCode()).thenAnswer(
      (_) async => const Err<void>(
        Failure(RateLimitedException(retryAfter: Duration(seconds: 42))),
      ),
    ),
    build: build,
    act: (bloc) {
      now = now.add(const Duration(minutes: 2));
      bloc.add(const ResendRequested());
    },
    skip: 1,
    expect: () => [
      isA<VerifyCodeState>().having(
        (s) => s.resendAvailableAt,
        'resendAvailableAt',
        now.add(const Duration(seconds: 42)),
      ),
    ],
  );

  // TC-AUTH-008: After 3 resends, back to Login.
  blocTest<VerifyCodeBloc, VerifyCodeState>(
    '401 on resend means the 3 resends are used up',
    setUp: () => when(() => repo.resendCode()).thenAnswer(
      (_) async => const Err<void>(Failure(UnauthenticatedException())),
    ),
    build: build,
    act: (bloc) {
      now = now.add(const Duration(minutes: 2));
      bloc.add(const ResendRequested());
    },
    skip: 1,
    expect: () => [
      isA<VerifyCodeState>().having(
        (s) => s.resendLimitReached,
        'resendLimitReached',
        isTrue,
      ),
    ],
  );
}
