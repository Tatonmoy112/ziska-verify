import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

import '../../../fakes/fake_session_service.dart';
import '../../../fakes/postman_examples.dart';
import '../../../fakes/scripted_adapter.dart';

/// Bulk lookup against the backend's Postman examples
/// (final.md Sections 13.2, 18.2).
void main() {
  late ScriptedAdapter adapter;
  late VerificationRepositoryImpl repository;
  late ScriptedAnswer next;

  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    final dio = Dio(
      DioFactory.options('https://api.example.test/v1/clients/x/'),
    )..httpClientAdapter = adapter;
    repository = VerificationRepositoryImpl(
      DioVerificationApiService(ApiClient(dio)),
      FakeSessionService(const SessionAuthenticated()),
    );
  });

  ScriptedAnswer example(
    int status,
    String name, {
    Map<String, List<String>> headers = const {},
  }) => ScriptedAnswer(
    status,
    postmanExample(request: 'Look up many items (bulk)', example: name),
    headers: headers,
  );

  const three = [
    BulkEntry(id: 0, way: LookupWay.serial, value: '1000001'),
    BulkEntry(id: 1, way: LookupWay.qr, value: 'Q8F2KD91XA7M'),
    BulkEntry(id: 2, way: LookupWay.hiddenCode, value: '481516234200'),
  ];

  test('sends the items in order and matches results by position', () async {
    next = example(200, '200 Three items');

    final result = await repository.bulkLookup(three);
    final outcome = (result as Success<BulkOutcome>).value;

    expect(adapter.requests.single.path, 'lookups/bulk');
    expect(adapter.requests.single.data, {
      'items': [
        {'way': 'serial', 'value': '1000001'},
        {'way': 'qr', 'value': 'Q8F2KD91XA7M'},
        {'way': 'hidden_code', 'value': '481516234200'},
      ],
    });
    expect(outcome.summary.total, 3);
    expect(outcome.summary.byReason[LookupReason.checkedBefore], 1);
    expect(outcome.rows.map((r) => r.result.outcome), [
      LookupOutcome.valid,
      LookupOutcome.warning,
      LookupOutcome.notFound,
    ]);
    expect(outcome.rows.map((r) => r.label), [
      '1000001',
      'Q8F2KD91XA7M',
      '*****200',
    ]);
    // Every item is its own check with its own reference.
    expect(outcome.rows.map((r) => r.result.ref).toSet(), hasLength(3));
  });

  test('a different number of results is never shown', () async {
    next = example(200, '200 Three items');
    final result = await repository.bulkLookup(three.take(2).toList());
    expect(
      (result as Err<BulkOutcome>).failure.exception,
      isA<InternalErrorException>(),
    );
  });

  test('429 carries Retry-After', () async {
    next = example(
      429,
      '429 Over 3,000 items a minute',
      headers: {
        'retry-after': ['42'],
      },
    );
    final result = await repository.bulkLookup(three);
    expect(
      (result as Err<BulkOutcome>).failure.retryAfter,
      const Duration(seconds: 42),
    );
  });

  test('503 is service unavailable', () async {
    next = example(503, '503 Our service is busy or a part is down');
    final result = await repository.bulkLookup(three);
    expect(
      (result as Err<BulkOutcome>).failure.exception,
      isA<ServiceUnavailableException>(),
    );
  });
}
