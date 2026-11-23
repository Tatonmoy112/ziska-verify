import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// A forced password change, as the backend decided (D65; guide §3.2):
/// there is no "Not now". Whoever sets the password ticks "must change
/// password" or not. Ticked, only the change-password screen (and Log out)
/// until it is changed; unticked, the app as usual, the password changeable
/// in Profile. TC-AUTH-095, TC-AUTH-092.
void main() {
  const notNow = Key('change.later');

  /// A `logged_in` answer; [extra] adds fields the guide does not have,
  /// which the app must ignore.
  ScriptedAnswer login({
    required bool mustChange,
    Map<String, Object?> extra = const {},
  }) => ok({
    'status': 'logged_in',
    'access_token': 'access-new',
    'access_expires_in': 900,
    'refresh_token': 'refresh-new',
    'refresh_expires_in': 2592000,
    'must_change_password': mustChange,
    ...extra,
  });

  Future<FlowApp> start(
    WidgetTester tester, {
    required bool mustChange,
    Map<String, Object?> extra = const {},
    Map<String, Object?>? profile,
  }) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      profile:
          profile ??
          {...Roles.fieldInspector, 'must_change_password': mustChange},
      overrides: {
        'POST auth/login': always(login(mustChange: mustChange, extra: extra)),
      },
    );
    await logInToCode(app);
    return app;
  }

  testWidgets('TC-AUTH-095 tick on: only the change screen and Log out, no '
      'Not now, even if a server sent password_change_skippable', (
    tester,
  ) async {
    await start(
      tester,
      mustChange: true,
      extra: {'password_change_skippable': true},
    );
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.byKey(notNow), findsNothing);
    expect(find.text('Not now'), findsNothing);
    expect(find.byKey(const Key('change.logout')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('TC-AUTH-095 tick off: the app as usual, with no password '
      'reminder in Profile', (tester) async {
    final app = await start(
      tester,
      mustChange: false,
      profile: {
        ...Roles.fieldInspector,
        'must_change_password': false,
        'password_change_pending': true,
      },
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    await app.tap(tab('Profile'));
    expect(find.byKey(const Key('profile.identity')), findsOneWidget);
    expect(find.byKey(const Key('profile.passwordPending')), findsNothing);
  });

  testWidgets('TC-AUTH-092 back does nothing on a forced change; Log out '
      'still works', (tester) async {
    final app = await start(tester, mustChange: true);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Set a new password'), findsOneWidget);

    await app.tap(find.byKey(const Key('change.logout')));
    expect(find.text('Login to Track & Trace'), findsOneWidget);
    expect(app.storage.values[SecureKeys.accessToken], isNull);
  });
}
