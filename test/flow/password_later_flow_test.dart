import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Change the first password now, or later (final.md Section 6.6;
/// docs/backend-requests/password-change-later.md). TC-AUTH-085 … -093.
void main() {
  const notNow = Key('change.later');
  const choiceSubtitle =
      'Your password was set by someone else. Choose your own now, or later '
      'from Profile.';
  const pendingBanner =
      'Your password was set by someone else. Change it to keep your account '
      'safe.';

  /// The profile after **Not now**: the change is no longer forced; the
  /// reminder shows.
  final pending = {
    ...Roles.fieldInspector,
    'must_change_password': false,
    'password_change_pending': true,
  };

  /// Logs out and in again: the login answers a forced change that may be
  /// skipped.
  Future<FlowApp> start(
    WidgetTester tester, {
    bool canSkip = true,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      profile: pending,
      overrides: {
        'POST auth/login': always(loggedIn(mustChange: true, canSkip: canSkip)),
        ...overrides,
      },
    );
    await logInToCode(app);
    return app;
  }

  Future<void> openProfile(FlowApp app) => app.tap(tab('Profile'));

  testWidgets('TC-AUTH-085 Not now goes on to the app with a normal pass', (
    tester,
  ) async {
    final app = await start(tester);
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.text(choiceSubtitle), findsOneWidget);
    expect(find.byKey(notNow), findsOneWidget);
    expect(find.byKey(const Key('change.logout')), findsOneWidget);

    await app.tap(find.byKey(notNow));

    expect(find.byKey(const Key('verify.input')), findsOneWidget);
    expect(app.backend.sent('POST', 'me/password/later'), hasLength(1));
    // The new access pass is stored; the refresh pass stays.
    expect(app.storage.values[SecureKeys.accessToken], 'access-later');
    expect(app.storage.values[SecureKeys.refreshToken], 'refresh-new');
    // Every request after it carries the new pass.
    final me = app.backend.sent('GET', 'me').last;
    expect(me.headers['Authorization'], 'Bearer access-later');
  });

  testWidgets('TC-AUTH-086 the next login asks again', (tester) async {
    final app = await start(tester);
    await app.tap(find.byKey(notNow));
    await openProfile(app);
    await tester.ensureVisible(find.byKey(const Key('profile.logout')));
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log out'),
      ),
    );
    expect(find.text('Login to Track & Trace'), findsOneWidget);

    await logInToCode(app);
    expect(find.text(choiceSubtitle), findsOneWidget);
    expect(find.byKey(notNow), findsOneWidget);
  });

  testWidgets('TC-AUTH-087 Profile reminds, and a change clears it', (
    tester,
  ) async {
    final app = await start(tester);
    await app.tap(find.byKey(notNow));
    await openProfile(app);
    expect(find.text(pendingBanner), findsOneWidget);

    // The backend clears the reminder with the change.
    app.backend.overrides['POST me/password'] = (r) {
      app.backend.profile = {...pending, 'password_change_pending': false};
      return FakeBackend.example(
        200,
        'Change the password',
        '200 Changed: a new access pass',
      );
    };
    await app.tap(find.byKey(const Key('profile.passwordPending.change')));
    // The voluntary change (back allowed), not the forced one.
    expect(
      find.text(
        'Your password was set by someone else. Choose your own password to '
        'continue.',
      ),
      findsNothing,
    );
    await app.enter(const Key('change.old'), 'first-pass1');
    await app.enter(const Key('change.new'), 'my-own-pass1');
    await app.enter(const Key('change.repeat'), 'my-own-pass1');
    await app.tap(find.byKey(const Key('change.submit')));

    // Back on Profile, scrolled to its top.
    await app.tester.drag(
      find.byType(Scrollable).last,
      const Offset(0, 2000),
    );
    await app.tester.pumpAndSettle();
    expect(find.byKey(const Key('profile.identity')), findsOneWidget);
    expect(find.text(pendingBanner), findsNothing);
  });

  testWidgets('TC-AUTH-088 without password_change_skippable the change '
      'stays required', (tester) async {
    await start(tester, canSkip: false);
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.text(choiceSubtitle), findsNothing);
    expect(find.byKey(notNow), findsNothing);
    expect(find.byKey(const Key('change.logout')), findsOneWidget);
  });

  testWidgets('TC-AUTH-089 Not now offline: the error, and the screen stays', (
    tester,
  ) async {
    final app = await start(
      tester,
      overrides: {'POST me/password/later': offline()},
    );
    await app.tap(find.byKey(notNow));
    expect(find.text(choiceSubtitle), findsOneWidget);
    expect(find.byKey(notNow), findsOneWidget);
    expect(find.textContaining('No connection'), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], 'access-new');
  });

  testWidgets('TC-AUTH-090 Not now refused: the message, and Not now goes', (
    tester,
  ) async {
    final app = await start(
      tester,
      overrides: {
        'POST me/password/later': always(apiError(403, 'forbidden')),
      },
    );
    await app.tap(find.byKey(notNow));
    expect(
      find.text(
        'Not now is not available for your account. Choose a new password '
        'or log out.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(notNow), findsNothing);
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.byKey(const Key('change.logout')), findsOneWidget);
  });

  testWidgets('TC-AUTH-091 a restart: after Not now the app opens; still '
      'forced, the choice comes back', (tester) async {
    final first = await start(tester);
    await first.tap(find.byKey(notNow));

    // After Not now, GET me no longer forces the change.
    await startApp(tester, profile: pending, storage: first.storage);
    expect(find.byKey(const Key('verify.input')), findsOneWidget);

    // Still forced, and skippable: GET me says so after a restart.
    await startApp(
      tester,
      profile: {
        ...Roles.fieldInspector,
        'must_change_password': true,
        'password_change_skippable': true,
      },
      storage: first.storage,
    );
    expect(find.text(choiceSubtitle), findsOneWidget);
    expect(find.byKey(notNow), findsOneWidget);
  });

  testWidgets('TC-AUTH-092 back does nothing; Log out still works', (
    tester,
  ) async {
    final app = await start(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(choiceSubtitle), findsOneWidget);

    await app.tap(find.byKey(const Key('change.logout')));
    expect(find.text('Login to Track & Trace'), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
  });

  testWidgets("TC-AUTH-096 the mock build's demo plays the coming answers", (
    tester,
  ) async {
    // Today's backend: a forced change, no password_change_skippable, and
    // GET me still forcing it. The demo plays the rest.
    final app = await startApp(
      tester,
      loggedIn: false,
      demoPasswordLater: true,
      profile: {...Roles.fieldInspector, 'must_change_password': true},
      overrides: {'POST auth/login': always(loggedIn(mustChange: true))},
    );
    await logInToCode(app);
    expect(find.text(choiceSubtitle), findsOneWidget);

    await app.tap(find.byKey(notNow));
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
    // Answered by the demo, not sent.
    expect(app.backend.sent('POST', 'me/password/later'), isEmpty);

    await openProfile(app);
    expect(find.text(pendingBanner), findsOneWidget);
  });

  testWidgets('TC-AUTH-093 two taps on Not now send one request', (
    tester,
  ) async {
    final app = await start(
      tester,
      overrides: {
        'POST me/password/later': slow(
          always(
            ok({
              'access_token': 'access-later',
              'access_expires_in': 900,
              'must_change_password': false,
              'password_change_pending': true,
            }),
          ),
        ),
      },
    );
    await tester.tap(find.byKey(notNow));
    await tester.pump();
    await tester.tap(find.byKey(notNow), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'me/password/later'), hasLength(1));
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
  });
}
