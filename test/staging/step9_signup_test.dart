import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 9 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): sign up, on the server's real answers replayed offline
/// (TC-STG-047 … -049).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  Future<FlowApp> requestWith(WidgetTester tester, String answer) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'GET roles/requestable': real('roles_requestable_200.json'),
        'POST auth/access': real(answer),
      },
    );
    await app.tapText('Sign up');
    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    await app.tap(find.byKey(const Key('access.submit')));
    return app;
  }

  testWidgets('TC-STG-047 the real 401 for a used code: the code step '
      'stays, with a new code to ask for', (tester) async {
    final app = await requestWith(tester, 'access_used_code_401.json');
    expect(
      find.text('The code is wrong or expired. Request a new code if needed.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('access.code')), findsOneWidget);
    expect(find.text('Send a new code'), findsOneWidget);
    expect(find.textContaining('Thanks for signing up.'), findsNothing);
    expect(app.backend.sent('POST', 'auth/access'), hasLength(1));
  });

  testWidgets('TC-STG-048 the real 404 "Role not found.": choose another '
      'role', (tester) async {
    await requestWith(tester, 'access_role_404.json');
    expect(
      find.text('This role is no longer available. Choose another role.'),
      findsOneWidget,
    );
    expect(find.textContaining('Thanks for signing up.'), findsNothing);
  });

  test('TC-STG-049 the real 400s for a name the server refuses', () {
    for (final fixture in [
      'access_name_over_400.json',
      'access_name_emoji_400.json',
    ]) {
      final answer = stagingAnswer(fixture);
      final error = ErrorMapper.fromResponse(
        statusCode: answer['status'] as int,
        body: answer['body'],
      );
      expect(error, isA<ValidationException>(), reason: fixture);
      expect(error.requestId, 'req-staging', reason: fixture);
    }
  });
}
