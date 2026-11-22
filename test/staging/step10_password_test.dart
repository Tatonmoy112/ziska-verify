import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 10 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): changing and resetting a password, on the server's real
/// answers replayed offline (TC-STG-051 … -053).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  const ruleBroken = 'The password does not meet the rules below.';

  testWidgets('TC-STG-051 the real 401 for a wrong current password: '
      'said so, still logged in', (tester) async {
    final app = await startApp(
      tester,
      profile: {...Roles.supervisor, 'must_change_password': true},
      overrides: {'POST me/password': real('password_wrong_old_401.json')},
    );
    await app.enter(const Key('change.old'), 'not-the-password-1');
    await app.enter(const Key('change.new'), 'abcd1234');
    await app.enter(const Key('change.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('change.submit')));
    expect(find.text('The current password is incorrect.'), findsOneWidget);
    expect(find.textContaining('req-staging'), findsOneWidget);
    expect(app.storage.values[SecureKeys.refreshToken], isNotNull);
    expect(app.storage.values[SecureKeys.accessToken], isNotNull);
  });

  Future<FlowApp> reset(WidgetTester tester, String answer) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/password/forgot': real('password_forgot_200.json'),
        'POST auth/password/reset': real(answer),
      },
    );
    await app.tapText('Forgot password?');
    await app.enter(const Key('forgot.email'), 'official@example.com');
    await app.tap(find.byKey(const Key('forgot.submit')));
    await app.enter(const Key('reset.code'), '123456');
    await app.enter(const Key('reset.new'), 'abcd1234');
    await app.enter(const Key('reset.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('reset.submit')));
    return app;
  }

  testWidgets('TC-STG-052 the real 200 of forgot, then the real 401 of '
      'reset: the code step stays', (tester) async {
    final app = await reset(tester, 'password_reset_wrong_code_401.json');
    expect(app.backend.sent('POST', 'auth/password/forgot'), hasLength(1));
    expect(
      find.text('The code is wrong or has expired. Ask for a new code.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset.code')), findsOneWidget);
  });

  testWidgets('TC-STG-053 the real 403 of reset shows the rules', (
    tester,
  ) async {
    final app = await reset(tester, 'password_reset_weak_403.json');
    expect(find.text(ruleBroken), findsOneWidget);
    expect(find.byKey(const Key('reset.code')), findsOneWidget);
    expect(app.backend.sent('POST', 'auth/password/reset'), hasLength(1));
  });
}
