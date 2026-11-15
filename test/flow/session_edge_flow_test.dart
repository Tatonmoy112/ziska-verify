import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/fake_secure_storage_service.dart';
import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: the edge, worst, and failure cases of staying logged in
/// (docs/test-cases/02-session.md, TC-SESS-011 and later).
void main() {
  const loginTitle = 'Login to Track & Trace';
  final historyTab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text('History'),
  );
  final confirmLogout = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text('Log out'),
  );

  testWidgets('TC-SESS-011 a refused renewal lands on Login and keeps the '
      'phone ID', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'GET checks': always(apiError(401, 'token_expired')),
        'POST auth/refresh': always(apiError(401, 'unauthenticated')),
      },
    );
    final phoneId = app.storage.values[SecureKeys.phoneId];
    await app.tap(historyTab);

    expect(find.text(loginTitle), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
    expect(app.storage.values[SecureKeys.refreshToken], isNull);
    expect(app.storage.values[SecureKeys.phoneId], phoneId);
  });

  testWidgets('TC-SESS-019 login routes carry no pass', (tester) async {
    final app = await startApp(tester, loggedIn: false);
    await logInToCode(app);
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    await app.tapText('Send the code again');
    await app.tapText('Back to login');
    await app.tapText('Forgot password?');
    await app.enter(const Key('forgot.email'), 'official@example.com');
    await app.tap(find.byKey(const Key('forgot.submit')));
    await app.enter(const Key('reset.code'), '123456');
    await app.enter(const Key('reset.new'), 'abcd1234');
    await app.enter(const Key('reset.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('reset.submit')));
    await logInWithCode(app);

    final routes = {
      'auth/login',
      'auth/verify-phone',
      'auth/resend-code',
      'auth/password/forgot',
      'auth/password/reset',
    };
    final checked = app.backend.requests.where((r) => routes.contains(r.path));
    expect(checked.map((r) => r.path).toSet(), routes);
    for (final r in checked) {
      expect(r.headers['Authorization'], isNull, reason: r.path);
    }
  });

  testWidgets('TC-SESS-023 no passes at start: Login, the phone ID kept', (
    tester,
  ) async {
    final first = await startApp(tester, loggedIn: false);
    final phoneId = first.storage.values[SecureKeys.phoneId];
    expect(find.text(loginTitle), findsOneWidget);

    final second = await startApp(tester, storage: first.storage);
    expect(find.text(loginTitle), findsOneWidget);
    expect(second.storage.values[SecureKeys.phoneId], phoneId);
  });

  group('TC-SESS-024 one pass missing at start', () {
    // As the server: a request without a pass is refused.
    Answer meNeedsAPass() => (r) {
      if (r.headers['Authorization'] == null) {
        return apiError(401, 'unauthenticated');
      }
      return ok(Roles.fieldInspector);
    };

    // A login needs both passes: with one left, Login, the leftover pass
    // cleared, the phone still trusted.
    for (final (name, key) in [
      ('only the refresh pass', SecureKeys.refreshToken),
      ('only the access pass', SecureKeys.accessToken),
    ]) {
      testWidgets(name, (tester) async {
        final storage = FakeSecureStorageService()..values[key] = 'pass-1';
        final app = await startApp(
          tester,
          storage: storage,
          overrides: {'GET me': meNeedsAPass()},
        );
        final phoneId = app.storage.values[SecureKeys.phoneId];

        expect(find.text(loginTitle), findsOneWidget);
        expect(find.text('Welcome back,'), findsNothing);
        expect(app.storage.values[SecureKeys.accessToken], isNull);
        expect(app.storage.values[SecureKeys.refreshToken], isNull);
        expect(app.storage.values[SecureKeys.phoneId], phoneId);
      });
    }
  });

  testWidgets('TC-SESS-026 GET me answered 401 at start', (tester) async {
    final app = await startApp(
      tester,
      overrides: {'GET me': always(apiError(401, 'unauthenticated'))},
    );
    expect(find.text(loginTitle), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
    expect(app.storage.values[SecureKeys.refreshToken], isNull);
  });

  testWidgets('TC-SESS-028 logout while a request is in flight', (
    tester,
  ) async {
    await startApp(
      tester,
      overrides: {
        'GET checks': slow(
          (_) =>
              FakeBackend.example(200, 'History of checks', '200 First page'),
          const Duration(seconds: 3),
        ),
      },
    );
    await tester.tap(historyTab);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    // Below the check counts: scrolled into view first.
    await tester.ensureVisible(find.byKey(const Key('profile.logout')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile.logout')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(confirmLogout);
    await tester.pumpAndSettle();
    // The late History answer arrives after the logout.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text(loginTitle), findsOneWidget);
    expect(find.text('1000001'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-SESS-029 a failed logout still logs out', (tester) async {
    final app = await startApp(
      tester,
      overrides: {'POST auth/logout': always(apiError(500, 'internal_error'))},
    );
    await app.tapText('Profile');
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tap(confirmLogout);

    expect(find.text(loginTitle), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
    expect(app.storage.values[SecureKeys.refreshToken], isNull);
  });

  testWidgets('TC-SESS-030 logout tapped twice sends one logout', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST auth/logout': slow(
          (_) => FakeBackend.example(
            200,
            'Log out (this phone)',
            '200 Logged out',
          ),
        ),
      },
    );
    await app.tapText('Profile');
    await app.tap(find.byKey(const Key('profile.logout')));
    await tester.tap(confirmLogout);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(
      find.byKey(const Key('profile.logout')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 50));
    // Confirm any second dialog the second tap opened.
    if (confirmLogout.evaluate().isNotEmpty) {
      await tester.tap(confirmLogout.last, warnIfMissed: false);
    }
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text(loginTitle), findsOneWidget);
    expect(app.backend.sent('POST', 'auth/logout'), hasLength(1));
  });
}
