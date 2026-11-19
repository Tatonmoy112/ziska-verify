import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/fake_secure_storage_service.dart';
import 'harness.dart';

/// Secure storage that cannot be read (a broken keystore at start).
class _UnreadableStorage extends FakeSecureStorageService {
  @override
  Future<String?> read(String key) => Future.error(Exception('keystore'));
}

/// Worst cases of login and authentication through the screens:
/// TC-AUTH-097 … -100 and TC-SESS-034 (the app starts).
void main() {
  const loginTitle = 'Login to Track & Trace';

  group('TC-AUTH-097 an answer of the wrong shape is an error', () {
    for (final (name, data) in [
      (
        'a pass that is not text',
        <String, dynamic>{
          'status': 'logged_in',
          'access_token': 123,
          'refresh_token': 'r',
          'must_change_password': false,
        },
      ),
      (
        'a flag that is not true or false',
        <String, dynamic>{
          'status': 'logged_in',
          'access_token': 'a',
          'refresh_token': 'r',
          'must_change_password': 'true',
        },
      ),
      ('no status', <String, dynamic>{'access_token': 'a'}),
    ]) {
      testWidgets('login: $name', (tester) async {
        final app = await startApp(
          tester,
          loggedIn: false,
          overrides: {'POST auth/login': always(ok(data))},
        );
        await logInToCode(app);
        // The spinner stops and the error shows with its reference.
        expect(find.text(loginTitle), findsOneWidget);
        // The general error: a success answer carries no reference.
        expect(find.text('Something went wrong. Try again.'), findsOneWidget);
        expect(app.enabled(const Key('login.submit')), isTrue);
        expect(app.storage.values[SecureKeys.accessToken], isNull);
      });
    }

    testWidgets('the code: a pass that is not text', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': always(
            ok({
              'status': 'logged_in',
              'access_token': 7,
              'refresh_token': 'r',
              'must_change_password': false,
            }),
          ),
        },
      );
      await logInWithCode(app);
      // The general error: a success answer carries no reference.
      expect(find.text('Something went wrong. Try again.'), findsOneWidget);
      expect(app.enabled(const Key('verify.submit')), isTrue);
    });
  });

  testWidgets('TC-SESS-034 secure storage that cannot be read: the app '
      'still opens, on Login', (tester) async {
    await startApp(tester, loggedIn: false, storage: _UnreadableStorage());
    expect(find.text(loginTitle), findsOneWidget);
  });

  testWidgets('TC-AUTH-098 Back to login while the code is checked: the late '
      'answer does not log in', (tester) async {
    final gate = Completer<void>();
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/verify-phone': (r) async {
          await gate.future;
          return loggedIn();
        },
      },
    );
    await logInToCode(app);
    await app.enter(const Key('verify.code'), '123456');
    await tester.tap(find.byKey(const Key('verify.submit')));
    await tester.pump();
    // The check is still running (its spinner never settles): tap and step
    // through the frames by hand.
    await tester.tap(find.text('Back to login'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text(loginTitle), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text(loginTitle), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
  });

  group('the 6-digit code', () {
    Future<FlowApp> onCode(WidgetTester tester) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      return app;
    }

    String sentCode(FlowApp app) =>
        (app.backend.sent('POST', 'auth/verify-phone').single.data
                as Map<String, dynamic>)['code']
            as String;

    testWidgets('TC-AUTH-099 Bangla digits are read as 0–9', (tester) async {
      final app = await onCode(tester);
      await app.enter(const Key('verify.code'), '১২৩৪৫৬');
      expect(app.fieldText(const Key('verify.code')), '123456');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(sentCode(app), '123456');
    });

    testWidgets('TC-AUTH-099 Arabic-Indic digits are read as 0–9', (
      tester,
    ) async {
      final app = await onCode(tester);
      await app.enter(const Key('verify.code'), '١٢٣٤٥٦');
      expect(app.fieldText(const Key('verify.code')), '123456');
    });

    testWidgets('TC-AUTH-100 a pasted message: its 6-digit group is used', (
      tester,
    ) async {
      final app = await onCode(tester);
      await app.enter(const Key('verify.code'), 'Your code for 2026: 123456');
      expect(app.fieldText(const Key('verify.code')), '123456');
    });

    testWidgets('TC-AUTH-100 two 6-digit groups: the first six digits, as '
        'before', (tester) async {
      final app = await onCode(tester);
      await app.enter(const Key('verify.code'), '111111 or 222222');
      expect(app.fieldText(const Key('verify.code')), '111111');
    });

    testWidgets('TC-AUTH-099 the reset code reads Bangla digits too', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      await app.enter(const Key('reset.code'), '১২৩৪৫৬');
      expect(app.fieldText(const Key('reset.code')), '123456');
    });
  });
}
