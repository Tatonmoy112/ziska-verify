import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/demo/password_later_demo.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/scripted_adapter.dart';

/// The mock build's demo of **Not now** (TC-AUTH-096): the backend's coming
/// answers played on top of today's.
void main() {
  late List<String> sent;
  late Map<String, dynamic> me;
  late Dio dio;

  /// Today's answers: a forced change, no `password_change_skippable`.
  setUp(() {
    sent = [];
    me = {
      'id': 'u1',
      'name': 'Asha Rao',
      'email': 'a@b.c',
      'role': 'Field inspector',
      'permissions': <String>[],
      'must_change_password': true,
    };
    final adapter = ScriptedAdapter((o) async {
      sent.add('${o.method} ${o.path}');
      return switch ('${o.method} ${o.path}') {
        'POST auth/login' || 'POST auth/verify-phone' => ScriptedAnswer(
          200,
          okBody({
            'status': 'logged_in',
            'access_token': 'a1',
            'refresh_token': 'r1',
            'must_change_password': true,
          }),
        ),
        'POST auth/refresh' => ScriptedAnswer(
          200,
          okBody({
            'status': 'logged_in',
            'access_token': 'a2',
            'refresh_token': 'r2',
            'must_change_password': true,
          }),
        ),
        'GET me' => ScriptedAnswer(200, okBody(Map.of(me))),
        'POST me/password' => ScriptedAnswer(
          200,
          okBody({'access_token': 'a3', 'must_change_password': false}),
        ),
        _ => ScriptedAnswer(200, okBody(<String, dynamic>{})),
      };
    });
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/'))
      ..httpClientAdapter = adapter
      ..interceptors.add(PasswordLaterDemo(FakeLoggerService()));
  });

  Future<Map<String, dynamic>> data(String method, String path) async {
    final response = await dio.request<Map<String, dynamic>>(
      path,
      options: Options(
        method: method,
        headers: {'Authorization': 'Bearer a1'},
      ),
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  test('a forced change at login may be skipped', () async {
    final login = await data('POST', 'auth/login');
    expect(login['must_change_password'], isTrue);
    expect(login['password_change_skippable'], isTrue);
    final code = await data('POST', 'auth/verify-phone');
    expect(code['password_change_skippable'], isTrue);
  });

  test(
    'GET me and a renewal offer Not now while the change is forced',
    () async {
      expect((await data('GET', 'me'))['password_change_skippable'], isTrue);
      expect(
        (await data('POST', 'auth/refresh'))['password_change_skippable'],
        isTrue,
      );
    },
  );

  test('Not now is answered without the network', () async {
    await data('POST', 'auth/login');
    final later = await data('POST', 'me/password/later');
    expect(later['access_token'], 'a1');
    expect(later['must_change_password'], isFalse);
    expect(later['password_change_pending'], isTrue);
    expect(sent, isNot(contains('POST me/password/later')));
  });

  test('after Not now: no forced change; the reminder is due', () async {
    await data('POST', 'auth/login');
    await data('POST', 'me/password/later');
    final profile = await data('GET', 'me');
    expect(profile['must_change_password'], isFalse);
    expect(profile['password_change_pending'], isTrue);
    expect(
      (await data('POST', 'auth/refresh'))['must_change_password'],
      isFalse,
    );
  });

  test('after a change: no reminder; the next login asks again', () async {
    await data('POST', 'auth/login');
    await data('POST', 'me/password/later');
    await data('POST', 'me/password');
    final profile = await data('GET', 'me');
    expect(profile['must_change_password'], isFalse);
    expect(profile['password_change_pending'], isFalse);

    final again = await data('POST', 'auth/login');
    expect(again['password_change_skippable'], isTrue);
    expect((await data('GET', 'me'))['must_change_password'], isTrue);
  });

  test('a password the official chose is left alone', () async {
    me['must_change_password'] = false;
    final profile = await data('GET', 'me');
    expect(profile.containsKey('password_change_skippable'), isFalse);
    expect(profile.containsKey('password_change_pending'), isFalse);
  });
}
