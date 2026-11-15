import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: profile edge cases (docs/test-cases/09-profile.md,
/// TC-PROF-007 and later).
void main() {
  Future<FlowApp> openProfile(
    WidgetTester tester,
    Map<String, dynamic> profile, {
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, profile: profile, overrides: overrides);
    await app.tap(tab('Profile'));
    return app;
  }

  Map<String, dynamic> withName(String name) => {
    ...Roles.fieldInspector,
    'name': name,
  };

  for (final (id, name, initials) in [
    ('007', 'Karim', 'K'),
    // Whole graphemes: "রা" is one character (consonant + vowel sign).
    ('008', 'আশা রাও', 'আরা'),
    ('010', '  Asha   Rao ', 'AR'),
  ]) {
    testWidgets('TC-PROF-$id initials of "$name"', (tester) async {
      await openProfile(tester, withName(name));
      expect(find.text(initials), findsOneWidget);
    });
  }

  testWidgets('TC-PROF-009 a very long name fits Profile and Verify', (
    tester,
  ) async {
    final app = await openProfile(tester, withName('Asha ' * 20));
    expect(tester.takeException(), isNull);
    await app.tap(tab('Verify'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-PROF-011 no organisation', (tester) async {
    final app = await openProfile(tester, {
      ...Roles.fieldInspector,
      'organisation': null,
    });
    expect(find.textContaining('null'), findsNothing);
    await app.tap(tab('Verify'));
    expect(find.textContaining('null'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-PROF-012 support with an email only opens mail', (
    tester,
  ) async {
    final app = await openProfile(tester, {
      ...Roles.fieldInspector,
      'support': {'email': 'help@ziska.example', 'phone': null},
    });
    await app.tapText('Support contact');
    expect(app.launcher.emails.single.to, 'help@ziska.example');
    expect(app.launcher.calls, isEmpty);
  });

  testWidgets('TC-PROF-013 support with a phone only opens the dialler', (
    tester,
  ) async {
    final app = await openProfile(tester, {
      ...Roles.fieldInspector,
      'support': {'email': null, 'phone': '+91 80 0000 0000'},
    });
    await app.tapText('Support contact');
    expect(app.launcher.calls.single, '+91 80 0000 0000');
    expect(app.launcher.emails, isEmpty);
  });

  testWidgets('TC-PROF-014 a voluntary change returns to Profile', (
    tester,
  ) async {
    final app = await openProfile(tester, Roles.fieldInspector);
    await app.tapText('Change password');
    expect(
      find.text('Choose a new password. Your other phones will be logged out.'),
      findsOneWidget,
    );
    await app.enter(const Key('change.old'), 'old-pass-1');
    await app.enter(const Key('change.new'), 'abcd1234');
    await app.enter(const Key('change.repeat'), 'abcd1234');
    await app.tap(find.byKey(const Key('change.submit')));

    expect(find.text('Your password was changed.'), findsOneWidget);
    expect(find.byKey(const Key('profile.logout')), findsOneWidget);
    expect(find.byKey(const Key('change.submit')), findsNothing);
  });

  testWidgets('TC-PROF-015 back from a voluntary change', (tester) async {
    final app = await openProfile(tester, Roles.fieldInspector);
    await app.tapText('Change password');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile.logout')), findsOneWidget);
  });

  testWidgets('TC-PROF-016 Profile shows the role after a reload', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {'GET checks': always(apiError(403, 'forbidden'))},
    );
    app.backend.profile = {...Roles.fieldInspector, 'role': 'Senior inspector'};
    await app.tap(tab('History'));
    await app.tap(tab('Profile'));
    expect(find.text('Senior inspector'), findsWidgets);
    expect(find.text('Field inspector'), findsNothing);
  });

  testWidgets('TC-PROF-017 the log out confirm text', (tester) async {
    final app = await openProfile(tester, Roles.fieldInspector);
    await app.tap(find.byKey(const Key('profile.logout')));
    expect(find.text('Log out?'), findsOneWidget);
    expect(
      find.text(
        'This phone stays trusted, so the next login needs no emailed code.',
      ),
      findsOneWidget,
    );
  });
}
