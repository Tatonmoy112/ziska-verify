import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/network/demo/postman_mock_routing.dart';

import '../../fakes/scripted_adapter.dart';

/// The mock build's routing for the Postman mock (TC-MIG-050): the right
/// example for shared routes, and the app's own session IDs echoed back.
void main() {
  const example = PostmanMockRouting.exampleSessionId;
  const mine = '11111111-1111-4111-8111-111111111111';
  late List<RequestOptions> sent;
  late Dio dio;

  setUp(() {
    sent = [];
    dio = Dio(BaseOptions(baseUrl: 'https://mock.example.test/'))
      ..httpClientAdapter = ScriptedAdapter((o) async {
        sent.add(o);
        return switch ('${o.method} ${o.path}') {
          'POST lookups' => ScriptedAnswer(
            200,
            okBody({
              'ref': 'MA-1',
              'result': 'warning',
              'session': {'id': example, 'scanned': 1},
            }),
          ),
          'GET lookups/sessions/$example' => ScriptedAnswer(
            200,
            okBody({'id': example, 'scanned': 41}),
          ),
          'POST incidents/1042/photos' => ScriptedAnswer(201, okBody({'n': 1})),
          'POST auth/verify-phone' => ScriptedAnswer(
            200,
            okBody({
              'status': 'logged_in',
              'access_token': 'eyJhbGciOiJFZERTQSIsImtpZCI6Im…',
              'refresh_token': 'rt_8Hq2…',
            }),
          ),
          _ => ScriptedAnswer(200, okBody(<String, dynamic>{})),
        };
      })
      ..interceptors.add(PostmanMockRouting());
  });

  String? asked() => sent.last.headers[PostmanMockRouting.header] as String?;

  test('a single check picks its example by the last digit', () async {
    for (final (value, name) in [
      ('1000001', '200 valid: genuine, first check'),
      ('1000002', '200 warning: checked before and expired'),
      ('1000003', '200 not_found'),
      ('1000004', '200 unassigned'),
      ('Q8F2KD91XA7M', '200 valid: genuine, first check'),
    ]) {
      await dio.post<Object?>(
        'lookups',
        data: {'way': 'serial', 'value': value},
      );
      expect(asked(), name, reason: value);
    }
  });

  test('a scan asks for the session example and gets its own session ID '
      'back', () async {
    final answer = await dio.post<Object?>(
      'lookups',
      data: {'way': 'qr', 'value': 'Q8F2KD91XA7M', 'session_id': mine},
    );
    expect(asked(), '200 first scan of an item: warning');
    final data = (answer.data! as Map)['data'] as Map;
    expect((data['session'] as Map)['id'], mine);

    await dio.post<Object?>(
      'lookups',
      data: {'way': 'qr', 'value': 'Q8F2KD91XA73', 'session_id': mine},
    );
    expect(asked(), '200 not_found');
  });

  test('a session path asks for the example ID; the answer has the real '
      'one', () async {
    final answer = await dio.get<Object?>('lookups/sessions/$mine');
    expect(sent.last.path, 'lookups/sessions/$example');
    expect(((answer.data! as Map)['data'] as Map)['id'], mine);

    await dio.post<Object?>('lookups/sessions/$mine/end');
    expect(sent.last.path, 'lookups/sessions/$example/end');
  });

  test('History: the first page and the later page by the cursor', () async {
    await dio.get<Object?>('checks', queryParameters: {'limit': 50});
    expect(asked(), '200 First page');
    await dio.get<Object?>(
      'checks',
      queryParameters: {'limit': 50, 'cursor': 'c1'},
    );
    expect(asked(), '200 A later page');
  });

  test('every fixed route names its success example', () async {
    await dio.get<Object?>('formats');
    expect(asked(), '200 The formats');
    await dio.get<Object?>('roles/requestable');
    expect(asked(), '200 The roles');
    await dio.post<Object?>('incidents', data: {'note': 'Torn seal'});
    expect(asked(), '201 Filed');
    await dio.post<Object?>('auth/login', data: {'email': 'a@b.c'});
    expect(asked(), '200 New phone: a code was emailed');
  });

  test(
    'the code 111111 logs in to a forced change; any other, normally',
    () async {
      await dio.post<Object?>('auth/verify-phone', data: {'code': '111111'});
      expect(asked(), '200 Logged in, a new password must be set');
      await dio.post<Object?>('auth/verify-phone', data: {'code': '123456'});
      expect(asked(), '200 Logged in, the phone is now trusted');
    },
  );

  test("a report's photos are numbered 1, 2, 3", () async {
    final numbers = <Object?>[];
    for (var k = 0; k < 3; k++) {
      final answer = await dio.post<Object?>(
        'incidents/1042/photos',
        data: 'x',
      );
      expect(asked(), '201 Uploaded as photo 1');
      numbers.add(((answer.data! as Map)['data'] as Map)['n']);
    }
    expect(numbers, [1, 2, 3]);
  });

  test('passes shortened with "…" become header-safe stand-ins, new each '
      'time', () async {
    final first = await dio.post<Object?>(
      'auth/verify-phone',
      data: {'code': '123456'},
    );
    final second = await dio.post<Object?>(
      'auth/verify-phone',
      data: {'code': '123456'},
    );
    final a = (first.data! as Map)['data'] as Map;
    final b = (second.data! as Map)['data'] as Map;
    expect(a['access_token'], 'mock-access-1');
    expect(a['refresh_token'], 'mock-refresh-2');
    expect(b['access_token'], isNot(a['access_token']));
    // A header can carry it now.
    await dio.get<Object?>(
      'me',
      options: Options(
        headers: {'Authorization': 'Bearer ${a['access_token']}'},
      ),
    );
    expect(sent.last.headers['Authorization'], 'Bearer mock-access-1');
  });

  test('a route the collection does not have goes as it is', () async {
    await dio.get<Object?>('somewhere/else');
    expect(sent.last.headers.containsKey(PostmanMockRouting.header), isFalse);
    expect(sent.last.path, 'somewhere/else');
  });

  test('the flag is refused outside the mock build', () {
    for (final flavor in ['staging', 'live']) {
      expect(
        () => AppConfig.fromValues(
          flavorName: flavor,
          baseUrl: 'https://api.example.test',
          clientSlug: 'x',
          officeEmail: '',
          officePhone: '',
          postmanMockRouting: true,
        ),
        throwsStateError,
      );
    }
  });
}
