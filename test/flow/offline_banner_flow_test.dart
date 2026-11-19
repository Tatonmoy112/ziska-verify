import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// The offline banner above every screen (final.md Section 14.2;
/// docs/test-cases/10-errors-network.md, TC-ERR-037 … -045).
void main() {
  final banner = find.byKey(const Key('network.offline'));
  const text = 'No internet connection. Checks need a connection.';

  /// The banner shows after a second offline.
  Future<void> goOffline(FlowApp app) async {
    app.connectivity.set(online: false);
    await app.tester.pump(const Duration(milliseconds: 1100));
    await app.tester.pump();
  }

  /// Android's back button.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  /// The banner goes on the next frame.
  Future<void> goOnline(FlowApp app) async {
    app.connectivity.set(online: true);
    await app.tester.pump();
    await app.tester.pump();
  }

  testWidgets('TC-ERR-037 the banner on every main screen', (tester) async {
    final app = await startApp(tester, profile: Roles.supervisor);
    await goOffline(app);
    expect(find.text(text), findsOneWidget, reason: 'Check');

    await app.tap(tab('History'));
    expect(banner, findsOneWidget, reason: 'History');
    await app.tap(tab('Profile'));
    expect(banner, findsOneWidget, reason: 'Profile');
    await app.tap(tab('Check'));
    for (final key in tiles.values) {
      await tester.scrollUntilVisible(
        find.byKey(key),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await app.tap(find.byKey(key));
      expect(banner, findsOneWidget, reason: '$key');
      await back(tester);
    }
  });

  testWidgets('TC-ERR-038 the banner goes when back online', (tester) async {
    final app = await startApp(tester);
    await goOffline(app);
    expect(banner, findsOneWidget);
    await goOnline(app);
    expect(banner, findsNothing);
  });

  testWidgets('TC-ERR-039 the banner on the login screens', (tester) async {
    final app = await startApp(tester, loggedIn: false);
    await goOffline(app);
    expect(banner, findsOneWidget, reason: 'Login');
    await app.tapText('Forgot password?');
    expect(banner, findsOneWidget, reason: 'Forgot password');
    await back(tester);
    await app.tapText('Sign up');
    expect(banner, findsOneWidget, reason: 'Sign up');
  });

  testWidgets('TC-ERR-040 the banner never blocks: a check is still tried', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {'POST lookups': offline()},
    );
    await goOffline(app);
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(app.backend.sent('POST', 'lookups'), hasLength(1));
    expect(
      find.text('Unable to check. Check the connection and try again.'),
      findsOneWidget,
    );
    expect(banner, findsOneWidget);
  });

  testWidgets('TC-ERR-041 back online sends nothing by itself', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {'POST lookups': offline()},
    );
    await goOffline(app);
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    final before = app.backend.requests.length;
    await goOnline(app);
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(app.backend.requests, hasLength(before));
  });

  testWidgets('TC-ERR-042 Wi-Fi without internet: no banner, the request '
      'says so', (tester) async {
    final app = await startApp(
      tester,
      overrides: {'GET checks': offline()},
    );
    // The link is up (connectivity online); the requests fail.
    await app.tap(tab('History'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
    expect(find.textContaining('No connection'), findsWidgets);
  });

  testWidgets('TC-ERR-043 a flapping link: no crash, no banner at the end', (
    tester,
  ) async {
    final app = await startApp(tester);
    for (var i = 0; i < 10; i++) {
      app.connectivity.set(online: false);
      await tester.pump(const Duration(milliseconds: 250));
      app.connectivity.set(online: true);
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(seconds: 2));
    expect(banner, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-ERR-044 read by TalkBack: a live region with its text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final app = await startApp(tester);
    await goOffline(app);
    expect(find.bySemanticsLabel(text), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel(text));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    semantics.dispose();
  });

  testWidgets('TC-ERR-045 fits at 3x font on a 320 px phone', (tester) async {
    final app = await startApp(tester, profile: Roles.supervisor);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await goOffline(app);
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final name in ['History', 'Profile', 'Check']) {
      await app.tap(tab(name));
      expect(tester.takeException(), isNull, reason: name);
    }
  });
}
