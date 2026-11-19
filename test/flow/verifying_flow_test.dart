import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';

import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: the verification loader (final.md Section 13.1.2, decision
/// 48; docs/test-cases/04-lookup.md TC-LOOK-102 … -107).
void main() {
  const valid = 'Genuine product';
  final loader = find.byType(VerifyingView);

  ScriptedAnswer validAnswer() => FakeBackend.example(
    200,
    'Look up one item',
    '200 valid: genuine, first check',
  );

  /// Types a serial and presses Verify, without waiting for the answer.
  Future<FlowApp> verify(
    WidgetTester tester,
    Answer answer,
  ) async {
    final app = await startApp(tester, overrides: {'POST lookups': answer});
    await app.enter(const Key('verify.input'), '1000001');
    await tester.tap(find.byKey(const Key('verify.submit')));
    await tester.pump();
    return app;
  }

  testWidgets('TC-LOOK-102 a slow lookup shows the loader', (tester) async {
    await verify(
      tester,
      slow((_) => validAnswer()),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(loader, findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    expect(loader, findsOneWidget);

    expect(find.text('Checking the item…'), findsOneWidget);
    // Code format ticked; the other two wait for the answer.
    final codeFormat = find.ancestor(
      of: find.text('Code format'),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(
        of: codeFormat,
        matching: find.byKey(const Key('verifying.step.done')),
      ),
      findsOneWidget,
    );
    for (final step in ['Item record', 'Check count']) {
      final row = find.ancestor(
        of: find.text(step),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(
          of: row,
          matching: find.byKey(const Key('verifying.step.waiting')),
        ),
        findsOneWidget,
        reason: step,
      );
    }
    // Over the whole screen, the bottom bar included.
    expect(
      tester.getRect(loader),
      Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio,
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('TC-LOOK-103 a fast lookup never shows the loader', (
    tester,
  ) async {
    await verify(tester, (_) => validAnswer());
    for (var i = 0; i < 20; i++) {
      expect(loader, findsNothing);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(loader, findsNothing);
    expect(find.text(valid), findsOneWidget);
  });

  testWidgets('TC-LOOK-104 the result replaces the loader', (tester) async {
    await verify(
      tester,
      slow((_) => validAnswer()),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(loader, findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(loader, findsNothing);
    expect(find.byType(LookupResultScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LookupResultScreen), findsNothing);
    expect(loader, findsNothing);
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
  });

  testWidgets('TC-LOOK-105 a failure closes the loader', (tester) async {
    await verify(
      tester,
      slow(
        always(apiError(429, 'rate_limited', retryAfter: 30, requestId: 'r1')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(loader, findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(loader, findsNothing);
    expect(find.textContaining('Too many attempts'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();

    await verify(
      tester,
      slow(always(apiError(500, 'internal_error', requestId: 'req-500'))),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(loader, findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(loader, findsNothing);
    expect(find.text('Reference: req-500'), findsOneWidget);
  });

  testWidgets('TC-LOOK-106 back waits during the check', (tester) async {
    final app = await verify(
      tester,
      slow((_) => validAnswer()),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(loader, findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(loader, findsOneWidget);
    expect(find.byKey(const Key('verify.input')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(valid), findsOneWidget);
    expect(app.backend.sent('POST', 'lookups'), hasLength(1));
  });

  testWidgets('TC-LOOK-107 the loader from the scanner', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST lookups': slow((_) => validAnswer()),
      },
    );
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(loader, findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(loader, findsNothing);
    expect(find.text(valid), findsOneWidget);
  });
}
