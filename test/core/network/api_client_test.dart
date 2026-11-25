import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/dio_session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_secure_storage_service.dart';
import '../../fakes/scripted_adapter.dart';

const _root = 'https://api.example.test/v1/clients/demo-pharma/';

/// A transport that reports every request as cancelled, as Dio does when
/// something below the app gives a request up.
ScriptedAdapter _cancelling() => ScriptedAdapter(
  (r) async =>
      throw DioException(requestOptions: r, type: DioExceptionType.cancel),
);

/// TC-ARCH-029 … -031 (docs/test-cases/18-architecture.md): `ApiClient`
/// has no cancel parameter no caller uses, and a cancel Dio reports anyway
/// is still one typed error (production audit P-18).
void main() {
  group("TC-ARCH-029 normal: ApiClient's calls take no cancel token", () {
    test('get, post and postBytes, and nothing else public', () {
      final source = File(
        'lib/core/network/api_client.dart',
      ).readAsStringSync();
      final start = source.indexOf('class ApiClient {');
      final end = source.indexOf('\n}\n', start);
      expect(start, isNot(-1));
      final body = source.substring(start, end);
      expect(body, isNot(contains('CancelToken')));
      expect(body, isNot(contains('cancelToken')));
      final public = RegExp(
        r'^  Future<Object\?> ([a-zA-Z]\w*)\(',
        multiLine: true,
      ).allMatches(body).map((m) => m.group(1)).toSet();
      expect(public, {'get', 'post', 'postBytes'});
    });
  });

  group('TC-ARCH-030 edge: a cancel Dio reports anyway is one typed error', () {
    late ScriptedAdapter adapter;
    late ApiClient api;
    setUp(() {
      adapter = _cancelling();
      api = ApiClient(
        Dio(DioFactory.options(_root))..httpClientAdapter = adapter,
      );
    });

    test('on get, post and postBytes', () async {
      await expectLater(
        api.get(ApiRoutes.me),
        throwsA(isA<RequestCancelledException>()),
      );
      await expectLater(
        api.post(ApiRoutes.lookups, body: {'code': 'x'}),
        throwsA(isA<RequestCancelledException>()),
      );
      await expectLater(
        api.postBytes(
          ApiRoutes.reportPhotos(1),
          Uint8List(4),
          contentType: 'image/jpeg',
        ),
        throwsA(isA<RequestCancelledException>()),
      );
      expect(adapter.requests, hasLength(3));
    });
  });

  group('TC-ARCH-031 worst: a cancelled request is not a lost login', () {
    test('no retry, no renewal, the login kept', () async {
      final storage = FakeSecureStorageService();
      final refresh = ScriptedAdapter(
        (_) async => ScriptedAnswer(200, okBody({})),
      );
      final session = DioSessionService(
        storage: storage,
        refreshDio: Dio(DioFactory.options(_root))..httpClientAdapter = refresh,
        logger: FakeLoggerService(),
      );
      await session.saveLogin(
        accessToken: 'a1',
        refreshToken: 'r1',
        mustChangePassword: false,
      );
      final adapter = _cancelling();
      final dio = Dio(DioFactory.options(_root))..httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(session: session, dio: dio));

      await expectLater(
        ApiClient(dio).get(ApiRoutes.checks),
        throwsA(isA<RequestCancelledException>()),
      );
      expect(adapter.requests, hasLength(1), reason: 'not sent again');
      expect(refresh.requests, isEmpty, reason: 'no renewal');
      expect(session.current, isA<SessionAuthenticated>());
    });
  });
}
