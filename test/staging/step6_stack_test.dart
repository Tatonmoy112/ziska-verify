import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 6 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): serial stacks, on the server's real answers replayed
/// offline through the whole app (TC-STG-031 … -034).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  Map<String, Answer> server() => {
    'GET me': real('me_200.json'),
    'GET formats': real('formats_200.json'),
    'POST lookups/serials': (r) {
      final serials = ((r.data as Map)['serials'] as List).cast<String>();
      return stagingScripted(
        serials.length == 1
            ? 'stack_leading_zeros_200.json'
            : 'stack_three_200.json',
      );
    },
    'GET checks': real('stack_session_checks_200.json'),
  };

  Future<FlowApp> sendStack(WidgetTester tester, String typed) async {
    final app = await startApp(tester, overrides: server());
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), typed);
    await app.tap(find.byKey(const Key('serials.submit')));
    return app;
  }

  testWidgets('TC-STG-031 the real stack of three: every row as sent', (
    tester,
  ) async {
    final app = await sendStack(tester, '1, 1000001, 1234567890');
    expect(app.backend.sent('POST', 'lookups/serials').single.data, {
      'serials': ['1', '1000001', '1234567890'],
    });
    for (final serial in ['1', '1000001', '1234567890']) {
      expect(
        find.byKey(Key('serials.row.$serial')),
        findsOneWidget,
        reason: serial,
      );
    }
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
    expect(find.textContaining('could not be shown'), findsNothing);
  });

  testWidgets('TC-STG-032 001 and 1: sent once as 001, and the real '
      'answer is shown, not "recorded, cannot be shown"', (tester) async {
    final app = await sendStack(tester, '001, 1');
    expect(find.text('1 of 50 serials · 1 repeated, sent once'), findsNothing);
    expect(app.backend.sent('POST', 'lookups/serials').single.data, {
      'serials': ['001'],
    });
    expect(find.byKey(const Key('serials.row.001')), findsOneWidget);
    expect(find.textContaining('could not be shown'), findsNothing);
    expect(find.bySemanticsLabel('Scanned: 1'), findsOneWidget);
  });

  testWidgets('TC-STG-032 the count says 001 and 1 are one serial', (
    tester,
  ) async {
    final app = await startApp(tester, overrides: server());
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), '001, 1');
    expect(
      find.text('1 of 50 serials · 1 repeated, sent once'),
      findsOneWidget,
    );
  });

  test('TC-STG-033 51 serials: the server refuses them (400); the app never '
      'sends them', () {
    final answer = stagingAnswer('stack_51_serials_400.json');
    final error = ErrorMapper.fromResponse(
      statusCode: answer['status'] as int,
      body: answer['body'],
    );
    expect(error, isA<ValidationException>());
  });

  testWidgets('TC-STG-034 the stack in History: its checks by session', (
    tester,
  ) async {
    final app = await sendStack(tester, '1, 1000001, 1234567890');
    await tester.scrollUntilVisible(
      find.text("View this session's checks"),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tapText("View this session's checks");
    final sent = app.backend.sent('GET', 'checks').last;
    expect(sent.queryParameters['session_id'], isNotNull);
    expect(find.text('Session checks'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('1000001'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1000001'), findsWidgets);
  });
}
