import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// TC-MIG-069 (UI audit 2026-11-22, 6.2): a stack whose answer was lost may
/// already be recorded, as a session of kind `serial` (guide §4.7), so sending
/// it again checks every serial again. The app asks before it does; a stack
/// that never left the phone goes again without asking.
void main() {
  const serials = '1000001 1000002 1000003';
  const title = 'Send the stack again?';

  /// [first] answers the first stack; then the fake backend's own answer.
  Future<FlowApp> open(WidgetTester tester, Answer first) async {
    late final FlowApp app;
    app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'POST lookups/serials': (r) {
          app.backend.overrides.remove('POST lookups/serials');
          return first(r);
        },
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.serials')));
    await app.enter(const Key('serials.input'), serials);
    await app.tap(find.byKey(const Key('serials.submit')));
    return app;
  }

  int sent(FlowApp app) => app.backend.sent('POST', 'lookups/serials').length;

  testWidgets('TC-MIG-069 a lost answer: not sent again without asking; '
      'Cancel keeps it, Send again sends it', (tester) async {
    final app = await open(tester, timedOut());
    expect(find.textContaining('may already be recorded'), findsOneWidget);
    expect(sent(app), 1);

    await app.tap(find.byKey(const Key('serials.submit')));
    expect(find.text(title), findsOneWidget);
    expect(find.textContaining('History'), findsWidgets);
    expect(sent(app), 1, reason: 'nothing sent before the answer');

    await app.tapText('Cancel');
    expect(find.text(title), findsNothing);
    expect(sent(app), 1);

    await app.tap(find.byKey(const Key('serials.submit')));
    await app.tap(find.byKey(const Key('serials.resend')));
    expect(sent(app), 2);
    expect(find.text(title), findsNothing);
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
  });

  testWidgets('TC-MIG-069 never sent (no connection): sent again without '
      'asking', (tester) async {
    final app = await open(tester, offline());
    expect(sent(app), 1);
    await app.tap(find.byKey(const Key('serials.submit')));
    expect(find.text(title), findsNothing);
    expect(sent(app), 2);
    expect(find.bySemanticsLabel('Scanned: 3'), findsOneWidget);
  });
}
