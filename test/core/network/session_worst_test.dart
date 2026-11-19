import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/session/dio_session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_secure_storage_service.dart';
import '../../fakes/scripted_adapter.dart';

const _root = 'https://api.example.test/v1/clients/demo-pharma/';

/// Secure storage that fails when told to (a broken keystore, a full disk).
class _FailingStorage extends FakeSecureStorageService {
  bool failReads = false;
  bool failWrites = false;
  bool failDeletes = false;

  @override
  Future<String?> read(String key) =>
      failReads ? Future.error(Exception('keystore')) : super.read(key);

  @override
  Future<void> write(String key, String value) => failWrites
      ? Future.error(Exception('disk full'))
      : super.write(key, value);

  @override
  Future<void> delete(String key) =>
      failDeletes ? Future.error(Exception('keystore')) : super.delete(key);
}

({ApiClient api, DioSessionService session, _FailingStorage storage}) _build({
  required ScriptedAdapter api,
  required ScriptedAdapter refresh,
}) {
  final storage = _FailingStorage();
  final session = DioSessionService(
    storage: storage,
    refreshDio: Dio(DioFactory.options(_root))..httpClientAdapter = refresh,
    logger: FakeLoggerService(),
  );
  final dio = Dio(DioFactory.options(_root))..httpClientAdapter = api;
  dio.interceptors.add(AuthInterceptor(session: session, dio: dio));
  return (api: ApiClient(dio), session: session, storage: storage);
}

Map<String, dynamic> _renewed(Object access, Object refresh) => okBody({
  'status': 'logged_in',
  'access_token': access,
  'refresh_token': refresh,
  'must_change_password': false,
});

