import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/fake_secure_storage_service.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Edge and worst cases of login and authentication through the screens
/// (docs/test-cases/01-auth.md, 02-session.md): answers, input, taps, and
/// sequences the fake backend can play.
void main() {
  const loginTitle = 'Login to Track & Trace';
  const wrongLogin = 'Email or password is incorrect.';
  const wrongCode =
      'The code is wrong or has expired. Check the latest email, or send the '
      'code again.';
  const general = 'Something went wrong. Try again.';
  const forcedSubtitle =
      'Your password was set by someone else. Choose your own password to '
      'continue.';

  Map<String, dynamic> body(FlowApp app, String method, String path) =>
      app.backend.sent(method, path).last.data as Map<String, dynamic>;

  group('answers', () {
    for (final (status, code) in [
      (500, 'internal_error'),
      (429, 'rate_limited'),
      (400, 'validation_failed'),
      (404, 'not_found'),
    ]) {
      testWidgets('TC-SESS-038 a renewal answering $status keeps the login', (
        tester,
      ) async {
        var calls = 0;
        final app = await startApp(
          tester,
          overrides: {
            'GET checks': (r) async => calls++ == 0
                ? apiError(401, 'token_expired')
                : FakeBackend.example(
                    200,
                    'History of checks',
                    '200 First page',
                  ),
            'POST auth/refresh': always(apiError(status, code)),
          },
        );
        await app.tap(tab('History'));
        // Not logged out; the request failed once, with its reference.
        expect(find.text(loginTitle), findsNothing);
        expect(find.text('Reference: req-1'), findsOneWidget);
        expect(app.storage.values[SecureKeys.accessToken], 'access-1');
        expect(app.storage.values[SecureKeys.refreshToken], 'refresh-1');
      });
    }

    testWidgets('TC-AUTH-103 unknown fields in a login answer are ignored', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(
            ok({
              'status': 'logged_in',
              'access_token': 'a',
              'access_expires_in': 900,
              'refresh_token': 'r',
              'refresh_expires_in': 2592000,
              'must_change_password': false,
              'something_new': {'nested': true},
            }),
          ),
        },
      );
      await logInToCode(app);
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
    });

    for (final (name, data) in [
      ('a code answer without challenge_id', {'status': 'code_sent'}),
      (
        'a login without the refresh pass',
        {
          'status': 'logged_in',
          'access_token': 'a',
          'must_change_password': false,
        },
      ),
      ('no data at all', null),
    ]) {
      testWidgets('TC-AUTH-104 $name is an error', (tester) async {
        final app = await startApp(
          tester,
          loggedIn: false,
          overrides: {'POST auth/login': always(ok(data))},
        );
        await logInToCode(app);
        expect(find.text(loginTitle), findsOneWidget);
        expect(find.text(general), findsOneWidget);
        expect(app.storage.values[SecureKeys.accessToken], isNull);
      });
    }

    for (final (name, header) in [
      ('without Retry-After', null),
      ('with a date in Retry-After', 'Wed, 21 Oct 2026 07:28:00 GMT'),
    ]) {
      // TC-MIG-029: Missing/invalid Retry-After uses a message/manual retry.
      testWidgets(
        'TC-AUTH-105 login 429 $name: manual retry, no invented countdown',
        (
          tester,
        ) async {
          final app = await startApp(
            tester,
            loggedIn: false,
            overrides: {
              'POST auth/login': always(
                header == null
                    ? apiError(429, 'rate_limited')
                    : ScriptedAnswer(
                        429,
                        errorBody('rate_limited'),
                        headers: {
                          'retry-after': [header],
                        },
                      ),
              ),
            },
          );
          await logInToCode(app);
          expect(
            find.text('Too many attempts. Try again later.'),
            findsOneWidget,
          );
          await app.enter(const Key('login.email'), 'another@example.com');
          await app.tap(find.byKey(const Key('login.submit')));
          expect(app.backend.sent('POST', 'auth/login'), hasLength(2));
        },
      );
    }
  });

  // D65 (guide §3.2): a code answer with must_change_password opens only
  // the change screen; there is no "Not now", whatever else the answer has.
  testWidgets('TC-AUTH-106 the code answer with must_change_password: only '
      'the change screen', (tester) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/verify-phone': always(loggedIn(mustChange: true)),
      },
    );
    await logInWithCode(app);
    expect(find.text(forcedSubtitle), findsOneWidget);
    expect(find.text('Not now'), findsNothing);
  });

  // Whoever sets the password decides (backend D59, D65): a forced change
  // offers Save and Log out only.
  group('TC-AUTH-115 the change is forced only when the answer says so', () {
    testWidgets('must_change_password false: straight to Verify', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {'POST auth/verify-phone': always(loggedIn())},
      );
      await logInWithCode(app);
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
      expect(find.text(forcedSubtitle), findsNothing);
    });

    testWidgets('must_change_password true: Save and Logout only', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': always(loggedIn(mustChange: true)),
        },
      );
      await logInWithCode(app);
      expect(find.text(forcedSubtitle), findsOneWidget);
      expect(find.byKey(const Key('change.submit')), findsOneWidget);
      expect(find.byKey(const Key('change.logout')), findsOneWidget);
      expect(find.text('Not now'), findsNothing);
    });
  });

  group('logout (TC-SESS-039)', () {
    Future<void> logOut(FlowApp app) async {
      await app.tap(tab('Profile'));
      await app.tap(find.byKey(const Key('profile.logout')));
      await app.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log out'),
        ),
      );
    }

    testWidgets('sends no body', (tester) async {
      final app = await startApp(tester);
      await logOut(app);
      expect(find.text(loginTitle), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/logout').single.data, isNull);
    });

    testWidgets('with an expired pass: renewed, then logged out', (
      tester,
    ) async {
      var calls = 0;
      final app = await startApp(
        tester,
        overrides: {
          'POST auth/logout': (r) async => calls++ == 0
              ? apiError(401, 'token_expired')
              : FakeBackend.example(
                  200,
                  'Log out (this phone)',
                  '200 Logged out',
                ),
        },
      );
      await logOut(app);
      expect(find.text(loginTitle), findsOneWidget);
      expect(app.backend.sent('POST', 'auth/logout'), hasLength(2));
      expect(app.backend.sent('POST', 'auth/refresh'), hasLength(1));
      expect(app.storage.values[SecureKeys.accessToken], isNull);
    });
  });

  group('input', () {
    testWidgets('TC-AUTH-108 the login password is sent as typed: spaces '
        'and a tab kept', (tester) async {
      final app = await startApp(tester, loggedIn: false);
      final tab = String.fromCharCode(9);
      await logInToCode(app, password: ' pass word$tab');
      expect(body(app, 'POST', 'auth/login')['password'], ' pass word$tab');
    });

    testWidgets('TC-AUTH-109 the email is trimmed on Forgot password', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), '  official@example.com  ');
      await app.tap(find.byKey(const Key('forgot.submit')));
      expect(
        body(app, 'POST', 'auth/password/forgot')['email'],
        'official@example.com',
      );
    });

    for (final (name, email) in [
      ('a full-width at sign', 'official＠example.com'),
      (
        'a zero-width space',
        'offi${String.fromCharCode(0x200B)}cial@example.com',
      ),
      ('two at signs', 'official@@example.com'),
      ('nothing after the at sign', 'official@'),
    ]) {
      testWidgets('TC-AUTH-110 an email with $name is refused before '
          'sending', (tester) async {
        final app = await startApp(tester, loggedIn: false);
        await app.enter(const Key('login.email'), email);
        await app.enter(const Key('login.password'), 'secret-pass');
        await app.tap(find.byKey(const Key('login.submit')));
        expect(find.text('Enter a valid email address'), findsOneWidget);
        expect(app.backend.sent('POST', 'auth/login'), isEmpty);
      });
    }

    testWidgets('TC-AUTH-111 Reset password needs all 6 code digits', (
      tester,
    ) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      await app.enter(const Key('reset.new'), 'abcd1234');
      await app.enter(const Key('reset.repeat'), 'abcd1234');
      await app.enter(const Key('reset.code'), '12345');
      expect(app.enabled(const Key('reset.submit')), isFalse);
      await app.enter(const Key('reset.code'), '123456');
      expect(app.enabled(const Key('reset.submit')), isTrue);
    });
  });

  group('taps', () {
    testWidgets('TC-AUTH-112 two taps on Send code send one request', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/password/forgot': slow(
            (_) => FakeBackend.example(
              200,
              '1. Email a reset code',
              '200 Always the same answer',
            ),
          ),
        },
      );
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await tester.tap(find.byKey(const Key('forgot.submit')));
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('forgot.submit')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'auth/password/forgot'), hasLength(1));
    });

    testWidgets('TC-AUTH-112 two taps on Reset password send one request', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/password/reset': slow(
            (_) => FakeBackend.example(
              200,
              '2. Set a new password with the code',
              '200 Changed: log in again',
            ),
          ),
        },
      );
      await app.tapText('Forgot password?');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      await app.enter(const Key('reset.code'), '123456');
      await app.enter(const Key('reset.new'), 'abcd1234');
      await app.enter(const Key('reset.repeat'), 'abcd1234');
      // The "code sent" message would cover the button.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
          .clearSnackBars();
      await tester.ensureVisible(find.byKey(const Key('reset.submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset.submit')));
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('reset.submit')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'auth/password/reset'), hasLength(1));
    });

    testWidgets('TC-AUTH-112 two taps on Send the code again send one '
        'request', (tester) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/resend-code': slow(
            (_) => FakeBackend.example(
              200,
              '3. Send the code again',
              '200 A new code was emailed',
            ),
          ),
        },
      );
      await logInToCode(app);
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send the code again'));
      await tester.pump();
      await tester.tap(find.text('Send the code again'), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'auth/resend-code'), hasLength(1));
    });
  });

  group('sequences', () {
    testWidgets('TC-AUTH-038 six wrong passwords: the same message, no lock '
        'wording, then a login', (tester) async {
      var calls = 0;
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': (r) async =>
              ++calls <= 6 ? apiError(401, 'unauthenticated') : loggedIn(),
        },
      );
      await app.enter(const Key('login.email'), 'official@example.com');
      await app.enter(const Key('login.password'), 'wrong-pass');
      for (var i = 0; i < 6; i++) {
        await app.tap(find.byKey(const Key('login.submit')));
        expect(find.text(wrongLogin), findsOneWidget, reason: 'try ${i + 1}');
        expect(find.textContaining('lock'), findsNothing);
        expect(find.textContaining('Lock'), findsNothing);
        expect(app.enabled(const Key('login.submit')), isTrue);
      }
      await app.tap(find.byKey(const Key('login.submit')));
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
    });

    testWidgets('TC-AUTH-037 a blocked official: the same message', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(apiError(401, 'unauthenticated')),
        },
      );
      await logInToCode(app);
      expect(find.text(wrongLogin), findsOneWidget);
    });

    testWidgets('TC-AUTH-049 an expired code, a new one sent, the new code '
        'works', (tester) async {
      var verifies = 0;
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': (r) async =>
              verifies++ == 0 ? apiError(401, 'unauthenticated') : loggedIn(),
        },
      );
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '111111');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text(wrongCode), findsOneWidget);

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await app.tapText('Send the code again');
      await app.enter(const Key('verify.code'), '222222');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
      expect(body(app, 'POST', 'auth/verify-phone')['code'], '222222');
    });

    testWidgets('TC-AUTH-051 five wrong codes, then a new login with a new '
        'code', (tester) async {
      var logins = 0;
      var verifies = 0;
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': (r) async {
            logins++;
            return FakeBackend.example(
              200,
              '1. Log in',
              '200 New phone: a code was emailed',
            );
          },
          'POST auth/verify-phone': (r) async =>
              ++verifies <= 6 ? apiError(401, 'unauthenticated') : loggedIn(),
        },
      );
      await logInToCode(app);
      for (var i = 0; i < 6; i++) {
        await app.enter(const Key('verify.code'), '00000$i');
        await app.tap(find.byKey(const Key('verify.submit')));
        expect(find.text(wrongCode), findsOneWidget, reason: 'try ${i + 1}');
      }
      await app.tapText('Back to login');
      await logInToCode(app);
      expect(logins, 2);
      await app.enter(const Key('verify.code'), '123456');
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
    });

    testWidgets('TC-AUTH-113 a code checked once and the answer lost: the '
        'retry is told the code is used', (tester) async {
      var verifies = 0;
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          // The first answer never arrives (the server did accept it); the
          // retry finds the code used.
          'POST auth/verify-phone': (r) async => verifies++ == 0
              ? timedOut()(r)
              : apiError(401, 'unauthenticated', requestId: 'req-used'),
        },
      );
      await logInWithCode(app);
      expect(find.textContaining('No connection'), findsWidgets);
      await app.tap(find.byKey(const Key('verify.submit')));
      expect(find.text(wrongCode), findsOneWidget);
      expect(find.text('Reference: req-used'), findsOneWidget);
    });
  });

  group('start', () {
    testWidgets('TC-SESS-010 the profile fails at start; Try again', (
      tester,
    ) async {
      var calls = 0;
      await startApp(
        tester,
        overrides: {
          'GET me': (r) async =>
              calls++ == 0 ? offline()(r) : ok(Roles.fieldInspector),
        },
      );
      expect(find.textContaining('No connection'), findsOneWidget);
      await tester.tap(find.byKey(const Key('splash.retry')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify.input')), findsOneWidget);
    });

    testWidgets('TC-SESS-022 killed during a renewal: a new access pass and '
        'the old refresh pass; the renewal ends the login', (tester) async {
      final storage = FakeSecureStorageService();
      storage.values[SecureKeys.accessToken] = 'access-new';
      storage.values[SecureKeys.refreshToken] = 'refresh-used';
      final app = await startApp(
        tester,
        storage: storage,
        overrides: {
          'GET formats': always(apiError(401, 'token_expired')),
          'POST auth/refresh': always(apiError(401, 'unauthenticated')),
        },
      );
      expect(find.text(loginTitle), findsOneWidget);
      expect(app.storage.values[SecureKeys.accessToken], isNull);
      expect(app.storage.values[SecureKeys.phoneId], isNotNull);
    });
  });

  testWidgets('TC-SESS-031 a phone clock an hour off: the resend wait still '
      'runs from now', (tester) async {
    // The test's own clock, an hour ahead (the phone's clock is wrong).
    final testClock = clock;
    await withClock(
      Clock(() => testClock.now().add(const Duration(hours: 1))),
      () async {
        final app = await startApp(tester, loggedIn: false);
        await logInToCode(app);
        expect(find.textContaining('Send again in 60 s'), findsOneWidget);
        await tester.pump(const Duration(seconds: 61));
        await tester.pumpAndSettle();
        expect(find.text('Send the code again'), findsOneWidget);
      },
    );
  });

  // Backend D64 (2026-11-17) and guide §3.7: a wrong or closed reset code
  // shows the usual wrong-or-expired text and offers step 1 again.
  testWidgets('TC-AUTH-116 a wrong reset code offers a new code, with the '
      'email kept', (tester) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/password/reset': always(apiError(401, 'unauthenticated')),
      },
    );
    await app.tapText('Forgot password?');
    await app.enter(const Key('forgot.email'), 'official@example.com');
    await app.tap(find.byKey(const Key('forgot.submit')));
    await app.enter(const Key('reset.code'), '123456');
    await app.enter(const Key('reset.new'), 'abcd1234');
    await app.enter(const Key('reset.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('reset.submit')));

    expect(
      find.text('The code is wrong or has expired. Ask for a new code.'),
      findsOneWidget,
    );
    // Not the login code's advice.
    expect(find.textContaining('log in again'), findsNothing);

    await app.tap(find.byKey(const Key('reset.newCode')));
    expect(find.byKey(const Key('forgot.email')), findsOneWidget);
    expect(app.fieldText(const Key('forgot.email')), 'official@example.com');
    await app.tap(find.byKey(const Key('forgot.submit')));
    expect(app.backend.sent('POST', 'auth/password/forgot'), hasLength(2));
  });
}
