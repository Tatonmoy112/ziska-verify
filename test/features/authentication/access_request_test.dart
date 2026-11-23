import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/features/authentication/data/repositories/access_request_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/access_request_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/request_access_cubit.dart';

import '../../fakes/fake_session_service.dart';
import '../../fakes/postman_examples.dart';
import '../../fakes/scripted_adapter.dart';

class MockRequests extends Mock implements AccessRequestRepository {}

const request = AccessRequest(
  email: 'person@example.com',
  code: '123456',
  name: 'Rahim Store',
  roleId: 7,
  password: 'abcd1234',
);
const roles = [RequestableRole(id: 7, name: 'Retail seller')];
void main() {
  setUpAll(() => registerFallbackValue(request));
  group('public access contract', () {
    late ScriptedAdapter adapter;
    late AccessRequestRepositoryImpl repository;
    late FakeSessionService session;
    late ScriptedAnswer answer;
    setUp(() {
      session = FakeSessionService()..savedAccess = 'existing-access';
      adapter = ScriptedAdapter((_) async => answer);
      final dio = Dio(
        DioFactory.options('https://api.example.test/v1/clients/x/'),
      )..httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(session: session, dio: dio));
      repository = AccessRequestRepositoryImpl(
        AccessRequestApiService(ApiClient(dio)),
      );
      addTearDown(session.dispose);
    });
    test(
      'roles are parsed without attaching an existing access token',
      () async {
        answer = ScriptedAnswer(
          200,
          postmanExample(
            request: '1. The roles that can be requested',
            example: '200 The roles',
          ),
        );
        final result =
            await repository.roles() as Success<List<RequestableRole>>;
        expect(result.value.map((r) => r.id), [8, 7]);
        expect(
          adapter.requests.single.headers.containsKey('Authorization'),
          isFalse,
        );
        expect(adapter.requests.single.path, 'roles/requestable');
      },
    );
    test('code request is public and sends only email', () async {
      answer = ScriptedAnswer(200, okBody(null));
      await repository.sendCode(request.email);
      expect(adapter.requests.single.data, {'email': request.email});
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
    test('pending request sends exact documented fields', () async {
      answer = ScriptedAnswer(200, okBody({'status': 'pending'}));
      expect(await repository.submit(request), isA<Success<void>>());
      expect(adapter.requests.single.data, {
        'email': request.email,
        'code': '123456',
        'name': 'Rahim Store',
        'role_id': 7,
        'password': 'abcd1234',
      });
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
    test('invalid access code never ends an existing login', () async {
      answer = ScriptedAnswer(401, errorBody('unauthenticated'));
      expect(await repository.submit(request), isA<Err<void>>());
      expect(session.endCalls, 0);
      expect(session.accessToken, 'existing-access');
    });
    test('unexpected successful status fails safely', () async {
      answer = ScriptedAnswer(200, okBody({'status': 'logged_in'}));
      expect(await repository.submit(request), isA<Err<void>>());
    });
  });
  group('access request state', () {
    late MockRequests repo;
    late RequestAccessCubit cubit;
    setUp(() {
      repo = MockRequests();
      when(repo.roles).thenAnswer((_) async => const Success(roles));
      when(
        () => repo.sendCode(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repo.submit(any()),
      ).thenAnswer((_) async => const Success(null));
      cubit = RequestAccessCubit(
        roles: GetRequestableRoles(repo),
        sendCode: SendAccessCode(repo),
        submit: SubmitAccessRequest(repo),
      );
      addTearDown(cubit.close);
    });
    test(
      'request success is pending without a session or retained secret',
      () async {
        await cubit.load();
        await cubit.sendCode(request.email);
        expect(cubit.state.stage, AccessStage.code);
        await cubit.submit(request);
        expect(cubit.state.stage, AccessStage.pending);
        expect(cubit.state.email, isNull);
        expect(cubit.state.toString(), isNot(contains(request.password)));
      },
    );
    test('empty roles prevent sending a code', () async {
      when(repo.roles).thenAnswer((_) async => const Success([]));
      await cubit.load();
      await cubit.sendCode(request.email);
      expect(cubit.state.roles, isEmpty);
      verifyNever(() => repo.sendCode(any()));
    });
    test('editing email invalidates the code step', () async {
      await cubit.load();
      await cubit.sendCode(request.email);
      cubit.emailEdited();
      await cubit.submit(request);
      expect(cubit.state.stage, AccessStage.form);
      verifyNever(() => repo.submit(any()));
    });
    for (final error in <AppException>[
      const PolicyDeniedException(),
      const NotFoundException(),
      const UnauthenticatedException(),
    ]) {
      test('${error.runtimeType} preserves the code step', () async {
        when(
          () => repo.submit(any()),
        ).thenAnswer((_) async => Err(Failure(error)));
        await cubit.load();
        await cubit.sendCode(request.email);
        final version = cubit.state.codeVersion;
        await cubit.submit(request);
        expect(cubit.state.stage, AccessStage.code);
        expect(cubit.state.codeVersion, version);
      });
    }
    test(
      'a failed role refresh preserves the code and entered email',
      () async {
        await cubit.load();
        await cubit.sendCode(request.email);
        final version = cubit.state.codeVersion;
        when(
          repo.roles,
        ).thenAnswer((_) async => const Err(Failure(NetworkException())));
        await cubit.load();
        expect(cubit.state.stage, AccessStage.code);
        expect(cubit.state.email, request.email);
        expect(cubit.state.codeVersion, version);
      },
    );
    test('409 consumes the code and requires sending another', () async {
      when(
        () => repo.submit(any()),
      ).thenAnswer((_) async => const Err(Failure(ConflictException())));
      await cubit.load();
      await cubit.sendCode(request.email);
      final version = cubit.state.codeVersion;
      await cubit.submit(request);
      expect(cubit.state.stage, AccessStage.form);
      expect(cubit.state.codeVersion, greaterThan(version));
      await cubit.submit(request);
      verify(() => repo.submit(any())).called(1);
    });
    test(
      '429 exposes its countdown and blocks repeated code requests',
      () async {
        when(() => repo.sendCode(any())).thenAnswer(
          (_) async => const Err(
            Failure(RateLimitedException(retryAfter: Duration(seconds: 30))),
          ),
        );
        await cubit.load();
        await cubit.sendCode(request.email);
        await cubit.sendCode(request.email);
        expect(cubit.state.waiting, isTrue);
        verify(() => repo.sendCode(any())).called(1);
      },
    );
    test(
      'duplicate submission is dropped while one request is in flight',
      () async {
        final pending = Completer<Result<void>>();
        when(() => repo.submit(any())).thenAnswer((_) => pending.future);
        await cubit.load();
        await cubit.sendCode(request.email);
        final sending = cubit.submit(request);
        await cubit.submit(request);
        pending.complete(const Success(null));
        await sending;
        verify(() => repo.submit(any())).called(1);
      },
    );
    test('invalid email is refused before requesting a code', () async {
      expect(await SendAccessCode(repo)('bad'), isA<Err<void>>());
      verifyNever(() => repo.sendCode(any()));
    });
    test('form boundaries and trimming preserve the chosen password', () async {
      final submit = SubmitAccessRequest(repo);
      expect(
        await submit(
          AccessRequest(
            email: 'a@b',
            code: '123456',
            name: 'a' * 101,
            roleId: 7,
            password: 'abcd1234',
          ),
        ),
        isA<Err<void>>(),
      );
      expect(
        await submit(
          AccessRequest(
            email: ' a@b ',
            code: '123456',
            name: " ${'a' * 100} ",
            roleId: 7,
            password: ' abcd1234 ',
          ),
        ),
        isA<Success<void>>(),
      );
      final sent =
          verify(() => repo.submit(captureAny())).captured.single
              as AccessRequest;
      expect(sent.email, 'a@b');
      expect(sent.name, 'a' * 100);
      expect(sent.password, ' abcd1234 ');
    });
    // TC-MIG-065: a name is 1 to 100 characters, and every length counts
    // code points: an emoji counts as one (backend DEC-429; guide §1, §3.9).
    test('TC-MIG-065 the name is at most 100 code points', () async {
      final submit = SubmitAccessRequest(repo);
      Future<Result<void>> named(String name) => submit(
        AccessRequest(
          email: 'a@b',
          code: '123456',
          name: name,
          roleId: 7,
          password: 'abcd1234',
        ),
      );
      expect(await named('${'a' * 99}🙂'), isA<Success<void>>());
      expect(await named('🙂' * 100), isA<Success<void>>());
      expect(await named('ক' * 100), isA<Success<void>>());
      expect(await named(' ${'a' * 100} '), isA<Success<void>>());
      expect(await named('${'a' * 100}🙂'), isA<Err<void>>());
      expect(await named('🙂' * 101), isA<Err<void>>());
      // A password of 128 code points passes too, as on the server.
      expect(
        await submit(
          AccessRequest(
            email: 'a@b',
            code: '123456',
            name: 'Test',
            roleId: 7,
            password: 'a1${'a' * 125}🙂',
          ),
        ),
        isA<Success<void>>(),
      );
    });
    test('invalid form values do not reach the API', () async {
      final submit = SubmitAccessRequest(repo);
      for (final invalid in [
        const AccessRequest(
          email: 'bad',
          code: '123456',
          name: 'A',
          roleId: 7,
          password: 'abcd1234',
        ),
        const AccessRequest(
          email: 'a@b',
          code: '12345',
          name: 'A',
          roleId: 7,
          password: 'abcd1234',
        ),
        const AccessRequest(
          email: 'a@b',
          code: '123456',
          name: '',
          roleId: 7,
          password: 'abcd1234',
        ),
        const AccessRequest(
          email: 'a@b',
          code: '123456',
          name: 'A',
          roleId: 0,
          password: 'abcd1234',
        ),
        const AccessRequest(
          email: 'a@b',
          code: '123456',
          name: 'A',
          roleId: 7,
          password: 'password',
        ),
      ]) {
        expect(await submit(invalid), isA<Err<void>>());
      }
      verifyNever(() => repo.submit(any()));
    });

    // TC-MIG-042 (data-flow audit B4, guide 1): codes and requests have
    // their own hourly limits, so a 429 on one never blocks the other.
    test('TC-MIG-042 a code 429 does not block sending the request', () async {
      await cubit.load();
      await cubit.sendCode(request.email);
      when(() => repo.sendCode(any())).thenAnswer(
        (_) async => const Err(
          Failure(RateLimitedException(retryAfter: Duration(minutes: 30))),
        ),
      );
      await cubit.sendCode(request.email);
      expect(cubit.state.codeWaiting, isTrue);
      expect(cubit.state.submitWaiting, isFalse);
      await cubit.submit(request);
      expect(cubit.state.stage, AccessStage.pending);
      verify(() => repo.submit(any())).called(1);
    });
  });
}
