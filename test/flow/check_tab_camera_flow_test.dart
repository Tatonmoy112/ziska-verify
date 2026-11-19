import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// The Check tab opens on the camera: a read QR is the trigger, sent at once
/// as `POST lookups` (app API guide §4.2; final.md Sections 13.1.2, 13.7).
void main() {
  const qr = 'https://www.ziskaverify.com/q/Q8F2KD91XA7M';

  testWidgets('TC-LOOK-124 a scan on the Check tab is sent at once, with no '
      'tap', (tester) async {
    final app = await startApp(tester);
    final camera = app.scanner.sessions.single;
    expect(find.byKey(const Key('verify.camera')), findsOneWidget);
    expect(camera.running, isTrue);

    app.scanner.scan(qr);
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'lookups').single.data, {
      'way': 'qr',
      'value': 'Q8F2KD91XA7M',
    });
    expect(find.text('Genuine product'), findsWidgets);
    expect(camera.running, isFalse, reason: 'the result is on top');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('verify.camera')), findsOneWidget);
    expect(camera.running, isTrue, reason: 'back on the tab: scanning again');
  });

  testWidgets('TC-LOOK-125 the camera runs only while the tab is seen', (
    tester,
  ) async {
    final app = await startApp(tester, profile: Roles.supervisor);
    final camera = app.scanner.sessions.single;
    expect(camera.running, isTrue);

    // Another tab.
    await app.tap(tab('History'));
    expect(camera.running, isFalse);
    await app.tap(tab('Check'));
    expect(camera.running, isTrue);

    // A tool on top: scanner mode has its own camera; this one stops.
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    expect(camera.running, isFalse);
    expect(app.scanner.sessions, hasLength(2));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(camera.running, isTrue);

    // The app in the background, then back.
    Future<void> to(List<AppLifecycleState> steps) async {
      steps.forEach(tester.binding.handleAppLifecycleStateChanged);
      await tester.pump();
    }

    await to(const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    expect(camera.running, isFalse);
    await to(const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    expect(camera.running, isTrue);

    // A stopped camera reads nothing.
    await app.tap(tab('History'));
    app.scanner.scan(qr);
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'lookups'), isEmpty);
  });

  testWidgets('TC-LOOK-126 camera refused: Open settings, and a typed serial '
      'still checks', (tester) async {
    final app = await startApp(tester);
    app.scanner.problem = ScannerProblem.permissionDenied;
    await app.tap(tab('History'));
    await app.tap(tab('Check'));
    expect(find.byKey(const Key('scanner.openSettings')), findsOneWidget);

    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(app.backend.sent('POST', 'lookups').single.data, {
      'way': 'serial',
      'value': '1000001',
    });
  });

  testWidgets('TC-LOOK-127 without item:lookup there is no camera', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      profile: Roles.only(['incident:report']),
    );
    expect(find.byKey(const Key('verify.camera')), findsNothing);
    expect(app.scanner.sessions, isEmpty);
  });
}
