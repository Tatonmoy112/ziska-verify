import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-UI-185 (emulator run, finding F-7): the status bar's clock and icons
/// stay readable on every screen: light over navy, dark over white, and a
/// page scrolled under the status bar does not run under the clock.
void main() {
  /// A phone's status bar, 47 points high.
  Future<FlowApp> start(WidgetTester tester, {bool loggedIn = true}) async {
    final app = await startApp(
      tester,
      loggedIn: loggedIn,
      profile: Roles.supervisor,
    );
    tester.view.padding = const FakeViewPadding(top: 141);
    tester.view.viewPadding = const FakeViewPadding(top: 141);
    await tester.pumpAndSettle();
    return app;
  }

  Brightness? icons() => SystemChrome.latestStyle?.statusBarIconBrightness;

  /// The navy strip behind the status bar, shown once the page scrolls.
  double scrim(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(find.byKey(const Key('statusBar.scrim')))
      .opacity;

  group('TC-UI-185 the status bar stays readable', () {
    testWidgets('the Check tab: light icons on the navy header', (
      tester,
    ) async {
      await start(tester);
      expect(icons(), Brightness.light);
    });

    testWidgets('Profile: light icons; scrolled, a navy strip under them', (
      tester,
    ) async {
      final app = await start(tester);
      await app.tap(tab('Profile'));
      expect(icons(), Brightness.light);
      expect(scrim(tester), 0, reason: 'at the top the header shows');

      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(scrim(tester), 1, reason: 'the cards never run under the clock');
      expect(icons(), Brightness.light);

      // Back to the very top (a drag loses its touch slop).
      await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
      await tester.pumpAndSettle();
      expect(scrim(tester), 0);
    });

    testWidgets('Change password: light icons on its navy header', (
      tester,
    ) async {
      final app = await start(tester);
      await app.tap(tab('Profile'));
      await app.tapText('Change password');
      expect(
        find.text(
          'Choose a new password. Your other phones will be '
          'logged out.',
        ),
        findsOneWidget,
      );
      expect(icons(), Brightness.light);
    });

    testWidgets('the date picker: dark icons on its white page', (
      tester,
    ) async {
      final app = await start(tester);
      // A wider screen: the test font draws every letter as a square, so
      // the picker's "Start Date – End Date" would not fit at 390 points,
      // as it does with the phone's font (seen on the emulator, 412).
      tester.view.physicalSize = const Size(1800, 2745);
      await tester.pumpAndSettle();
      await app.tap(tab('History'));
      expect(icons(), Brightness.light, reason: "History's navy bar");
      await app.tap(find.byKey(const Key('history.filters')));
      await app.tapText('Choose dates');
      expect(find.text('Select range'), findsOneWidget);
      expect(icons(), Brightness.dark);
    });

    testWidgets('Login: dark icons on white', (tester) async {
      await start(tester, loggedIn: false);
      expect(find.text('Login to Track & Trace'), findsOneWidget);
      expect(icons(), Brightness.dark);
    });
  });
}
