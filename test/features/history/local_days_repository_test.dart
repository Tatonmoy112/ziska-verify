import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/data/repositories/history_repository_impl.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

import '../../fakes/fake_session_service.dart';
import '../../fakes/scripted_adapter.dart';

/// TC-HIST-051 and TC-HIST-053: `from`/`to` are whole UTC days (guide §4.5,
/// §5). A Bangladesh day is asked as the UTC days it overlaps; only the rows
/// inside it are kept; the server's totals count UTC days, so none are
/// given. Rows come newest first, so the list ends at the first day.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  final day = DateTime(2026, 11, 23);

  Map<String, Object?> check(String ref, String at) => {
    'ref': ref,
    'at': at,
    'way': 'serial',
    'result': 'not_found',
    'reasons': <String>[],
    'serial': null,
    'product': null,
    'batch': null,
    'official': 'Test Official',
    'session_id': null,
  };

  const totals = {
    'total': 9,
    'valid': 0,
    'warning': 0,
    'not_found': 9,
    'unassigned': 0,
  };

  ScriptedAnswer checksPage(
    List<Map<String, Object?>> checks, {
    String? next,
    bool withTotals = true,
  }) => ScriptedAnswer(
    200,
    okBody({
      'checks': checks,
      'totals': withTotals ? totals : null,
      'next_cursor': next,
    }),
  );

  late ScriptedAdapter adapter;
  late Map<String?, ScriptedAnswer> byCursor;
  late ApiClient api;
  setUp(() {
    adapter = ScriptedAdapter(
      (r) async => byCursor[r.queryParameters['cursor'] as String?]!,
    );
    api = ApiClient(
      Dio(DioFactory.options('https://example.test/v1/clients/x/'))
        ..httpClientAdapter = adapter,
    );
  });

  group('History', () {
    late HistoryRepositoryImpl repository;
    setUp(() => repository = HistoryRepositoryImpl(DioHistoryApiService(api)));

    Future<CheckPage> dated() async =>
        (await repository.getChecks(
                  CheckQuery(from: day, to: day),
                  const PageRequest(),
                )
                as Success<CheckPage>)
            .value;

    test('one Bangladesh day: the UTC days it overlaps are asked, and only '
        'its checks are kept', () async {
      byCursor = {
        null: checksPage([
          // 01:00 on the 24th in Dhaka: after the day.
          check('LATE', '2026-11-23T19:00:00+00:00'),
          // 23:30 on the 23rd in Dhaka.
          check('KEEP-1', '2026-11-23T17:30:00+00:00'),
          // 00:30 on the 23rd in Dhaka (the 22nd in UTC).
          check('KEEP-2', '2026-11-22T18:30:00+00:00'),
          // 23:00 on the 22nd in Dhaka: before the day.
          check('EARLY', '2026-11-22T17:00:00+00:00'),
        ]),
      };
      final page = await dated();
      final sent = adapter.requests.single.queryParameters;
      expect(sent['from'], '2026-11-22');
      expect(sent['to'], '2026-11-23');
      expect(page.page.items.map((c) => c.ref), ['KEEP-1', 'KEEP-2']);
      expect(page.totals, isNull, reason: 'the totals count UTC days');
      expect(page.page.nextCursor, isNull);
    });

    test('a page that keeps nothing loads the next one by itself', () async {
      byCursor = {
        null: checksPage([
          check('LATE', '2026-11-23T20:00:00+00:00'),
        ], next: 'c1'),
        'c1': checksPage(
          [check('KEEP', '2026-11-23T10:00:00+00:00')],
          next: 'c2',
          withTotals: false,
        ),
      };
      final page = await dated();
      expect(adapter.requests, hasLength(2));
      expect(page.page.items.single.ref, 'KEEP');
      expect(page.page.nextCursor, 'c2');
    });

    test('TC-HIST-053 a check before the first day ends the list: no more '
        'pages', () async {
      byCursor = {
        null: checksPage([
          check('KEEP', '2026-11-23T10:00:00+00:00'),
          check('EARLY', '2026-11-22T17:00:00+00:00'),
        ], next: 'c1'),
      };
      final page = await dated();
      expect(adapter.requests, hasLength(1));
      expect(page.page.items.map((c) => c.ref), ['KEEP']);
      expect(page.page.nextCursor, isNull);
    });

    test('TC-HIST-053 many pages after the last day are read through, not '
        'shown as a blank page', () async {
      byCursor = {
        for (var i = 0; i < 12; i++)
          i == 0 ? null : 'c$i': checksPage(
            [check('LATE-$i', '2026-11-23T20:00:00+00:00')],
            next: 'c${i + 1}',
            withTotals: false,
          ),
        'c12': checksPage(
          [check('KEEP', '2026-11-23T10:00:00+00:00')],
          next: 'c13',
          withTotals: false,
        ),
      };
      final page = await dated();
      expect(adapter.requests, hasLength(13));
      expect(page.page.items.single.ref, 'KEEP');
      expect(page.page.nextCursor, 'c13');
    });

    test('without dates nothing changes: the query as typed and the server '
        'totals', () async {
      byCursor = {
        null: checksPage([check('A', '2026-11-23T19:00:00+00:00')]),
      };
      final result =
          await repository.getChecks(const CheckQuery(), const PageRequest())
              as Success<CheckPage>;
      expect(
        adapter.requests.single.queryParameters.containsKey('from'),
        isFalse,
      );
      expect(result.value.page.items.single.ref, 'A');
      expect(result.value.totals?.total, 9);
    });
  });

  group('Sessions', () {
    late VerificationRepositoryImpl repository;
    setUp(() {
      final session = FakeSessionService();
      repository = VerificationRepositoryImpl(
        DioVerificationApiService(api),
        session,
      );
      addTearDown(repository.dispose);
      addTearDown(session.dispose);
    });

    Map<String, Object?> session(
      String id,
      String startedAt, [
      String? lastScanAt,
    ]) => {
      'id': id,
      'kind': 'qr',
      'status': 'ended',
      'started_at': startedAt,
      'last_scan_at': lastScanAt ?? startedAt,
      'scanned': 1,
      'valid': 0,
      'warning': 0,
      'not_found': 1,
      'unassigned': 0,
      'official': 'Test Official',
    };

    ScriptedAnswer sessionsPage(
      List<Map<String, Object?>> sessions, {
      String? next,
    }) => ScriptedAnswer(
      200,
      okBody({'sessions': sessions, 'next_cursor': next}),
    );

    Future<CursorPage<ScanSessionSummary>> dated() async =>
        (await repository.sessions(
                  SessionQuery(from: day, to: day),
                  const PageRequest(),
                )
                as Success<CursorPage<ScanSessionSummary>>)
            .value;

    test('sessions of a Bangladesh day, by when they started', () async {
      byCursor = {
        null: sessionsPage([
          session(
            '11111111-1111-4111-8111-111111111111',
            '2026-11-23T19:00:00+00:00',
          ),
          session(
            '22222222-2222-4222-8222-222222222222',
            '2026-11-22T18:30:00+00:00',
          ),
          session(
            '33333333-3333-4333-8333-333333333333',
            '2026-11-22T12:00:00+00:00',
          ),
        ]),
      };
      final page = await dated();
      final sent = adapter.requests.single.queryParameters;
      expect(sent['from'], '2026-11-22');
      expect(sent['to'], '2026-11-23');
      expect(page.items.map((s) => s.totals.id), [
        '22222222-2222-4222-8222-222222222222',
      ]);
    });

    test('TC-HIST-053 a session whose last scan is before the first day '
        'ends the list', () async {
      byCursor = {
        null: sessionsPage([
          session(
            '22222222-2222-4222-8222-222222222222',
            '2026-11-23T05:00:00+00:00',
          ),
          session(
            '33333333-3333-4333-8333-333333333333',
            '2026-11-22T10:00:00+00:00',
          ),
        ], next: 'c1'),
      };
      final page = await dated();
      expect(adapter.requests, hasLength(1));
      expect(page.nextCursor, isNull);
    });

    test('a session started before the day but scanned in it is not kept, '
        'and the list goes on', () async {
      byCursor = {
        null: sessionsPage([
          session(
            '44444444-4444-4444-8444-444444444444',
            '2026-11-22T17:50:00+00:00',
            '2026-11-22T18:10:00+00:00',
          ),
        ], next: 'c1'),
        'c1': sessionsPage([]),
      };
      final page = await dated();
      expect(page.items, isEmpty);
      expect(adapter.requests, hasLength(2));
    });
  });
}
