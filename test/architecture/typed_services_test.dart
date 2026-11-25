import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';

import '../fakes/postman_examples.dart';
import '../fakes/scripted_adapter.dart';

/// TC-ARCH-038 … -040 (docs/test-cases/18-architecture.md): every API
/// service takes typed values, builds its body, and returns a DTO; no
/// repository builds a body or reads JSON (production audit P-31).
void main() {
  late ScriptedAnswer next;
  late ScriptedAdapter adapter;
  late ApiClient api;
  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    api = ApiClient(
      Dio(DioFactory.options('https://example.test/v1/clients/x/'))
        ..httpClientAdapter = adapter,
    );
  });
  ScriptedAnswer example(String request, String name) =>
      ScriptedAnswer(200, postmanExample(request: request, example: name));

  group('TC-ARCH-038 normal: typed in, DTO out', () {
    test('a report: the documented body, built by the service', () async {
      next = ScriptedAnswer(201, okBody({'id': 1042}));
      final id = await DioIncidentApiService(api).fileReport(
        note: 'Seal is cut',
        checkRef: 'MA-2026-000123',
        retailUserId: 'r1',
      );
      expect(id, 1042);
      expect(adapter.requests.single.data, {
        'note': 'Seal is cut',
        'check_ref': 'MA-2026-000123',
        'retail_user_id': 'r1',
      });
    });

    test('a scan: the totals and the lookup, in one DTO', () async {
      next = example(
        '1. A scan in the session',
        '200 first scan of an item: warning',
      );
      final scan = await DioVerificationApiService(
        api,
      ).scan('Q8F2KD91XA7M', 'S-1');
      expect(scan.session.scanned, greaterThan(0));
      expect(scan.result.result, 'warning');
    });

    test('a serial stack: each row with its lookup', () async {
      next = example('A stack of serials', '200 Three serials, one sent twice');
      final stack = await DioVerificationApiService(
        api,
      ).serials(['1000001', '1000002', '1000003']);
      expect(stack.items.map((i) => i.serial), [
        '1000001',
        '1000002',
        '1000003',
      ]);
      expect(stack.items.every((i) => i.result.result.isNotEmpty), isTrue);
    });
  });

  group('TC-ARCH-039 edge: optional parts', () {
    test('a report with no link sends the note only', () async {
      next = ScriptedAnswer(201, okBody({'id': 7}));
      await DioIncidentApiService(api).fileReport(note: 'n');
      expect(adapter.requests.single.data, {'note': 'n'});
    });

    test('a row not found has no item', () async {
      next = example('1. A scan in the session', '200 not_found');
      final scan = await DioVerificationApiService(api).scan('x', 'S-1');
      expect(scan.result.result, 'not_found');
      expect(scan.result.item, isNull);
    });
  });

  group('TC-ARCH-040 worst: no raw JSON past a service', () {
    List<(String, String)> sources(String layer) => [
      for (final file in Directory('lib/features').listSync(recursive: true))
        if (file is File &&
            file.path.replaceAll(r'\', '/').contains('/data/$layer/') &&
            !file.path.endsWith('.g.dart'))
          (file.path, file.readAsStringSync()),
    ];

    test('no service returns a raw map or takes a raw body', () {
      final raw = RegExp(
        r'Future<Map<String, dynamic>>|\(Map<String, Object\?> body\)',
      );
      for (final (path, source) in sources('services')) {
        expect(source, isNot(matches(raw)), reason: path);
      }
    });

    test('no repository reads JSON or builds a body', () {
      final json = RegExp(r"\.fromJson\(|data\['|'[a-z_]+': \?");
      for (final (path, source) in sources('repositories')) {
        expect(source, isNot(matches(json)), reason: path);
      }
    });
  });
}
