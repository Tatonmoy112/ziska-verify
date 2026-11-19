import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: the edge, worst, and failure cases of logging in
/// (docs/test-cases/01-auth.md, TC-AUTH-027 and later).
void main() {
  const loginTitle = 'Login to Track & Trace';
  const loginFailed = 'Email or password is incorrect.';
  const invalidEmail = 'Enter a valid email address';
  const noConnection = 'No connection. Check the internet and try again.';
  const ruleBroken = 'The password does not meet the rules below.';
  const rules = ['8 characters or more', 'a letter', 'a number'];

  Map<String, dynamic> body(FlowApp app, String method, String path) =>
      app.backend.sent(method, path).last.data as Map<String, dynamic>;

  Future<void> go(WidgetTester tester, String location) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);
    await tester.pumpAndSettle();
  }

  /// Taps [finder] twice before the (slow) answer arrives.
  Future<void> doubleTap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Map<String, dynamic> forced(Map<String, dynamic> profile) => {
    ...profile,
    'must_change_password': true,
  };

  group('Login input', () {
    testWidgets('TC-AUTH-027 spaces around the email are not sent', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), '  official@example.com \n');
      await app.enter(const Key('login.password'), 'secret-pass');
      await app.tap(find.byKey(const Key('login.submit')));

      expect(body(app, 'POST', 'auth/login')['email'], 'official@example.com');
    });

    for (final (id, email) in [
      ('029', 'a@b'),
      ('029', 'a@@b.com'),
      ('029', '@example.com'),
      ('029', 'official@'),
      ('030', '${'a' * 308}@example.com'),
    ]) {
      testWidgets('TC-AUTH-$id "${email.length > 30 ? '${email.length} '
                    'characters' : email}" is refused, or answered like any '
          'unknown address', (tester) async {
        final app = await startApp(
          tester,
          loggedIn: false,
          overrides: {
            'POST auth/login': always(apiError(401, 'unauthenticated')),
          },
        );
        await app.enter(const Key('login.email'), email);
        await app.enter(const Key('login.password'), 'secret-pass');
        await app.tap(find.byKey(const Key('login.submit')));

        final sent = app.backend.sent('POST', 'auth/login').isNotEmpty;
        expect(
          find.text(sent ? loginFailed : invalidEmail),
          findsOneWidget,
        );
        expect(find.text(loginTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('TC-AUTH-031 the login password is not checked against '
        'the rule', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'abc');
      for (final rule in rules) {
        expect(find.text(rule), findsNothing);
      }
      await app.tap(find.byKey(const Key('login.submit')));

      expect(body(app, 'POST', 'auth/login')['password'], 'abc');
    });

    testWidgets('TC-AUTH-032 the password field holds at most 128 '
        'characters', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'p' * 129);
      expect(app.fieldText(const Key('login.password')), hasLength(128));
      await app.tap(find.byKey(const Key('login.submit')));

      expect(body(app, 'POST', 'auth/login')['password'], hasLength(128));
    });

    testWidgets('TC-AUTH-033 the password is hidden until shown', (
      tester,
    ) async {
      await startApp(tester, loggedIn: false);
      bool hidden() => tester
          .widget<TextField>(find.byKey(const Key('login.password')))
          .obscureText;

      expect(hidden(), isTrue);
      await tester.tap(find.text('Show password'));
      await tester.pumpAndSettle();
      expect(hidden(), isFalse);
      await tester.tap(find.text('Hide password'));
      await tester.pumpAndSettle();
      expect(hidden(), isTrue);
    });
  });

  group('Login request', () {
    testWidgets('TC-AUTH-034 one press, one login', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': slow(
            (_) => FakeBackend.example(
              200,
              '1. Log in',
              '200 New phone: a code was emailed',
            ),
          ),
        },
      );
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'secret-pass');
      await doubleTap(tester, find.byKey(const Key('login.submit')));

      expect(app.backend.sent('POST', 'auth/login'), hasLength(1));
    });

    testWidgets('TC-AUTH-035 the status decides, never the message', (
      tester,
    ) async {
      var app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      expect(find.text('Check your email'), findsOneWidget);

      app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/login': always(loggedIn())},
      );
      await logInToCode(app);
      expect(find.text('Welcome back,'), findsOneWidget);
    });

    testWidgets('TC-AUTH-036 an unknown status does not log in', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(ok({'status': 'something_new'})),
        },
      );
      await logInToCode(app);

      expect(find.text(loginTitle), findsOneWidget);
      expect(app.storage.values[SecureKeys.refreshToken], isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-AUTH-039 a rate-limited login counts down and sends '
        'nothing until 0', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(
            apiError(429, 'rate_limited', retryAfter: 30),
          ),
        },
      );
      await logInToCode(app);
      expect(
        find.text('Too many attempts. Try again in 30 s.'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Too many attempts. Try again in 29 s.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pump();
      expect(app.backend.sent('POST', 'auth/login'), hasLength(1));

      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      await app.tap(find.byKey(const Key('login.submit')));
      expect(app.backend.sent('POST', 'auth/login'), hasLength(2));
    });

    testWidgets('TC-AUTH-040 login offline', (tester) async {
      await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/login': offline()},
      );
      // The harness app is not reachable from here; log in by hand.
      await tester.enterText(
        find.byKey(const Key('login.email')),
        'official@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login.password')),
        'secret-pass',
      );
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pumpAndSettle();

      expect(find.text(noConnection), findsOneWidget);
      expect(find.text(loginTitle), findsOneWidget);
    });

    testWidgets('TC-AUTH-041 login answered 503, then 500', (tester) async {
      var app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(apiError(503, 'service_unavailable')),
        },
      );
      await logInToCode(app);
      expect(
        find.text('The service is busy. Try again shortly.'),
        findsOneWidget,
      );

      app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(
            apiError(500, 'internal_error', requestId: 'req-500'),
          ),
        },
      );
      await logInToCode(app);
      expect(find.text('Something went wrong. Try again.'), findsOneWidget);
      expect(find.textContaining('req-500'), findsOneWidget);
    });

    testWidgets('TC-AUTH-042 client switched off', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/login': always(apiError(404, 'not_found'))},
      );
      await logInToCode(app);
      expect(find.text('Not available.'), findsOneWidget);
    });

    testWidgets('TC-AUTH-044 the code screen does not survive a restart', (
      tester,
    ) async {
      final first = await startApp(tester, loggedIn: false);
      await logInToCode(first);
      expect(find.text('Check your email'), findsOneWidget);

      final second = await startApp(tester, storage: first.storage);
      expect(find.text(loginTitle), findsOneWidget);
      await logInToCode(second);
      expect(find.text('Check your email'), findsOneWidget);
      expect(second.backend.sent('POST', 'auth/login'), hasLength(1));
    });
  });

  group('Code screen', () {
    testWidgets('TC-AUTH-045 a pasted code fills the field', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '123456');
      expect(app.enabled(const Key('verify.submit')), isTrue);
    });

    testWidgets('TC-AUTH-046 only digits enter the code field', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      for (final pasted in ['123 456', 'Code: 123456']) {
        await app.enter(const Key('verify.code'), pasted);
        expect(app.fieldText(const Key('verify.code')), '123456');
        expect(app.enabled(const Key('verify.submit')), isTrue);
      }
    });

    testWidgets('TC-AUTH-047 a code with leading zeros keeps them', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '000123');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(body(app, 'POST', 'auth/verify-phone')['code'], '000123');
    });

    testWidgets('TC-AUTH-048 one press, one code check', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/verify-phone': slow(always(loggedIn()))},
      );
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '123456');
      await doubleTap(tester, find.byKey(const Key('verify.submit')));
      expect(app.backend.sent('POST', 'auth/verify-phone'), hasLength(1));
    });

    testWidgets('TC-AUTH-053 code check offline', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/verify-phone': offline()},
      );
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '123456');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text(noConnection), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('TC-AUTH-054 code check rate limited', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': always(
            apiError(429, 'rate_limited', retryAfter: 20),
          ),
        },
      );
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '123456');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(
        find.text('Too many attempts. Try again in 20 s.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Too many attempts. Try again in 19 s.'),
        findsOneWidget,
      );
    });

    testWidgets('TC-AUTH-055 a forced change right after the code', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': always(loggedIn(mustChange: true)),
        },
      );
      app.backend.profile = forced(Roles.fieldInspector);
      await logInWithCode(app);
      expect(find.text('Set a new password'), findsOneWidget);
      expect(
        find.text(
          'Your password was set by someone else. Choose your own password '
          'to continue.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-AUTH-056 resend sends a new code for the same '
        'challenge', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await app.tapText('Send the code again');

      final challenge =
          (app.backend.sent('POST', 'auth/resend-code').single.data
              as Map<String, dynamic>)['challenge_id'];
      expect(challenge, isNotNull);
      expect(find.text('A new code was sent.'), findsOneWidget);
      expect(find.textContaining('Send again in'), findsOneWidget);
    });

    testWidgets('TC-AUTH-057 resend offline', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/resend-code': offline()},
      );
      await logInToCode(app);
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await app.tapText('Send the code again');
      expect(find.text(noConnection), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);
    });
  });

  group('Forced and voluntary change', () {
    testWidgets('TC-AUTH-060 log out from the forced change', (tester) async {
      final app = await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
      );
      final phoneId = app.storage.values[SecureKeys.phoneId];
      expect(find.text('Set a new password'), findsOneWidget);
      await app.tapText('Log out');

      expect(find.text(loginTitle), findsOneWidget);
      expect(app.storage.values[SecureKeys.accessToken], isNull);
      expect(app.storage.values[SecureKeys.refreshToken], isNull);
      expect(app.storage.values[SecureKeys.phoneId], phoneId);
    });

    testWidgets('TC-AUTH-061 a restart keeps the forced change', (
      tester,
    ) async {
      final first = await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
      );
      expect(find.text('Set a new password'), findsOneWidget);

      await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
        storage: first.storage,
      );
      expect(find.text('Set a new password'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Set a new password'), findsOneWidget);
    });

    testWidgets('TC-AUTH-062 a forced change in the middle of a session', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        overrides: {
          'GET checks': always(apiError(403, 'password_change_required')),
        },
      );
      app.backend.profile = forced(Roles.fieldInspector);
      await app.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('History'),
        ),
      );
      expect(find.text('Set a new password'), findsOneWidget);
    });

    Future<void> fillChange(FlowApp app, {String next = 'abcd1234'}) async {
      await app.enter(const Key('change.old'), 'first-pass');
      await app.enter(const Key('change.new'), next);
      await app.enter(const Key('change.repeat'), next);
    }

    testWidgets('TC-AUTH-064 a password change offline', (tester) async {
      final app = await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
        overrides: {'POST me/password': offline()},
      );
      await fillChange(app);
      await app.tap(find.byKey(const Key('change.submit')));
      expect(find.text(noConnection), findsOneWidget);
      expect(find.text('Set a new password'), findsOneWidget);
      expect(app.storage.values[SecureKeys.refreshToken], isNotNull);
    });

    testWidgets('TC-AUTH-065 the server refuses the new password', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
        overrides: {
          'POST me/password': always(
            apiError(403, 'policy_denied', requestId: 'req-policy'),
          ),
        },
      );
      await fillChange(app);
      await app.tap(find.byKey(const Key('change.submit')));
      expect(find.text(ruleBroken), findsOneWidget);
      for (final rule in rules) {
        expect(find.text(rule), findsOneWidget, reason: rule);
      }
      expect(find.textContaining('req-policy'), findsOneWidget);
    });

    testWidgets('TC-AUTH-066 the new access pass is used; the refresh '
        'pass stays', (tester) async {
      final app = await startApp(
        tester,
        overrides: {
          'POST me/password': always(
            ok({
              'access_token': 'access-changed',
              'access_expires_in': 900,
              'must_change_password': false,
            }),
          ),
        },
      );
      await app.tapText('Profile');
      await app.tapText('Change password');
      await fillChange(app);
      await app.tap(find.byKey(const Key('change.submit')));
      await app.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('History'),
        ),
      );

      expect(
        app.backend.sent('GET', 'checks').last.headers['Authorization'],
        'Bearer access-changed',
      );
      expect(app.storage.values[SecureKeys.refreshToken], 'refresh-1');
    });

    testWidgets('TC-AUTH-067 one press, one password change', (tester) async {
      final app = await startApp(
        tester,
        overrides: {
          'POST me/password': slow(
            (_) => FakeBackend.example(
              200,
              'Change the password',
              '200 Changed: a new access pass',
            ),
          ),
        },
      );
      await app.tapText('Profile');
      await app.tapText('Change password');
      await fillChange(app);
      await doubleTap(tester, find.byKey(const Key('change.submit')));

      expect(app.backend.sent('POST', 'me/password'), hasLength(1));
      expect(find.text('Your password was changed.'), findsOneWidget);
      expect(find.text('The current password is incorrect.'), findsNothing);
    });

    testWidgets('TC-AUTH-068 the rules show before typing on every '
        'new-password screen', (tester) async {
      void expectRules(Key submit) {
        for (final rule in rules) {
          expect(find.text(rule), findsOneWidget, reason: rule);
        }
        expect(find.byIcon(Icons.check_circle), findsNothing);
      }

      // Forced change.
      final app = await startApp(tester, profile: forced(Roles.fieldInspector));
      expectRules(const Key('change.submit'));
      expect(app.enabled(const Key('change.submit')), isFalse);

      // Voluntary change.
      final second = await startApp(tester);
      await second.tapText('Profile');
      await second.tapText('Change password');
      expectRules(const Key('change.submit'));
      expect(second.enabled(const Key('change.submit')), isFalse);

      // Reset.
      final third = await startApp(tester, loggedIn: false);
      await third.tapText('Forgot password?');
      await third.enter(const Key('forgot.email'), 'official@example.com');
      await third.tap(find.byKey(const Key('forgot.submit')));
      expectRules(const Key('reset.submit'));
      expect(third.enabled(const Key('reset.submit')), isFalse);
    });

    testWidgets('TC-AUTH-069 7 characters keep Save disabled; 8 enable it', (
      tester,
    ) async {
      final app = await startApp(tester, profile: forced(Roles.fieldInspector));
      await fillChange(app, next: 'abcd123');
      expect(app.enabled(const Key('change.submit')), isFalse);
      await fillChange(app);
      expect(app.enabled(const Key('change.submit')), isTrue);
    });

    testWidgets('TC-AUTH-072 a pasted control character is never sent', (
      tester,
    ) async {
      final app = await startApp(tester, profile: forced(Roles.fieldInspector));
      // A tab stays in the field and the rule refuses it.
      await fillChange(app, next: 'abcd\t1234');
      expect(app.enabled(const Key('change.submit')), isFalse);
      await tester.tap(find.byKey(const Key('change.submit')));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'me/password'), isEmpty);

      // A line break never enters a one-line field (Flutter removes it from
      // every one-line field), so it is never sent either.
      await fillChange(app, next: 'abcd\n1234');
      expect(app.fieldText(const Key('change.new')), isNot(contains('\n')));
    });
  });

  group('Forgotten password', () {
    Future<void> openForgot(FlowApp app) => app.tapText('Forgot password?');

    testWidgets('TC-AUTH-075 an address without @ is not sent', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await openForgot(app);
      await app.enter(const Key('forgot.email'), 'official.example.com');
      await tester.tap(find.byKey(const Key('forgot.submit')));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'auth/password/forgot'), isEmpty);
    });

    testWidgets('TC-AUTH-076 forgot password offline', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/password/forgot': offline()},
      );
      await openForgot(app);
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      expect(find.text(noConnection), findsOneWidget);
      expect(find.byKey(const Key('reset.code')), findsNothing);
    });

    testWidgets('TC-AUTH-077 forgot password rate limited', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/password/forgot': always(
            apiError(429, 'rate_limited', retryAfter: 60),
          ),
        },
      );
      await openForgot(app);
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      expect(
        find.text('Too many attempts. Try again in 60 s.'),
        findsOneWidget,
      );
    });

    Future<void> toReset(FlowApp app) async {
      await openForgot(app);
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      await app.enter(const Key('reset.code'), '123456');
      await app.enter(const Key('reset.new'), 'abcd1234');
      await app.enter(const Key('reset.repeat'), 'abcd1234');
      await app.tap(find.byKey(const Key('reset.submit')));
    }

    testWidgets('TC-AUTH-078 a wrong, expired, or used reset code', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/password/reset': always(apiError(401, 'unauthenticated')),
        },
      );
      await toReset(app);
      expect(
        find.text('The code is wrong or has expired. Ask for a new code.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('reset.code')), findsOneWidget);
    });

    testWidgets('TC-AUTH-079 the reset password refused by the server', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/password/reset': always(apiError(403, 'policy_denied')),
        },
      );
      await toReset(app);
      expect(find.text(ruleBroken), findsOneWidget);
    });

    testWidgets('TC-AUTH-081 the reset screen without its email goes back '
        'to Forgot password', (tester) async {
      await startApp(tester, loggedIn: false);
      await go(tester, '/forgot-password/reset');
      expect(find.byKey(const Key('forgot.email')), findsOneWidget);
      expect(find.byKey(const Key('reset.code')), findsNothing);
    });
  });
}
