import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';

import '../../../fakes/postman_examples.dart';
import '../../../fakes/scripted_adapter.dart';

/// API contract tests: every answer is parsed from the backend's own
/// Postman examples (final.md Section 18.2).
void main() {
  late ScriptedAdapter adapter;
  late ApiClient api;
  late ScriptedAnswer next;

  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    final dio = Dio(
      DioFactory.options('https://api.example.test/v1/clients/x/'),
    )..httpClientAdapter = adapter;
    api = ApiClient(dio);
  });

  ScriptedAnswer example(int status, String request, String name) =>
      ScriptedAnswer(status, postmanExample(request: request, example: name));

  group('auth/login', () {
    test('trusted phone: logged_in with both passes', () async {
      next = example(200, '1. Log in', '200 Trusted phone: logged in');
      final dto = await DioAuthApiService(
        api,
      ).login(email: 'a@b.c', password: 'p', phoneId: 'id');
      expect(dto.status, 'logged_in');
      expect(dto.accessToken, isNotEmpty);
      expect(dto.refreshToken, isNotEmpty);
      expect(dto.mustChangePassword, isFalse);
      final sent = adapter.requests.single;
      expect(sent.path, 'auth/login');
      expect(sent.data, {'email': 'a@b.c', 'password': 'p', 'phone_id': 'id'});
      expect(sent.headers['Authorization'], isNull);
    });

    test('new phone: code_sent with challenge_id', () async {
      next = example(200, '1. Log in', '200 New phone: a code was emailed');
      final dto = await DioAuthApiService(
        api,
      ).login(email: 'a@b.c', password: 'p', phoneId: 'id');
      expect(dto.status, 'code_sent');
      expect(dto.challengeId, isNotEmpty);
    });

    test('wrong login: unauthenticated', () async {
      next = example(401, '1. Log in', '401 Email or password is incorrect');
      await expectLater(
        DioAuthApiService(api).login(email: 'a', password: 'p', phoneId: 'i'),
        throwsA(isA<UnauthenticatedException>()),
      );
    });
  });

  test('verify-phone: a new password must be set', () async {
    next = example(
      200,
      '2. Verify the phone with the emailed code',
      '200 Logged in, a new password must be set',
    );
    final dto = await DioAuthApiService(
      api,
    ).verifyPhone(challengeId: 'c', code: '123456', phoneId: 'id');
    expect(dto.status, 'logged_in');
    expect(dto.mustChangePassword, isTrue);
  });

  test('me/password: a new access pass', () async {
    next = example(
      200,
      'Change the password',
      '200 Changed: a new access pass',
    );
    final dto = await DioAuthApiService(
      api,
    ).changePassword(oldPassword: 'old', newPassword: 'abcd1234');
    expect(dto.accessToken, isNotEmpty);
    expect(dto.mustChangePassword, isFalse);
    expect(adapter.requests.single.data, {
      'old_password': 'old',
      'new_password': 'abcd1234',
    });
  });

  test('GET me: the profile', () async {
    next = example(200, 'Profile', '200 The profile');
    final dto = await DioProfileApiService(api).getMe();
    expect(dto.name, isNotEmpty);
    expect(dto.permissions, isNotEmpty);
    expect(dto.mustChangePassword, isFalse);
  });
}
