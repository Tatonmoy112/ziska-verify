import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import '../../../fakes/fake_session_service.dart';
import '../../../fakes/postman_examples.dart';
import '../../../fakes/scripted_adapter.dart';

void main() {
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
      'from': '2026-11-01',
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
