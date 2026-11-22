import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: the Sessions view of History, edge cases
/// (docs/test-cases/16-mobile-migration.md TC-MIG-057 … -059; test-server
/// integration, step 5).
void main() {
  Map<String, Object?> session(String id, {String status = 'ended'}) => {
    'id': id,
    'kind': 'qr',
    'status': status,
    'started_at': '2026-11-22T06:15:02Z',
    'last_scan_at': '2026-11-22T06:32:41Z',
    'scanned': 3,
    'valid': 2,
    'warning': 0,
    'not_found': 1,
    'unassigned': 0,
    'official': 'Asha Rao',
  };

  ScriptedAnswer page(List<Map<String, Object?>> sessions, {String? next}) =>
      ok({'sessions': sessions, 'next_cursor': next});

  Future<FlowApp> openSessions(
    WidgetTester tester,
    Map<String, Answer> overrides,
  ) async {
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: overrides,
    );
    await app.tap(tab('History'));
    await app.tap(find.byKey(const Key('history.view.sessions')));
    return app;
  }

  const a = '11111111-1111-4111-8111-111111111111';
  const b = '22222222-2222-4222-8222-222222222222';

  testWidgets('TC-MIG-057 no sessions in the period', (tester) async {
    await openSessions(tester, {'GET lookups/sessions': always(page([]))});
    expect(find.text('No sessions found.'), findsOneWidget);
    expect(find.text('Showing the last 7 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-MIG-058 the next page by its cursor, then an empty last '
      'page: the list ends', (tester) async {
    final app = await openSessions(tester, {
      'GET lookups/sessions': (r) => switch (r.queryParameters['cursor']) {
        null => page([session(a, status: 'open')], next: 'c-2'),
        'c-2' => page([session(b)], next: 'c-3'),
        _ => page([]),
      },
    });
    await tester.pumpAndSettle();
    final sent = app.backend.sent('GET', 'lookups/sessions');
    expect(
      [for (final r in sent) r.queryParameters['cursor']],
      [null, 'c-2', 'c-3'],
    );
    expect(find.byKey(const Key('sessions.row.$a')), findsOneWidget);
    expect(find.byKey(const Key('sessions.row.$b')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(app.backend.sent('GET', 'lookups/sessions'), hasLength(3));
  });

  testWidgets('TC-MIG-059 the first page fails, then Try again', (
    tester,
  ) async {
    var calls = 0;
    final app = await openSessions(tester, {
      'GET lookups/sessions': (_) => calls++ == 0
          ? apiError(500, 'internal_error', requestId: 'req-s')
          : page([session(a)]),
    });
    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
    expect(find.textContaining('req-s'), findsOneWidget);
    await app.tapText('Try again');
    expect(find.byKey(const Key('sessions.row.$a')), findsOneWidget);
  });
}
