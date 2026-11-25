import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/data/mappers/check_mappers.dart';
import 'package:ziska_verify/features/history/data/models/checks_page_dto.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';

import '../../fakes/postman_examples.dart';
import '../../fakes/scripted_adapter.dart';

/// `GET checks` against the backend's Postman examples
/// (final.md §10, §13.4, §18).
void main() {
  late ScriptedAdapter adapter;
  late DioHistoryApiService service;
  late ScriptedAnswer next;

  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    final dio = Dio(
      DioFactory.options('https://api.example.test/v1/clients/x/'),
    )..httpClientAdapter = adapter;
    service = DioHistoryApiService(ApiClient(dio));
  });

  ScriptedAnswer example(String name) => ScriptedAnswer(
    200,
    postmanExample(request: 'History of checks', example: name),
  );

  test('first page: checks, totals, and an opaque cursor', () async {
    next = example('200 First page');
    final page = (await service.getChecks(
      const CheckQuery(),
      const PageRequest(),
    )).toEntity();

    final check = page.page.items.single;
    expect(check.ref, 'MA-2026-000124');
    expect(check.way, CheckWay.qr);
    expect(check.result, CheckResult.warning);
    expect(check.reasons, [CheckReason.checkedBefore]);
    expect(check.at, DateTime.utc(2026, 10, 28, 10, 2, 11));
    expect(page.totals!.total, 120);
    expect(page.page.nextCursor, '3255');
    expect(adapter.requests.single.queryParameters, {'limit': 50});
  });

  test('a later page: no totals, the end', () async {
    next = example('200 A later page');
    final page = (await service.getChecks(
      const CheckQuery(),
      const PageRequest(cursor: '3255'),
    )).toEntity();
    expect(page.page.items, isEmpty);
    expect(page.totals, isNull);
    expect(page.page.hasMore, isFalse);
    expect(adapter.requests.single.queryParameters['cursor'], '3255');
  });

  group('query parameters (final.md Section 10.2)', () {
    test('empty filters are not sent; scope only when all', () {
      expect(
        DioHistoryApiService.checksQuery(
          const CheckQuery(search: '  '),
          const PageRequest(),
        )..removeWhere((_, v) => v == null),
        {'limit': 50},
      );
    });

    test('every filter in the API form', () {
      final q = DioHistoryApiService.checksQuery(
        CheckQuery(
          result: CheckResult.notFound,
          way: CheckWay.hiddenCode,
          from: DateTime(2026, 10, 2),
          to: DateTime(2026, 10, 28),
          search: '1000001',
          sessionId: 'session-1',
        ),
        const PageRequest(cursor: 'x'),
      );
      expect(q, {
        'limit': 50,
        'cursor': 'x',
        'result': 'not_found',
        'way': 'hidden_code',
        'from': '2026-10-02',
        'to': '2026-10-28',
        'search': '1000001',
        'session_id': 'session-1',
      });
    });
  });

  // docs/test-cases/06-history.md: query edge cases.
  group('query edge cases', () {
    Map<String, Object?> sent(
      CheckQuery q, [
      PageRequest p = const PageRequest(),
    ]) =>
        DioHistoryApiService.checksQuery(q, p)
          ..removeWhere((_, v) => v == null);

    test('TC-HIST-016 a one-day range sends the same day twice', () {
      final day = DateTime(2026, 10, 28);
      expect(sent(CheckQuery(from: day, to: day)), {
        'limit': 50,
        'from': '2026-10-28',
        'to': '2026-10-28',
      });
    });

    test('TC-HIST-017 dates are YYYY-MM-DD with leading zeros', () {
      final q = sent(
        CheckQuery(from: DateTime(2026, 1, 2), to: DateTime(2026, 10, 28)),
      );
      expect(q['from'], '2026-01-02');
      expect(q['to'], '2026-10-28');
    });

    test('TC-HIST-019 no filter: limit only, no empty parameter', () {
      expect(sent(const CheckQuery()), {'limit': 50});
      // The default spelled out: own scope is never sent.
      // ignore: avoid_redundant_argument_values
      expect(sent(const CheckQuery(sessionId: null)), {'limit': 50});
    });

    test('TC-HIST-020 every result filter in the API form', () {
      for (final (r, wire) in [
        (CheckResult.valid, 'valid'),
        (CheckResult.warning, 'warning'),
        (CheckResult.notFound, 'not_found'),
        (CheckResult.unassigned, 'unassigned'),
      ]) {
        expect(sent(CheckQuery(result: r))['result'], wire);
      }
    });

    test('TC-HIST-021 every way filter in the API form', () {
      for (final (w, wire) in [
        (CheckWay.serial, 'serial'),
        (CheckWay.qr, 'qr'),
        (CheckWay.hiddenCode, 'hidden_code'),
      ]) {
        expect(sent(CheckQuery(way: w))['way'], wire);
      }
    });

    test('TC-HIST-022 filters combined in one request', () {
      expect(
        sent(
          CheckQuery(
            result: CheckResult.warning,
            way: CheckWay.qr,
            from: DateTime(2026, 10),
            to: DateTime(2026, 10, 28),
            search: '1000001',
          ),
        ),
        {
          'limit': 50,
          'result': 'warning',
          'way': 'qr',
          'from': '2026-10-01',
          'to': '2026-10-28',
          'search': '1000001',
        },
      );
    });

    test('TC-HIST-024 a reference number is sent as the search', () {
      expect(
        sent(const CheckQuery(search: 'MA-2026-000123'))['search'],
        'MA-2026-000123',
      );
    });

    test('TC-HIST-027 a search with symbols stays one encoded value', () async {
      next = example('200 A later page');
      await service.getChecks(
        const CheckQuery(search: '1000&scope=all'),
        const PageRequest(),
      );
      final request = adapter.requests.single;
      expect(request.queryParameters['search'], '1000&scope=all');
      expect(request.queryParameters.containsKey('scope'), isFalse);
      expect(request.uri.query, contains('search=1000%26scope%3Dall'));
      expect(request.uri.queryParameters.containsKey('scope'), isFalse);
    });

    test('TC-HIST-028 a cleared search is not sent', () {
      expect(sent(const CheckQuery(search: '')).containsKey('search'), isFalse);
      expect(sent(const CheckQuery()).containsKey('search'), isFalse);
    });

    test('TC-HIST-030 a numeric-looking cursor stays text', () async {
      next = ScriptedAnswer(
        200,
        okBody({'checks': <Object?>[], 'totals': null, 'next_cursor': '0032'}),
      );
      final page = (await service.getChecks(
        const CheckQuery(),
        const PageRequest(),
      )).toEntity();
      expect(page.page.nextCursor, '0032');

      next = example('200 A later page');
      await service.getChecks(
        const CheckQuery(),
        const PageRequest(cursor: '0032'),
      );
      expect(adapter.requests.last.uri.query, contains('cursor=0032'));
    });

    test('TC-HIST-039 rows without serial, product, or batch', () {
      final notFound = CheckDto.fromJson({
        'ref': 'MA-2026-000200',
        'at': '2026-10-28T10:02:11Z',
        'way': 'serial',
        'result': 'not_found',
        'reasons': <String>[],
        'serial': null,
        'product': null,
        'batch': null,
        'official': 'Asha Rao',
      }).toEntity();
      expect(notFound.serial, isNull);
      expect(notFound.product, isNull);
      expect(notFound.result, CheckResult.notFound);
    });
  });

  test('an unknown result is never valid', () {
    final record = CheckDto.fromJson({
      'ref': 'R',
      'at': '2026-10-28T10:02:11Z',
      'way': 'qr',
      'result': 'counterfeit',
      'official': 'A',
    }).toEntity();
    expect(record.result, CheckResult.unknown);
  });
}
