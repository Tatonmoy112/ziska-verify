import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

import '../../../fakes/postman_examples.dart';
import '../../../fakes/scripted_adapter.dart';

/// API contract tests on the backend's Postman examples
/// (final.md Section 18.2).
void main() {
  late ScriptedAdapter adapter;
  late DioVerificationApiService service;
  late ScriptedAnswer next;

  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    final dio = Dio(
      DioFactory.options('https://api.example.test/v1/clients/x/'),
    )..httpClientAdapter = adapter;
    service = DioVerificationApiService(ApiClient(dio));
  });

  ScriptedAnswer example(int status, String request, String name) =>
      ScriptedAnswer(status, postmanExample(request: request, example: name));

  Future<LookupResult> lookup(String name) async {
    next = example(200, 'Look up one item', name);
    return (await service.lookup(way: 'qr', value: 'Q8F2KD91XA7M')).toEntity();
  }

  test('GET formats', () async {
    next = example(200, 'Input formats', '200 The formats');
    final formats = (await service.getFormats()).toEntity();
    expect(formats.hiddenCodes.single.length, 12);
    expect(formats.serialMaxDigits, 19);
    expect(formats.qr.length, 12);
  });

  test('POST lookups sends way and value', () async {
    await lookup('200 valid: genuine, first check');
    expect(adapter.requests.single.path, 'lookups');
    expect(adapter.requests.single.data, {
      'way': 'qr',
      'value': 'Q8F2KD91XA7M',
    });
  });

  test('valid: first check, item details, no reasons', () async {
    final r = await lookup('200 valid: genuine, first check');
    expect(r.outcome, LookupOutcome.valid);
    expect(r.ref, 'MA-2026-000123');
    expect(r.reasons, isEmpty);
    expect(r.count!.thisCheck, 1);
    expect(r.count!.lastAt, isNull);
    expect(r.item!.maskedCode, '*****7K2');
    expect(r.item!.batch.expires, DateTime(2027, 9, 30));
  });

  test('warning: every reason, count, and last time', () async {
    final r = await lookup('200 warning: checked before and expired');
    expect(r.outcome, LookupOutcome.warning);
    expect(r.reasons, [LookupReason.checkedBefore, LookupReason.expired]);
    expect(r.count!.thisCheck, 3);
    expect(r.count!.lastAt, DateTime.utc(2026, 10, 12, 9, 14));
  });

  test('not_found and unassigned carry only ref', () async {
    for (final (name, outcome) in [
      ('200 not_found', LookupOutcome.notFound),
      ('200 unassigned', LookupOutcome.unassigned),
    ]) {
      final r = await lookup(name);
      expect(r.outcome, outcome);
      expect(r.ref, isNotEmpty);
      expect(r.item, isNull);
      expect(r.count, isNull);
    }
  });

  test('503 app_preparing is its own error', () async {
    next = example(
      503,
      'Look up one item',
      "503 The client's app is being prepared",
    );
    await expectLater(
      service.lookup(way: 'serial', value: '1'),
      throwsA(isA<AppPreparingException>()),
    );
  });

  group('fail-safe (final.md Section 13.1.5)', () {
    test('an unknown result is never valid', () {
      const dto = LookupResultDto(ref: 'R', result: 'counterfeit');
      expect(dto.toEntity().outcome, LookupOutcome.unknown);
    });

    test('an unknown reason becomes a generic warning', () {
      const dto = LookupResultDto(
        ref: 'R',
        result: 'warning',
        reasons: ['stolen'],
      );
      expect(dto.toEntity().reasons, [LookupReason.unknown]);
    });

    test('unknown fields are ignored', () {
      final dto = LookupResultDto.fromJson({
        'ref': 'R',
        'result': 'not_found',
        'new_field': {'x': 1},
      });
      expect(dto.toEntity().outcome, LookupOutcome.notFound);
    });
  });
}
