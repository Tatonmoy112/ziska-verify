import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/dio_session_service.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_secure_storage_service.dart';
import '../../fakes/scripted_adapter.dart';

const _root = 'https://api.example.test/v1/clients/demo-pharma/';

/// Reads each request's body as a real connection does, so a body that can
/// be read only once fails the second time, as on a phone.
class _ReadingAdapter implements HttpClientAdapter {
  _ReadingAdapter(this.answer);

  final ScriptedAnswer Function(int call) answer;
  final bodies = <List<int>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = <int>[];
    await requestStream?.forEach(body.addAll);
    bodies.add(body);
    final a = answer(bodies.length);
    return ResponseBody.fromString(
      jsonEncode(a.body),
      a.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// TC-REP-066 (UI audit 2026-11-22, 8.2): the access pass lasts 15 minutes, so
/// the first photo after a quiet spell meets `401 token_expired`. The app
/// renews the pass and sends the same photo again; its bytes go again whole.
/// (The audit thought the body could be read only once; `Stream.fromIterable`
/// gives its items again to each reader, so it already works. This test keeps
/// it so if the body ever changes.)
void main() {
  test('TC-REP-066 a photo answered token_expired is sent again whole '
      'after the renewal', () async {
    final photo = Uint8List.fromList(List.generate(3000, (i) => i % 251));
    final api = _ReadingAdapter(
      (call) => call == 1
          ? ScriptedAnswer(401, errorBody('token_expired'))
          : ScriptedAnswer(201, okBody({'n': 1})),
    );
    final session = DioSessionService(
      storage: FakeSecureStorageService(),
      refreshDio: Dio(DioFactory.options(_root))
        ..httpClientAdapter = ScriptedAdapter(
          (_) async => ScriptedAnswer(
            200,
            okBody({
              'status': 'logged_in',
              'access_token': 'a2',
              'refresh_token': 'r2',
              'must_change_password': false,
            }),
          ),
        ),
      logger: FakeLoggerService(),
    );
    addTearDown(session.dispose);
    await session.saveLogin(
      accessToken: 'a1',
      refreshToken: 'r1',
      mustChangePassword: false,
    );
    final dio = Dio(DioFactory.options(_root))..httpClientAdapter = api;
    dio.interceptors.add(AuthInterceptor(session: session, dio: dio));

    final answer = await ApiClient(dio).postBytes(
      ApiRoutes.reportPhotos(1042),
      photo,
      contentType: 'image/jpeg',
    );

    expect((answer! as Map)['n'], 1);
    expect(api.bodies, hasLength(2));
    expect(api.bodies.last, photo, reason: 'the same bytes, sent again');
  });
}
