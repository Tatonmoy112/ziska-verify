import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 2 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): login and staying logged in, on the server's real
/// answers replayed offline through the whole app (TC-STG-008 … -013).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  /// The server's own answers for every route the login touches.
  Map<String, Answer> server() => {
    'POST auth/login': real('login_code_sent_200.json'),
    'POST auth/verify-phone': real('verify_phone_logged_in_200.json'),
    'GET me': real('me_200.json'),
    'GET formats': real('formats_200.json'),
    'POST auth/refresh': real('refresh_200.json'),
    'POST auth/logout': real('logout_200.json'),
  };

  final historyTab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text('History'),
  );

  testWidgets('TC-STG-008 a new phone: login, the emailed code, then in, '
      'with both passes kept', (tester) async {
    final app = await startApp(tester, loggedIn: false, overrides: server());
    await logInToCode(app);
    expect(find.byKey(const Key('verify.code')), findsOneWidget);
    final login = app.backend.sent('POST', 'auth/login').single;
    expect((login.data as Map).keys, {'email', 'password', 'phone_id'});

    await app.enter(const Key('verify.code'), '123456');
    await app.tap(find.byKey(const Key('verify.submit')));
    final verify = app.backend.sent('POST', 'auth/verify-phone').single;
    expect(verify.data, {
      'challenge_id': 'challenge-staging',
      'code': '123456',
      'phone_id': (login.data as Map)['phone_id'],
    });
    expect(app.storage.values[SecureKeys.accessToken], 'access-staging');
    expect(app.storage.values[SecureKeys.refreshToken], 'refresh-staging');
    // GET me's real answer: the name on the Check tab.
    expect(find.text('Test Official'), findsOneWidget);
    expect(tab('Check'), findsOneWidget);
  });

  testWidgets('TC-STG-009 a trusted phone logs in without a code', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        ...server(),
        'POST auth/login': real('login_trusted_phone_200.json'),
      },
    );
    await logInToCode(app);
    expect(find.byKey(const Key('verify.code')), findsNothing);
    expect(app.backend.sent('POST', 'auth/verify-phone'), isEmpty);
    expect(find.text('Test Official'), findsOneWidget);
  });

  testWidgets('TC-STG-010 an expired pass is renewed with the real answer: '
      'both new passes stored, the request sent once more', (tester) async {
    var checks = 0;
    final app = await startApp(
      tester,
      overrides: {
        ...server(),
        'GET checks': (r) => ++checks == 1
            ? apiError(401, 'token_expired')
            : ok({
                'checks': <Object?>[],
                'totals': null,
                'next_cursor': null,
              }),
      },
    );
    await app.tap(historyTab);
    expect(app.backend.sent('POST', 'auth/refresh'), hasLength(1));
    expect(checks, 2);
    expect(app.storage.values[SecureKeys.accessToken], 'access-staging');
    expect(app.storage.values[SecureKeys.refreshToken], 'refresh-staging');
    final retried = app.backend.sent('GET', 'checks').last;
    expect(retried.headers['Authorization'], 'Bearer access-staging');
  });

  testWidgets('TC-STG-011 logout as the server accepts it: no body and no '
      'type; then Login, the phone ID kept', (tester) async {
    final app = await startApp(tester, overrides: server());
    final phoneId = app.storage.values[SecureKeys.phoneId];
    await app.tap(tab('Profile'));
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log out'),
      ),
    );
    final sent = app.backend.sent('POST', 'auth/logout').single;
    expect(sent.data, isNull);
    expect(
      sent.headers.keys.map((k) => k.toLowerCase()),
      isNot(contains('content-type')),
    );
    expect(find.text('Login to Track & Trace'), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
    expect(app.storage.values[SecureKeys.phoneId], phoneId);
  });

  test('TC-STG-011 the server refuses a logout sent as an empty JSON body '
      '(why the app sends none)', () {
    final answer = stagingAnswer('logout_empty_json_body_400.json');
    final error = ErrorMapper.fromResponse(
      statusCode: answer['status'] as int,
      body: answer['body'],
    );
    expect(error, isA<ValidationException>());
    expect(error.code, 'validation_failed');
  });

  testWidgets('TC-STG-012 a used refresh pass is refused: Login, the phone '
      'ID kept', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        ...server(),
        'GET checks': always(apiError(401, 'token_expired')),
        'POST auth/refresh': real('refresh_used_pass_401.json'),
      },
    );
    final phoneId = app.storage.values[SecureKeys.phoneId];
    await app.tap(historyTab);
    expect(find.text('Login to Track & Trace'), findsOneWidget);
    expect(app.storage.values[SecureKeys.refreshToken], isNull);
    expect(app.storage.values[SecureKeys.phoneId], phoneId);
  });

  testWidgets('TC-STG-013 a pass ended elsewhere (the real 401 after a '
      'logout): Login', (tester) async {
    final app = await startApp(
      tester,
      overrides: {...server(), 'GET checks': real('me_after_logout_401.json')},
    );
    await app.tap(historyTab);
    expect(find.text('Login to Track & Trace'), findsOneWidget);
  });
}
