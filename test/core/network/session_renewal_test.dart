import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/dio_session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_secure_storage_service.dart';
import '../../fakes/scripted_adapter.dart';

const _root = 'https://api.example.test/v1/clients/demo-pharma/';

/// Builds the same wiring as `registerCore`, on scripted adapters.
({
  ApiClient api,
  DioSessionService session,
  FakeSecureStorageService storage,
})
_build({
  required ScriptedAdapter api,
  required ScriptedAdapter refresh,
}) {
  final storage = FakeSecureStorageService();
  final refreshDio = Dio(DioFactory.options(_root))
    ..httpClientAdapter = refresh;
  final session = DioSessionService(
    storage: storage,
    refreshDio: refreshDio,
    logger: FakeLoggerService(),
  );
  final dio = Dio(DioFactory.options(_root))..httpClientAdapter = api;
  dio.interceptors.add(AuthInterceptor(session: session, dio: dio));
  return (api: ApiClient(dio), session: session, storage: storage);
}

void main() {
  test('two requests failing with token_expired at once cause one renewal, '
      'and each is retried once', () async {
    final renewalGate = Completer<void>();
    final api = ScriptedAdapter((o) async {
      final auth = o.headers['Authorization'];
      if (auth == 'Bearer old-access') {
        return ScriptedAnswer(401, errorBody('token_expired'));
      }
      return ScriptedAnswer(200, okBody({'path': o.path}));
    });
    final refresh = ScriptedAdapter((o) async {
      await renewalGate.future;
      return ScriptedAnswer(
        200,
        okBody({
          'status': 'logged_in',
          'access_token': 'new-access',
          'refresh_token': 'new-refresh',
          'must_change_password': false,
        }),
      );
    });
    final w = _build(api: api, refresh: refresh);
    await w.session.saveLogin(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      mustChangePassword: false,
    );

    final a = w.api.get('me');
    final b = w.api.get('formats');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    renewalGate.complete();

    expect(await a, {'path': 'me'});
    expect(await b, {'path': 'formats'});
    expect(refresh.requests, hasLength(1));
    expect(refresh.requests.single.headers['Authorization'], isNull);
    expect(api.countPath('me'), 2);
    expect(api.countPath('formats'), 2);
    expect(w.storage.values[SecureKeys.accessToken], 'new-access');
    expect(w.storage.values[SecureKeys.refreshToken], 'new-refresh');
  });

  test('401 unauthenticated at renewal ends the session and keeps the phone '
      'ID', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('token_expired')),
    );
    final refresh = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('unauthenticated')),
    );
    final w = _build(api: api, refresh: refresh);
    w.storage.values[SecureKeys.phoneId] = 'phone-1';
    await w.session.saveLogin(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      mustChangePassword: false,
    );

    await expectLater(
      w.api.get('me'),
      throwsA(isA<UnauthenticatedException>()),
    );
    expect(w.session.current, isA<SessionUnauthenticated>());
    expect(w.storage.values[SecureKeys.accessToken], isNull);
    expect(w.storage.values[SecureKeys.refreshToken], isNull);
    expect(w.storage.values[SecureKeys.phoneId], 'phone-1');
  });

  test('a request still expired after renewal is not retried again', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('token_expired')),
    );
    final refresh = ScriptedAdapter(
      (o) async => ScriptedAnswer(
        200,
        okBody({'access_token': 'new-access', 'refresh_token': 'new-refresh'}),
      ),
    );
    final w = _build(api: api, refresh: refresh);
    await w.session.saveLogin(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      mustChangePassword: false,
    );

    await expectLater(w.api.get('me'), throwsA(isA<TokenExpiredException>()));
    expect(api.countPath('me'), 2);
    expect(refresh.requests, hasLength(1));
  });

  test('401 unauthenticated on a logged-in route ends the session', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('unauthenticated')),
    );
    final w = _build(api: api, refresh: _unused());
    await w.session.saveLogin(
      accessToken: 'a',
      refreshToken: 'r',
      mustChangePassword: false,
    );

    await expectLater(
      w.api.get('me'),
      throwsA(isA<UnauthenticatedException>()),
    );
    expect(w.session.current, isA<SessionUnauthenticated>());
  });

  test('401 on me/password (wrong old password) keeps the session', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('unauthenticated')),
    );
    final w = _build(api: api, refresh: _unused());
    await w.session.saveLogin(
      accessToken: 'a',
      refreshToken: 'r',
      mustChangePassword: false,
    );

    await expectLater(
      w.api.post('me/password', body: {}, keepSessionOn401: true),
      throwsA(isA<UnauthenticatedException>()),
    );
    expect(w.session.current, isA<SessionAuthenticated>());
    expect(w.storage.values[SecureKeys.refreshToken], 'r');
  });

  test('a wrong emailed code on verify-phone keeps the code screen', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(401, errorBody('unauthenticated')),
    );
    final w = _build(api: api, refresh: _unused());
    await w.session.restore();
    w.session.awaitCode(challengeId: 'challenge-1', email: 'a@b.c');

    await expectLater(
      w.api.post('auth/verify-phone', body: {}, skipAuth: true),
      throwsA(isA<UnauthenticatedException>()),
    );
    expect(w.session.current, isA<SessionAwaitingCode>());
    expect(api.requests.single.headers['Authorization'], isNull);
  });

  test('429 exposes Retry-After', () async {
    final api = ScriptedAdapter(
      (o) async => ScriptedAnswer(
        429,
        errorBody('rate_limited'),
        headers: {
          'retry-after': ['30'],
        },
      ),
    );
    final w = _build(api: api, refresh: _unused());

    await expectLater(
      w.api.get('formats'),
      throwsA(
        isA<RateLimitedException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 30),
        ),
      ),
    );
  });

  group('Session edge cases', sessionEdgeCases);
}

