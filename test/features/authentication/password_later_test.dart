import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/session/dio_session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';
import 'package:ziska_verify/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/password_cubits.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';
import 'package:ziska_verify/features/profile/data/mappers/profile_mapper.dart';
import 'package:ziska_verify/features/profile/data/models/profile_dto.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_secure_storage_service.dart';
import '../../fakes/fake_session_service.dart';
import '../../fakes/scripted_adapter.dart';

class _MockAuthApi extends Mock implements AuthApiService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FixedPhoneId implements PhoneIdService {
  @override
  Future<String> getOrCreate() async => 'phone-1';
}

/// **Not now** on a forced password change (final.md Section 6.6;
/// docs/backend-requests/password-change-later.md): the pieces under the
/// screens. TC-AUTH-094.
void main() {
  group('answers', () {
    test('password_change_skippable is read; missing means no', () {
      final skippable = LoginResponseDto.fromJson(const {
        'status': 'logged_in',
        'must_change_password': true,
        'password_change_skippable': true,
      });
      expect(skippable.passwordChangeSkippable, isTrue);
      final older = LoginResponseDto.fromJson(const {
        'status': 'logged_in',
        'must_change_password': true,
      });
      expect(older.passwordChangeSkippable, isNull);
    });

    test('me/password/later gives a new access pass', () {
      final dto = PasswordLaterResponseDto.fromJson(const {
        'access_token': 'a-later',
        'access_expires_in': 900,
        'must_change_password': false,
        'password_change_pending': true,
      });
      expect(dto.accessToken, 'a-later');
    });

    test('GET me: the new fields, false when missing', () {
      Map<String, dynamic> me([Map<String, dynamic> extra = const {}]) => {
        'id': 'u1',
        'name': 'Asha Rao',
        'email': 'a@b.c',
        'role': 'Field inspector',
        'permissions': <String>[],
        'must_change_password': true,
        ...extra,
      };
      final older = ProfileDto.fromJson(me()).toEntity();
      expect(older.passwordChangeSkippable, isFalse);
      expect(older.passwordChangePending, isFalse);
      final newer = ProfileDto.fromJson(
        me({
          'password_change_skippable': true,
          'password_change_pending': true,
        }),
      ).toEntity();
      expect(newer.passwordChangeSkippable, isTrue);
      expect(newer.passwordChangePending, isTrue);
    });
  });

  group('repository', () {
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

    void loginAnswers(LoginResponseDto dto) => when(
      () => api.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phoneId: any(named: 'phoneId'),
      ),
    ).thenAnswer((_) async => dto);

    test('a skippable forced change: the session says so', () async {
      loginAnswers(
        const LoginResponseDto(
          status: 'logged_in',
          accessToken: 'a',
          refreshToken: 'r',
          mustChangePassword: true,
          passwordChangeSkippable: true,
        ),
      );
      await repository.login(email: 'a@b.c', password: 'p');
      final state = session.current! as SessionPasswordChangeRequired;
      expect(state.canSkip, isTrue);
    });

    test('skippable without a forced change: just logged in', () async {
      loginAnswers(
        const LoginResponseDto(
          status: 'logged_in',
          accessToken: 'a',
          refreshToken: 'r',
          mustChangePassword: false,
          passwordChangeSkippable: true,
        ),
      );
      await repository.login(email: 'a@b.c', password: 'p');
      expect(session.current, isA<SessionAuthenticated>());
    });

    test('Not now stores the new access pass and logs in', () async {
      session.emitState(const SessionPasswordChangeRequired(canSkip: true));
      when(() => api.postponePasswordChange()).thenAnswer(
        (_) async => const PasswordLaterResponseDto(accessToken: 'a-later'),
      );
      final result = await repository.postponePasswordChange();
      expect(result, isA<Success<void>>());
      expect(session.savedAccess, 'a-later');
      expect(session.current, isA<SessionAuthenticated>());
    });

    test('Not now refused: the error, and the session stays', () async {
      session.emitState(const SessionPasswordChangeRequired(canSkip: true));
      when(
        () => api.postponePasswordChange(),
      ).thenThrow(const ForbiddenException());
      final result = await repository.postponePasswordChange();
      expect(
        (result as Err<void>).failure.exception,
        isA<ForbiddenException>(),
      );
      expect(session.current, isA<SessionPasswordChangeRequired>());
    });
  });

  group('session', () {
    late FakeSecureStorageService storage;
    late DioSessionService session;
    late ScriptedAdapter refresh;
    var renewal = <String, dynamic>{};

    setUp(() {
      storage = FakeSecureStorageService();
      refresh = ScriptedAdapter(
        (_) async => ScriptedAnswer(200, okBody(renewal)),
      );
      session = DioSessionService(
        storage: storage,
        refreshDio: Dio(DioFactory.options('https://api.example.test/'))
          ..httpClientAdapter = refresh,
        logger: FakeLoggerService(),
      );
    });

    tearDown(() => session.dispose());

    test(
      'the login decides; a bare 403 keeps it; GET me can change it',
      () async {
        await session.saveLogin(
          accessToken: 'a',
          refreshToken: 'r',
          mustChangePassword: true,
          canSkip: true,
        );
        expect(
          (session.current! as SessionPasswordChangeRequired).canSkip,
          isTrue,
        );
        // A 403 password_change_required does not say: the last value stays.
        session.requirePasswordChange();
        expect(
          (session.current! as SessionPasswordChangeRequired).canSkip,
          isTrue,
        );
        // GET me says it may no longer be skipped.
        session.requirePasswordChange(canSkip: false);
        expect(
          (session.current! as SessionPasswordChangeRequired).canSkip,
          isFalse,
        );
      },
    );

    test(
      'Not now: the access pass is replaced, the refresh pass stays',
      () async {
        await session.saveLogin(
          accessToken: 'a',
          refreshToken: 'r',
          mustChangePassword: true,
          canSkip: true,
        );
        await session.postponePasswordChange('a-later');
        expect(session.current, isA<SessionAuthenticated>());
        expect(session.accessToken, 'a-later');
        expect(storage.values[SecureKeys.accessToken], 'a-later');
        expect(storage.values[SecureKeys.refreshToken], 'r');
      },
    );

    test('a renewal that still forces the change carries the choice', () async {
      await session.saveLogin(
        accessToken: 'a',
        refreshToken: 'r',
        mustChangePassword: false,
      );
      renewal = {
        'status': 'logged_in',
        'access_token': 'a2',
        'refresh_token': 'r2',
        'must_change_password': true,
        'password_change_skippable': true,
      };
      await session.renew();
      final state = session.current! as SessionPasswordChangeRequired;
      expect(state.canSkip, isTrue);
    });

    test('a renewal after Not now does not force the change again', () async {
      await session.saveLogin(
        accessToken: 'a',
        refreshToken: 'r',
        mustChangePassword: true,
        canSkip: true,
      );
      await session.postponePasswordChange('a-later');
      renewal = {
        'status': 'logged_in',
        'access_token': 'a2',
        'refresh_token': 'r2',
        'must_change_password': false,
      };
      await session.renew();
      expect(session.current, isA<SessionAuthenticated>());
    });
  });

  group('cubit', () {
    late _MockAuthRepository repository;

    setUp(() => repository = _MockAuthRepository());

    blocTest<PostponePasswordCubit, SubmitState>(
      'two taps while one runs send one request',
      setUp: () => when(() => repository.postponePasswordChange()).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return const Success(null);
        },
      ),
      build: () => PostponePasswordCubit(PostponePasswordChange(repository)),
      act: (cubit) => Future.wait([cubit.submit(), cubit.submit()]),
      verify: (cubit) {
        verify(() => repository.postponePasswordChange()).called(1);
        expect(cubit.state.status, SubmitStatus.success);
      },
    );
  });
}
