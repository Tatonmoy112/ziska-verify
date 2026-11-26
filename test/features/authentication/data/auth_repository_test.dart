import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';
import 'package:ziska_verify/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';

import '../../../fakes/fake_logger_service.dart';
import '../../../fakes/fake_session_service.dart';

class _MockAuthApi extends Mock implements AuthApiService {}

/// Secure storage that cannot be read: a platform error, not an app one.
class _BrokenPhoneId implements PhoneIdService {
  @override
  Future<String> getOrCreate() async =>
      throw Exception('PlatformException(keystore)');
}

class _FixedPhoneId implements PhoneIdService {
  @override
  Future<String> getOrCreate() async => 'phone-1';
}

void main() {
  late _MockAuthApi api;
  late FakeSessionService session;
  late AuthRepositoryImpl repository;

  setUp(() {
    api = _MockAuthApi();
    session = FakeSessionService(const SessionUnauthenticated());
    repository = AuthRepositoryImpl(
      api: api,
      session: session,
      phoneId: _FixedPhoneId(),
      logger: FakeLoggerService(),
    );
  });

  void login(LoginResponseDto dto) => when(
    () => api.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
      phoneId: any(named: 'phoneId'),
    ),
  ).thenAnswer((_) async => dto);

  test('code_sent moves the session to the code screen', () async {
    login(const LoginResponseDto(status: 'code_sent', challengeId: 'ch-1'));

    final result = await repository.login(email: 'a@b.c', password: 'p');

    expect((result as Success<LoginOutcome>).value, isA<CodeSent>());
    final state = session.current! as SessionAwaitingCode;
    expect(state.challengeId, 'ch-1');
    expect(state.email, 'a@b.c');
    verify(
      () => api.login(email: 'a@b.c', password: 'p', phoneId: 'phone-1'),
    ).called(1);
  });

  test('logged_in stores both passes', () async {
    login(
      const LoginResponseDto(
        status: 'logged_in',
        accessToken: 'a',
        refreshToken: 'r',
        mustChangePassword: false,
      ),
    );

    await repository.login(email: 'a@b.c', password: 'p');

    expect(session.savedAccess, 'a');
    expect(session.savedRefresh, 'r');
    expect(session.current, isA<SessionAuthenticated>());
  });

  test('must_change_password moves to the forced change', () async {
    login(
      const LoginResponseDto(
        status: 'logged_in',
        accessToken: 'a',
        refreshToken: 'r',
        mustChangePassword: true,
      ),
    );

    await repository.login(email: 'a@b.c', password: 'p');

    expect(session.current, isA<SessionPasswordChangeRequired>());
  });

  test('verify sends the challenge and the phone ID', () async {
    session.awaitCode(challengeId: 'ch-1', email: 'a@b.c');
    when(
      () => api.verifyPhone(
        challengeId: any(named: 'challengeId'),
        code: any(named: 'code'),
        phoneId: any(named: 'phoneId'),
      ),
    ).thenAnswer(
      (_) async => const LoginResponseDto(
        status: 'logged_in',
        accessToken: 'a',
        refreshToken: 'r',
      ),
    );

    await repository.verifyCode('123456');

    verify(
      () => api.verifyPhone(
        challengeId: 'ch-1',
        code: '123456',
        phoneId: 'phone-1',
      ),
    ).called(1);
    expect(session.current, isA<SessionAuthenticated>());
  });

  test('a failed login is a Failure, never a throw', () async {
    when(
      () => api.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phoneId: any(named: 'phoneId'),
      ),
    ).thenThrow(const UnauthenticatedException(statusCode: 401));

    final result = await repository.login(email: 'a@b.c', password: 'x');

    expect(
      (result as Err<LoginOutcome>).failure.exception,
      isA<UnauthenticatedException>(),
    );
    expect(session.current, isA<SessionUnauthenticated>());
  });

  // TC-SESS-009: Logout works offline.
  test('logout ends the session even when the server fails', () async {
    await session.saveLogin(
      accessToken: 'a',
      refreshToken: 'r',
      mustChangePassword: false,
    );
    when(() => api.logout()).thenThrow(const NetworkException());

    await repository.logout();

    expect(session.endCalls, 1);
    expect(session.current, isA<SessionUnauthenticated>());
  });

  // Data-flow audit A1 (guide §2): an unreadable phone ID is an app error,
  // so Login says "Something went wrong" instead of spinning.
  test('TC-SESS-042 an unreadable phone ID is an error, not a hang', () async {
    final broken = AuthRepositoryImpl(
      api: api,
      session: session,
      phoneId: _BrokenPhoneId(),
      logger: FakeLoggerService(),
    );
    final result = await broken.login(email: 'a@b.c', password: 'p');
    expect(result, isA<Err<LoginOutcome>>());
    expect(
      (result as Err<LoginOutcome>).failure.exception,
      isA<InternalErrorException>(),
    );
    verifyNever(
      () => api.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phoneId: any(named: 'phoneId'),
      ),
    );
  });
}
