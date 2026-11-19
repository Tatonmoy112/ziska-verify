import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import 'harness.dart';

/// Flow tests: AUTH and SESS (docs/test-cases/01-auth.md, 02-session.md).
void main() {
  bool enabled(WidgetTester tester, Key key) =>
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(key),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed !=
      null;

  group('AUTH', () {
    testWidgets('TC-AUTH-002 an empty password is not sent', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('login.submit')));

      expect(find.text('Required'), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/login'), isEmpty);
    });

    testWidgets('TC-AUTH-003 a new phone goes to the code screen', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'secret-pass');
      await app.tap(find.byKey(const Key('login.submit')));

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('official@example.com'), findsOneWidget);
      final body =
          app.backend.sent('POST', 'auth/login').single.data
              as Map<String, dynamic>;
      expect(body['email'], 'official@example.com');
      expect(body['phone_id'], hasLength(43));
    });

    testWidgets('TC-AUTH-004 the code field takes 6 digits only', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'secret-pass');
      await app.tap(find.byKey(const Key('login.submit')));

      await app.enter(const Key('verify.code'), 'abc');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('verify.code')))
            .controller!
            .text,
        isEmpty,
      );
      await app.enter(const Key('verify.code'), '12345');
      expect(enabled(tester, const Key('verify.submit')), isFalse);
      await app.enter(const Key('verify.code'), '123456');
      expect(enabled(tester, const Key('verify.submit')), isTrue);
    });

    testWidgets('TC-AUTH-005 the right code logs in to the Verify tab', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await logInWithCode(app);

      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('Asha Rao'), findsOneWidget);
      expect(app.storage.values[SecureKeys.refreshToken], isNotNull);
    });

    testWidgets('TC-AUTH-009 back to login from the code screen', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'secret-pass');
      await app.tap(find.byKey(const Key('login.submit')));

      await app.tapText('Back to login');
      expect(find.text('Login to Track & Trace'), findsOneWidget);

      // Android back does the same.
      await app.tap(find.byKey(const Key('login.submit')));
      expect(find.text('Check your email'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Login to Track & Trace'), findsOneWidget);
    });

    testWidgets('TC-AUTH-014 a forced password change is the only screen, '
        'then Home', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': (_) => FakeBackend.example(
            200,
            '2. Verify the phone with the emailed code',
            '200 Logged in, a new password must be set',
          ),
        },
      );
      await logInWithCode(app);
      expect(find.text('Set a new password'), findsOneWidget);

      // Back does not leave it.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Set a new password'), findsOneWidget);

      await app.enter(const Key('change.old'), 'first-pass');
      await app.enter(const Key('change.new'), 'abcd1234');
      await app.enter(const Key('change.repeat'), 'abcd1234');
      await app.tap(find.byKey(const Key('change.submit')));

      expect(find.text('Welcome back,'), findsOneWidget);
      expect(app.backend.sent('POST', 'me/password').single.data, {
        'old_password': 'first-pass',
        'new_password': 'abcd1234',
      });
    });

    testWidgets('TC-AUTH-018 the repeated password must match', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': (_) => FakeBackend.example(
            200,
            '2. Verify the phone with the emailed code',
            '200 Logged in, a new password must be set',
          ),
        },
      );
      await logInWithCode(app);
      await app.enter(const Key('change.old'), 'first-pass');
      await app.enter(const Key('change.new'), 'abcd1234');
      await app.enter(const Key('change.repeat'), 'abcd1235');

      expect(find.text('The passwords do not match'), findsOneWidget);
      expect(enabled(tester, const Key('change.submit')), isFalse);
    });

    testWidgets('TC-AUTH-020 forgot password always confirms; '
        'TC-AUTH-021 reset returns to Login', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));

      expect(
        find.text('If the address has an account, a code was sent.'),
        findsOneWidget,
      );
      expect(find.text('Reset password'), findsWidgets);

      await app.enter(const Key('reset.code'), '123456');
      await app.enter(const Key('reset.new'), 'abcd1234');
      await app.enter(const Key('reset.repeat'), 'abcd1234');
      await app.tap(find.byKey(const Key('reset.submit')));

      expect(
        find.text(
          'Password changed. Log in with your new password; every phone needs '
          'the emailed code at its next login.',
        ),
        findsOneWidget,
      );
      expect(find.text('Login to Track & Trace'), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/password/reset').single.data, {
        'email': 'official@example.com',
        'code': '123456',
        'new_password': 'abcd1234',
      });
    });
  });

  group('SESS', () {
    testWidgets('TC-SESS-002 the session survives a restart, with the same '
        'phone ID', (tester) async {
      final first = await startApp(tester, loggedIn: false);
      await logInWithCode(first);
      final phoneId = first.storage.values[SecureKeys.phoneId];

      final second = await startApp(tester, storage: first.storage);
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(second.storage.values[SecureKeys.phoneId], phoneId);
      expect(second.backend.sent('POST', 'auth/login'), isEmpty);
    });

    testWidgets('TC-SESS-005 logout keeps the phone ID', (tester) async {
      final app = await startApp(tester);
      final phoneId = app.storage.values[SecureKeys.phoneId];
      await app.tapText('Profile');
      await app.tap(find.byKey(const Key('profile.logout')));
      await app.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log out'),
        ),
      );

      expect(find.text('Login to Track & Trace'), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/logout'), hasLength(1));
      expect(app.storage.values[SecureKeys.accessToken], isNull);
      expect(app.storage.values[SecureKeys.refreshToken], isNull);
      expect(app.storage.values[SecureKeys.phoneId], phoneId);
    });

    // TC-SESS-044 (data-flow audit E18): sent bare, as in the Postman
    // collection; the button spins until the login has ended.
    testWidgets('TC-SESS-044 logout is sent with no body type, and spins', (
      tester,
    ) async {
      final answer = Completer<void>();
      final app = await startApp(
        tester,
        overrides: {
          'POST auth/logout': (_) async {
            await answer.future;
            return ok(null);
          },
        },
      );
      await app.tapText('Profile');
      await app.tap(find.byKey(const Key('profile.logout')));
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log out'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.descendant(
          of: find.byKey(const Key('profile.logout')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      final sent = app.backend.sent('POST', 'auth/logout').single;
      expect(sent.data, isNull);
      expect(
        sent.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('content-type')),
      );
      answer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Login to Track & Trace'), findsOneWidget);
    });

    testWidgets('TC-SESS-006 logout can be cancelled', (tester) async {
      final app = await startApp(tester);
      await app.tapText('Profile');
      await app.tap(find.byKey(const Key('profile.logout')));
      await app.tapText('Cancel');

      expect(find.byKey(const Key('profile.logout')), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/logout'), isEmpty);
    });
  });

  test('the fake backend answers like the Postman mock', () async {
    final backend = FakeBackend(profile: const {});
    final answer = await backend.answer(
      RequestOptions(path: 'auth/login', method: 'POST'),
    );
    expect(answer.status, 200);
    expect((answer.body['data']! as Map)['status'], 'code_sent');
  });
}