/// docs/test-cases/02-session.md: renewal edge and worst cases.
void sessionEdgeCases() {
  Map<String, Object?> renewed(String access, String refresh) => okBody({
    'status': 'logged_in',
    'access_token': access,
    'access_expires_in': 900,
    'refresh_token': refresh,
    'refresh_expires_in': 2592000,
    'must_change_password': false,
  });

  Future<void> loggedIn(DioSessionService session) => session.saveLogin(
    accessToken: 'old-access',
    refreshToken: 'old-refresh',
    mustChangePassword: false,
  );

  /// Expired with the old pass, fine with any other.
  ScriptedAdapter expiresOldPass() => ScriptedAdapter((o) async {
    if (o.headers['Authorization'] == 'Bearer old-access') {
      return ScriptedAnswer(401, errorBody('token_expired'));
    }
    return ScriptedAnswer(200, okBody({'path': o.path}));
  });

  test('TC-SESS-012 a renewal without connection keeps the login', () async {
    var online = false;
    final refresh = ScriptedAdapter((o) async {
      if (!online) {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      }
      return ScriptedAnswer(200, renewed('new-access', 'new-refresh'));
    });
    final w = _build(api: expiresOldPass(), refresh: refresh);
    await loggedIn(w.session);

    await expectLater(w.api.get('checks'), throwsA(isA<NetworkException>()));
    expect(w.session.current, isA<SessionAuthenticated>());
    expect(w.storage.values[SecureKeys.refreshToken], 'old-refresh');

    online = true;
    expect(await w.api.get('checks'), {'path': 'checks'});
  });

  test('TC-SESS-013 a renewal answered 503 keeps the login', () async {
    final refresh = ScriptedAdapter(
      (o) async => ScriptedAnswer(503, errorBody('service_unavailable')),
    );
    final w = _build(api: expiresOldPass(), refresh: refresh);
    await loggedIn(w.session);

    await expectLater(
      w.api.get('checks'),
      throwsA(isA<ServiceUnavailableException>()),
    );
    expect(w.session.current, isA<SessionAuthenticated>());
    expect(w.storage.values[SecureKeys.refreshToken], 'old-refresh');
  });

  test('TC-SESS-014 three requests expiring together: one renewal', () async {
    final gate = Completer<void>();
    final api = expiresOldPass();
    final refresh = ScriptedAdapter((o) async {
      await gate.future;
      return ScriptedAnswer(200, renewed('new-access', 'new-refresh'));
    });
    final w = _build(api: api, refresh: refresh);
    await loggedIn(w.session);

    final calls = [w.api.get('me'), w.api.get('formats'), w.api.get('checks')];
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete();
    await Future.wait(calls);

    expect(refresh.requests, hasLength(1));
    for (final path in ['me', 'formats', 'checks']) {
      expect(api.countPath(path), 2, reason: path);
    }
  });

  test('TC-SESS-016 both new passes are stored before the retry', () async {
    late FakeSecureStorageService storage;
    final seenAtRetry = <String?>[];
    final api = ScriptedAdapter((o) async {
      if (o.headers['Authorization'] == 'Bearer old-access') {
        return ScriptedAnswer(401, errorBody('token_expired'));
      }
      seenAtRetry
        ..add(storage.values[SecureKeys.accessToken])
        ..add(storage.values[SecureKeys.refreshToken])
        ..add(o.headers['Authorization'] as String?);
      return ScriptedAnswer(200, okBody(null));
    });
    final refresh = ScriptedAdapter(
      (o) async => ScriptedAnswer(200, renewed('new-access', 'new-refresh')),
    );
    final w = _build(api: api, refresh: refresh);
    storage = w.storage;
    await loggedIn(w.session);

    await w.api.get('checks');
    expect(seenAtRetry, ['new-access', 'new-refresh', 'Bearer new-access']);
  });

  test('TC-SESS-017 a refresh pass is sent only once; '
      'TC-SESS-018 the renewal carries no Authorization header', () async {
    var n = 0;
    final refresh = ScriptedAdapter((o) async {
      n++;
      return ScriptedAnswer(200, renewed('access-$n', 'refresh-$n'));
    });
    // The passes that have run out.
    final expired = {'Bearer old-access'};
    final api = ScriptedAdapter((o) async {
      if (expired.contains(o.headers['Authorization'])) {
        return ScriptedAnswer(401, errorBody('token_expired'));
      }
      return ScriptedAnswer(200, okBody(null));
    });
    final w = _build(api: api, refresh: refresh);
    await loggedIn(w.session);

    await w.api.get('checks');
    expired.add('Bearer access-1'); // 15 minutes later
    await w.api.get('checks');

    final sent = [
      for (final r in refresh.requests)
        (r.data as Map<String, dynamic>)['refresh_token'],
    ];
    expect(sent, ['old-refresh', 'refresh-1']);
    for (final r in refresh.requests) {
      expect(r.headers['Authorization'], isNull);
      expect((r.data as Map<String, dynamic>).keys, ['refresh_token']);
    }
  });

  test('TC-SESS-020 an expired lookup is retried exactly once', () async {
    final api = expiresOldPass();
    final refresh = ScriptedAdapter(
      (o) async => ScriptedAnswer(200, renewed('new-access', 'new-refresh')),
    );
    final w = _build(api: api, refresh: refresh);
    await loggedIn(w.session);

    await w.api.post('lookups', body: {'way': 'serial', 'value': '1000001'});
    expect(api.countPath('lookups'), 2);
    expect(refresh.requests, hasLength(1));
  });
}

/// An adapter that must never be called.
ScriptedAdapter _unused() => ScriptedAdapter(
  (o) async => throw StateError('unexpected request to ${o.path}'),
);
