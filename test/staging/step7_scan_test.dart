import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

import '../fakes/fake_session_service.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 7 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): scanner sessions, on the server's real answers replayed
/// offline (TC-STG-036 … -039).
///
/// The real answers carry the session the checker made. The server echoes
/// the session it was sent, so the fake server puts the app's own session
/// in each answer, as the real one would.
void main() {
  const a = 'https://www.ziskaverify.com/q/Q8F2KD91XA7M';
  const b = 'https://www.ziskaverify.com/q/K7M2PX4Q9AB1';
  const realSession = '4a7a81bb-4a34-4fde-ac36-22f72f2787fd';

  /// [name]'s real answer, in the session the app sent.
  ScriptedAnswer inSession(String name, String id) {
    final body = stagingAnswer(name)['body'] as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return ScriptedAnswer(200, {
      ...body,
      'data': {
        ...data,
        'session': {...data['session'] as Map<String, dynamic>, 'id': id},
      },
    });
  }

  /// The real server's scans: QR A first, QR B, then A again (a repeat).
  Answer realScans({Set<String>? ended}) {
    final seen = <String, Set<String>>{};
    return (r) {
      final sent = r.data as Map;
      final id = sent['session_id'] as String;
      if (ended?.contains(id) ?? false) {
        return stagingScripted('scan_session_ended_409.json');
      }
      final values = seen.putIfAbsent(id, () => {});
      final value = sent['value'] as String;
      final repeat = !values.add(value);
      if (ended != null) return inSession('scan_new_session_200.json', id);
      return inSession(switch ((value, repeat)) {
        ('Q8F2KD91XA7M', false) => 'scan_first_200.json',
        ('Q8F2KD91XA7M', true) => 'scan_repeat_200.json',
        _ => 'scan_second_200.json',
      }, id);
    };
  }

  Future<void> settleScans(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pumpAndSettle();
  }

  /// Scrolls the scanner's list to the row [ref].
  Future<void> showRow(WidgetTester tester, String ref) =>
      tester.scrollUntilVisible(
        find.byKey(ValueKey(ref)),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('session.rows')),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  group('the repository on the real answers', () {
    late ScriptedAdapter adapter;
    late VerificationRepositoryImpl repository;
    late ScriptedAnswer next;
    setUp(() {
      final session = FakeSessionService();
      adapter = ScriptedAdapter((_) async => next);
      final dio = Dio(DioFactory.options('https://example.test/v1/clients/x/'))
        ..httpClientAdapter = adapter;
      repository = VerificationRepositoryImpl(
        DioVerificationApiService(ApiClient(dio)),
        session,
      );
      addTearDown(repository.dispose);
      addTearDown(session.dispose);
    });

    test('TC-STG-036 a real scan: not found, its reference, the session '
        'totals and what is left', () async {
      next = stagingScripted('scan_first_200.json');
      final scan =
          (await repository.scan('Q8F2KD91XA7M', realSession)
                  as Success<ScanResult>)
              .value;
      expect(adapter.requests.single.data, {
        'way': 'qr',
        'value': 'Q8F2KD91XA7M',
        'session_id': realSession,
      });
      expect(scan.result.outcome, LookupOutcome.notFound);
      expect(scan.result.ref, 'MA-2026-000030');
      expect(scan.result.item, isNull);
      expect(scan.repeat, isFalse);
      expect(scan.session.scanned, 1);
      expect(scan.session.notFound, 1);
      expect(scan.session.left, 4999);

      next = stagingScripted('scan_repeat_200.json');
      final again =
          (await repository.scan('Q8F2KD91XA7M', realSession)
                  as Success<ScanResult>)
              .value;
      expect(again.repeat, isTrue);
      expect(again.result.ref, scan.result.ref, reason: "the first scan's");
      expect(again.session.scanned, 2, reason: 'QR B came between');
    });

    test('TC-STG-037 a real answer for another session is refused', () async {
      next = stagingScripted('scan_first_200.json');
      final result = await repository.scan(
        'Q8F2KD91XA7M',
        ActiveScanStore.newId(),
      );
      expect(
        (result as Err<ScanResult>).failure.exception,
        isA<InternalErrorException>().having(
          (e) => e.reason,
          'reason',
          VerificationReason.sessionMismatch,
        ),
      );
    });

    test(
      'TC-STG-038 the real 409 session_ended and 404 for a session',
      () async {
        next = stagingScripted('scan_session_ended_409.json');
        final ended = await repository.scan('Q8F2KD91XA7M', realSession);
        expect(
          (ended as Err<ScanResult>).failure.exception,
          isA<ScanSessionException>().having(
            (e) => e.code,
            'code',
            'session_ended',
          ),
        );
        next = stagingScripted('scan_session_unknown_404.json');
        final unknown = await repository.session(realSession);
        expect(
          (unknown as Err<ScanSessionSummary>).failure.exception,
          isA<NotFoundException>(),
        );
        for (final (name, status) in [
          ('scan_session_open_200.json', ScanStatus.open),
          ('scan_session_ended_200.json', ScanStatus.ended),
        ]) {
          next = stagingScripted(name);
          final summary =
              (await repository.session(realSession)
                      as Success<ScanSessionSummary>)
                  .value;
          expect(summary.kind, SessionKind.qr, reason: name);
          expect(summary.status, status, reason: name);
          expect(summary.totals.scanned, 2, reason: name);
        }
        next = stagingScripted('scan_end_200.json');
        expect(await repository.endSession(realSession), isA<Success<void>>());
      },
    );
  });

  testWidgets('TC-STG-036 Scanner mode on the real answers: two products, '
      'a repeat, Finish', (tester) async {
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {'POST lookups': realScans()},
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    app.scanner
      ..scan(a)
      ..scan(b);
    await settleScans(tester);
    app.scanner.scan(a);
    await settleScans(tester);

    final sent = app.backend.sent('POST', 'lookups');
    expect(sent, hasLength(3));
    final ids = {for (final r in sent) (r.data as Map)['session_id']};
    expect(ids, hasLength(1), reason: 'one session for all three');
    expect(find.byKey(const Key('session.repeat')), findsOneWidget);
    expect(find.bySemanticsLabel('Scanned: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Not found: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Remaining: 4998'), findsOneWidget);

    await app.tap(find.byKey(const Key('session.finish')));
    expect(find.text('2 products scanned'), findsOneWidget);
    for (final ref in ['MA-2026-000030', 'MA-2026-000031']) {
      expect(find.byKey(ValueKey('summary.$ref')), findsOneWidget);
    }
    final ended = [
      for (final r in app.backend.requests)
        if (r.method == 'POST' && r.path.endsWith('/end')) r.path,
    ];
    expect(ended, ['lookups/sessions/${ids.single}/end']);
  });

  testWidgets('TC-STG-038 the real session_ended: a new session, the scan '
      'sent again in it, nothing asked', (tester) async {
    final ended = <String>{};
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: {'POST lookups': realScans(ended: ended)},
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    // The session the scanner opened has ended on the server (15 minutes
    // without a scan).
    final store = ActiveScanStore(
      app.storage,
      client: testConfig.clientSlug,
      official: Roles.supervisor['id'] as String,
    );
    ended.add((await store.read())!);
    app.scanner.scan(a);
    await settleScans(tester);

    final sent = [
      for (final r in app.backend.sent('POST', 'lookups'))
        (r.data as Map)['session_id'] as String,
    ];
    expect(sent, hasLength(2));
    expect(sent.first, isNot(sent.last));
    expect(await store.read(), sent.last);
    await showRow(tester, 'MA-2026-000032');
    expect(find.byKey(const ValueKey('MA-2026-000032')), findsOneWidget);
    expect(find.bySemanticsLabel('Scanned: 1'), findsOneWidget);
    expect(find.byKey(const Key('session.restarted')), findsNothing);
    expect(find.byKey(const Key('session.scanAgain')), findsNothing);
    // TC-MIG-072 (UI audit 2026-11-22, 5.2): the list starts again, and the
    // screen says why and where the earlier products are.
    expect(
      find.text(
        'A new session started: the last one was full, or closed after 15 '
        'minutes without a scan. Its products are in History, then Sessions.',
      ),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  testWidgets('TC-MIG-072 the real session_ended without History: the '
      'notice does not point to it', (tester) async {
    final ended = <String>{};
    final app = await startApp(
      tester,
      profile: Roles.only(['item:bulk_lookup']),
      overrides: {'POST lookups': realScans(ended: ended)},
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    final store = ActiveScanStore(
      app.storage,
      client: testConfig.clientSlug,
      official: Roles.only(['item:bulk_lookup'])['id'] as String,
    );
    ended.add((await store.read())!);
    app.scanner.scan(a);
    await settleScans(tester);
    expect(
      find.text(
        'A new session started: the last one was full, or closed after 15 '
        'minutes without a scan.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('History'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  group('TC-STG-039 after a crash, the real saved session', () {
    Future<FlowApp> reopen(WidgetTester tester, String summary) async {
      final app = await startApp(
        tester,
        profile: Roles.supervisor,
        overrides: {
          'GET lookups/sessions/$realSession': (_) => stagingScripted(summary),
          'GET checks': (_) => stagingScripted('scan_session_checks_200.json'),
          'POST lookups': realScans(),
        },
      );
      await ActiveScanStore(
        app.storage,
        client: testConfig.clientSlug,
        official: Roles.supervisor['id'] as String,
      ).save(realSession);
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      return app;
    }

    testWidgets('open: its totals and its two scans come back', (
      tester,
    ) async {
      final app = await reopen(tester, 'scan_session_open_200.json');
      expect(
        app.backend.sent('GET', 'checks').last.queryParameters['session_id'],
        realSession,
      );
      expect(find.bySemanticsLabel('Scanned: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Not found: 2'), findsOneWidget);
      for (final ref in ['MA-2026-000031', 'MA-2026-000030']) {
        await showRow(tester, ref);
        expect(find.byKey(ValueKey(ref)), findsOneWidget, reason: ref);
      }
      app.scanner.scan(a);
      await settleScans(tester);
      expect(
        (app.backend.sent('POST', 'lookups').single.data as Map)['session_id'],
        realSession,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    });

    for (final (what, summary) in [
      ('ended', 'scan_session_ended_200.json'),
      ('not found (404)', 'scan_session_unknown_404.json'),
      // A serial stack, not a scanner session (guide §4.6).
      ('a serial stack', 'stack_session_200.json'),
    ]) {
      testWidgets('$what: a new session, nothing of the old one', (
        tester,
      ) async {
        final app = await reopen(tester, summary);
        expect(app.backend.sent('GET', 'checks'), isEmpty);
        expect(find.bySemanticsLabel('Scanned: 0'), findsOneWidget);
        expect(find.byKey(const ValueKey('MA-2026-000030')), findsNothing);
        app.scanner.scan(a);
        await settleScans(tester);
        expect(
          (app.backend.sent('POST', 'lookups').single.data
              as Map)['session_id'],
          isNot(realSession),
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      });
    }
  });
}