/// Worst cases of the session (final.md Sections 6.1, 6.4, 6.5):
/// TC-SESS-033 … -037.
void main() {
  test(
    'TC-SESS-033 a renewal answer of the wrong shape keeps the login',
    () async {
      final w = _build(
        api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
        refresh: ScriptedAdapter(
          (_) async => ScriptedAnswer(200, _renewed(123, 'r2')),
        ),
      );
      await w.session.saveLogin(
        accessToken: 'a1',
        refreshToken: 'r1',
        mustChangePassword: false,
      );
      final result = await w.session.renew();
      expect(result, isA<RenewalFailed>());
      expect(w.session.current, isA<SessionAuthenticated>());
      expect(w.storage.values[SecureKeys.accessToken], 'a1');
      expect(w.storage.values[SecureKeys.refreshToken], 'r1');
    },
  );

  group('TC-SESS-034 secure storage cannot be read at start', () {
    test('the session starts logged out instead of failing', () async {
      final w = _build(
        api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
        refresh: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
      );
      w.storage.failReads = true;
      await w.session.restore();
      expect(w.session.current, isA<SessionUnauthenticated>());
      expect(w.session.accessToken, isNull);
    });

    test(
      'a phone ID that failed is asked for again, not kept failed',
      () async {
        final storage = _FailingStorage()..failReads = true;
        final ids = SecurePhoneIdService(storage);
        await expectLater(ids.getOrCreate(), throwsA(anything));
        storage.failReads = false;
        expect(await ids.getOrCreate(), hasLength(43));
      },
    );
  });

  group('TC-SESS-035 secure storage cannot be written or cleared', () {
    test(
      'logout still reaches Login when the passes cannot be deleted',
      () async {
        final w = _build(
          api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
          refresh: ScriptedAdapter(
            (_) async => ScriptedAnswer(200, okBody({})),
          ),
        );
        await w.session.saveLogin(
          accessToken: 'a1',
          refreshToken: 'r1',
          mustChangePassword: false,
        );
        w.storage.failDeletes = true;
        await w.session.end();
        expect(w.session.current, isA<SessionUnauthenticated>());
        expect(w.session.accessToken, isNull);
      },
    );

    test(
      'a login that cannot be stored is an app error, not a crash',
      () async {
        final w = _build(
          api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
          refresh: ScriptedAdapter(
            (_) async => ScriptedAnswer(200, okBody({})),
          ),
        );
        w.storage.failWrites = true;
        await expectLater(
          w.session.saveLogin(
            accessToken: 'a1',
            refreshToken: 'r1',
            mustChangePassword: false,
          ),
          throwsA(isA<AppException>()),
        );
        expect(w.session.current, isNot(isA<SessionAuthenticated>()));
      },
    );
  });

  test(
    'TC-SESS-036 logout while a renewal runs: nothing is stored again',
    () async {
      final gate = Completer<void>();
      final w = _build(
        api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
        refresh: ScriptedAdapter((_) async {
          await gate.future;
          return ScriptedAnswer(200, _renewed('a2', 'r2'));
        }),
      );
      await w.session.saveLogin(
        accessToken: 'a1',
        refreshToken: 'r1',
        mustChangePassword: false,
      );
      final renewal = w.session.renew();
      await Future<void>.delayed(Duration.zero);
      await w.session.end();
      gate.complete();
      final result = await renewal;

      expect(result, isA<SessionEnded>());
      expect(w.session.current, isA<SessionUnauthenticated>());
      expect(w.session.accessToken, isNull);
      expect(w.storage.values[SecureKeys.accessToken], isNull);
      expect(w.storage.values[SecureKeys.refreshToken], isNull);
    },
  );

  test(
    'TC-SESS-037 a late 401 for an older pass does not end a new login',
    () async {
      final gate = Completer<void>();
      final arrived = Completer<void>();
      final seen = <String?>[];
      final w = _build(
        api: ScriptedAdapter((o) async {
          final auth = o.headers['Authorization'] as String?;
          seen.add(auth);
          if (auth == 'Bearer a-old') {
            arrived.complete();
            await gate.future;
            return ScriptedAnswer(401, errorBody('unauthenticated'));
          }
          return ScriptedAnswer(200, okBody({'ok': true}));
        }),
        refresh: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
      );
      await w.session.saveLogin(
        accessToken: 'a-old',
        refreshToken: 'r-old',
        mustChangePassword: false,
      );
      // A request of the old login, still on its way.
      final late = w.api.get('checks');
      await arrived.future;
      // Logged out and in again meanwhile.
      await w.session.end();
      await w.session.saveLogin(
        accessToken: 'a-new',
        refreshToken: 'r-new',
        mustChangePassword: false,
      );
      gate.complete();
      await late;

      expect(w.session.current, isA<SessionAuthenticated>());
      expect(w.session.accessToken, 'a-new');
      expect(seen.last, 'Bearer a-new');
    },
  );

  test(
    'TC-SESS-043 a late 403 password_change_required for an older pass '
    'does not force a change on a new login',
    () async {
      final gate = Completer<void>();
      final arrived = Completer<void>();
      final w = _build(
        api: ScriptedAdapter((o) async {
          if (o.headers['Authorization'] == 'Bearer a-old') {
            arrived.complete();
            await gate.future;
            return ScriptedAnswer(403, errorBody('password_change_required'));
          }
          return ScriptedAnswer(200, okBody({'ok': true}));
        }),
        refresh: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
      );
      await w.session.saveLogin(
        accessToken: 'a-old',
        refreshToken: 'r-old',
        mustChangePassword: false,
      );
      final late = w.api.get('checks');
      await arrived.future;
      await w.session.end();
      await w.session.saveLogin(
        accessToken: 'a-new',
        refreshToken: 'r-new',
        mustChangePassword: false,
      );
      gate.complete();
      await expectLater(late, throwsA(isA<PasswordChangeRequiredException>()));
      expect(w.session.current, isA<SessionAuthenticated>());
    },
  );

  test(
    'TC-AUTH-102 a change that still forces a change stays forced',
    () async {
      final w = _build(
        api: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
        refresh: ScriptedAdapter((_) async => ScriptedAnswer(200, okBody({}))),
      );
      await w.session.saveLogin(
        accessToken: 'a1',
        refreshToken: 'r1',
        mustChangePassword: true,
      );
      await w.session.savePasswordChange('a2', mustChangePassword: true);
      expect(w.session.current, isA<SessionPasswordChangeRequired>());
      expect(w.session.accessToken, 'a2');
    },
  );

  group('TC-SESS-040 a renewal fails while 3 requests wait on it', () {
    Future<List<Object?>> threeAtOnce(
      Future<ScriptedAnswer> Function(RequestOptions) renewal,
    ) async {
      final w = _build(
        api: ScriptedAdapter((o) async {
          final auth = o.headers['Authorization'];
          return auth == 'Bearer a1'
              ? ScriptedAnswer(401, errorBody('token_expired'))
              : ScriptedAnswer(200, okBody({'ok': true}));
        }),
        refresh: ScriptedAdapter(renewal),
      );
      await w.session.saveLogin(
        accessToken: 'a1',
        refreshToken: 'r1',
        mustChangePassword: false,
      );
      final ended = <SessionState>[];
      final sub = w.session.states.listen(ended.add);
      addTearDown(sub.cancel);
      final results = await Future.wait([
        for (final path in ['me', 'formats', 'checks'])
          w.api.get(path).then<Object?>((v) => v, onError: (Object e) => e),
      ]);
      return [...results, ended.whereType<SessionUnauthenticated>().length];
    }

    test('offline: each fails once; the login is kept', () async {
      final out = await threeAtOnce(
        (o) async => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ),
      );
      expect(out.take(3), everyElement(isA<NetworkException>()));
      expect(out.last, 0);
    });

    test('401: each fails once; Login is reached once', () async {
      final out = await threeAtOnce(
        (_) async => ScriptedAnswer(401, errorBody('unauthenticated')),
      );
      expect(out.take(3), everyElement(isA<UnauthenticatedException>()));
      expect(out.last, 1);
    });
  });
}
