import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import '../../../fakes/fake_session_service.dart';
import '../../../fakes/postman_examples.dart';
import '../../../fakes/scripted_adapter.dart';
import '../../../fakes/staging_fixtures.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);
  late ScriptedAdapter adapter;
  late VerificationRepositoryImpl repository;
  late ScriptedAnswer next;
  const id = '7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33';
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
  ScriptedAnswer example(String request, String name, [int status = 200]) =>
      ScriptedAnswer(status, postmanExample(request: request, example: name));

  for (final name in [
    '200 first scan of an item: warning',
    '200 the same QR again in the session (repeat)',
    '200 not_found',
  ]) {
    test('scan contract: $name', () async {
      next = example('1. A scan in the session', name);
      final result = await repository.scan('Q8F2KD91XA7M', id);
      expect(result, isA<Success<ScanResult>>());
      final scan = (result as Success<ScanResult>).value;
      expect(scan.session.id, id);
      expect(scan.repeat, name.contains('(repeat)'));
      expect(scan.result.ref, isNotEmpty);
      expect(adapter.requests.single.data, {
        'way': 'qr',
        'value': 'Q8F2KD91XA7M',
        'session_id': id,
      });
    });
  }
  for (final code in ['session_full', 'session_ended', 'session_not_yours']) {
    test('typed session conflict: $code', () async {
      next = ScriptedAnswer(409, errorBody(code));
      final result =
          await repository.scan('Q8F2KD91XA7M', id) as Err<ScanResult>;
      expect(result.failure.exception, isA<ScanSessionException>());
      expect(result.failure.exception.code, code);
      expect(result.failure.requestId, 'req-1');
    });
  }
  test('a scan with another session ID fails closed', () async {
    next = example('1. A scan in the session', '200 not_found');
    expect(
      await repository.scan('Q8F2KD91XA7M', 'other'),
      isA<Err<ScanResult>>(),
    );
  });
  test(
    'serial stacks send only serials, deduplicate and map by serial',
    () async {
      next = example('A stack of serials', '200 Three serials, one sent twice');
      final result =
          await repository.serials(['1000001', '1000002', '1000001', '1000003'])
              as Success<SerialStackResult>;
      expect(result.value.items.map((r) => r.serial), [
        '1000001',
        '1000002',
        '1000003',
      ]);
      expect(result.value.items.last.result.item, isNull);
      expect(result.value.session.scanned, 3);
      expect(adapter.requests.single.path, 'lookups/serials');
      expect(adapter.requests.single.data, {
        'serials': ['1000001', '1000002', '1000003'],
      });
    },
  );
  test('empty and oversized stacks never leave the repository', () async {
    expect(await repository.serials([]), isA<Err<SerialStackResult>>());
    expect(
      await repository.serials([for (var i = 0; i < 51; i++) '$i']),
      isA<Err<SerialStackResult>>(),
    );
    expect(adapter.requests, isEmpty);
  });
  // TC-MIG-060 (test-server integration, step 6): the guide answers each
  // row with "the serial as sent". The test server compares serials as
  // numbers (backend question B5). Should it answer 001 as 1, or merge 001
  // and 1 into one row, the rows no longer match what was sent: the stack
  // was recorded (a 200), so it counts as recorded and is never sent again.
  group('TC-MIG-060 leading zeros in a stack', () {
    Map<String, Object?> row(String serial, String ref) => {
      'serial': serial,
      'ref': ref,
      'result': 'not_found',
    };
    ScriptedAnswer answer(List<Map<String, Object?>> items) => ScriptedAnswer(
      200,
      okBody({
        'session': {
          'id': id,
          'kind': 'serial',
          'scanned': items.length,
          'valid': 0,
          'warning': 0,
          'not_found': items.length,
          'unassigned': 0,
        },
        'items': items,
      }),
    );

    Future<void> expectRecorded(List<String> sent) async {
      final result = await repository.serials(sent) as Err<SerialStackResult>;
      expect(
        result.failure.exception,
        isA<InternalErrorException>().having(
          (e) => e.reason,
          'reason',
          VerificationReason.serialStackMismatch,
        ),
      );
    }

    test('the serials go as typed, zeros kept', () async {
      next = answer([row('001', 'R1'), row('2', 'R2')]);
      final result = await repository.serials(['001', '2']);
      expect(adapter.requests.single.data, {
        'serials': ['001', '2'],
      });
      expect(result, isA<Success<SerialStackResult>>());
    });

    test('001 answered as 1: recorded, not shown', () async {
      next = answer([row('1', 'R1'), row('2', 'R2')]);
      await expectRecorded(['001', '2']);
    });

    test('001 and 1 merged into one row: recorded, not shown', () async {
      next = answer([row('1', 'R1')]);
      await expectRecorded(['001', '1']);
    });
  });

  test("TC-MIG-061 001 and 1 go as one serial; the server's real answer "
      '(one row, 001) is shown', () async {
    next = stagingScripted('stack_leading_zeros_200.json');
    final result = await repository.serials(['001', '1']);
    expect(adapter.requests.single.data, {
      'serials': ['001'],
    });
    final stack = (result as Success<SerialStackResult>).value;
    expect(stack.items.single.serial, '001');
    expect(stack.items.single.result.outcome, LookupOutcome.warning);
  });

  test('reordered or missing stack results are rejected', () async {
    next = example('A stack of serials', '200 Three serials, one sent twice');
    expect(
      await repository.serials(['1000003', '1000002', '1000001']),
      isA<Err<SerialStackResult>>(),
    );
    expect(
      await repository.serials(['1000001']),
      isA<Err<SerialStackResult>>(),
    );
  });
  // TC-MIG-056 (audit 2026-11-19): a 200 means the stack was recorded
  // (guide section 4.7), so an answer that cannot be read is "recorded",
  // never an error that lets the same stack go again.
  group('TC-MIG-056 a 200 that cannot be read is recorded', () {
    Map<String, dynamic> stack() => postmanExample(
      request: 'A stack of serials',
      example: '200 Three serials, one sent twice',
    );
    const serials = ['1000001', '1000002', '1000003'];

    Future<void> expectRecorded() async {
      final result =
          await repository.serials(serials) as Err<SerialStackResult>;
      expect(
        result.failure.exception,
        isA<InternalErrorException>().having(
          (e) => e.reason,
          'reason',
          VerificationReason.serialStackMismatch,
        ),
      );
    }

    test('a field of the wrong type', () async {
      final body = stack();
      (((body['data'] as Map)['items'] as List).first as Map)['result'] = 7;
      next = ScriptedAnswer(200, body);
      await expectRecorded();
    });

    test('no items list', () async {
      final body = stack();
      (body['data'] as Map).remove('items');
      next = ScriptedAnswer(200, body);
      await expectRecorded();
    });

    test('data that is not an object', () async {
      next = const ScriptedAnswer(200, {
        'success': true,
        'message': 'ok',
        'data': 'done',
      });
      await expectRecorded();
    });

    test('a 200 that is not the envelope', () async {
      next = const ScriptedAnswer.raw(200, '<html>ok</html>');
      await expectRecorded();
    });

    test('a non-200 page is not recorded', () async {
      next = const ScriptedAnswer.raw(502, '<html>Bad gateway</html>');
      final result =
          await repository.serials(serials) as Err<SerialStackResult>;
      expect(
        result.failure.exception.reason,
        isNot(VerificationReason.serialStackMismatch),
      );
    });
  });
  test('session list accepts kind and sends only documented filters', () async {
    next = example('3. My sessions', '200 Sessions');
    final result = await repository.sessions(
      SessionQuery(
        status: ScanStatus.ended,
        from: DateTime(2026, 11),
        to: DateTime(2026, 11, 16),
      ),
      const PageRequest(cursor: 'opaque'),
    );
    expect(result, isA<Success<Object>>());
    expect(adapter.requests.single.queryParameters, {
      'limit': 50,
      'cursor': 'opaque',
      'status': 'ended',
      // The UTC days the Bangladesh days overlap (TC-HIST-051).
      'from': '2026-10-31',
      'to': '2026-11-16',
    });
  });
  test('session detail and end have no scope or body', () async {
    next = example('4. One session', '200 Session');
    final result = await repository.session(id) as Success<ScanSessionSummary>;
    expect(result.value.kind, SessionKind.qr);
    next = ScriptedAnswer(200, okBody(null));
    await repository.endSession(id);
    expect(adapter.requests.last.path, 'lookups/sessions/$id/end');
    expect(adapter.requests.last.data, isNull);
  });
  test('unknown additive fields do not break stack responses', () async {
    final body = postmanExample(
      request: 'A stack of serials',
      example: '200 Three serials, one sent twice',
    );
    (body['data'] as Map)['future_field'] = true;
    next = ScriptedAnswer(200, body);
    expect(
      await repository.serials(['1000001', '1000002', '1000003']),
      isA<Success<SerialStackResult>>(),
    );
  });
}
