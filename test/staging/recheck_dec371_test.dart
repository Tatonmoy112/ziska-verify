import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';

import '../fakes/fake_session_service.dart';
import '../fakes/scripted_adapter.dart';
import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// The recheck against the backend plan `ProtectB-DOCS` at 5d96a91
/// (docs/staging-integration-2026-11-22.md): DEC-371 says every serial
/// "accepts leading zeros and is read without them", up to 40 characters.
/// The server's real answers, replayed offline (TC-STG-055 … -057).
void main() {
  final padded20 = '${'0' * 19}1';

  testWidgets('TC-STG-055 serial 1 typed with 19 zeros: sent as typed, the '
      "server's item 1 shown", (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST lookups': (_) =>
            stagingScripted('lookup_serial_padded20_200.json'),
      },
    );
    await app.enter(const Key('verify.input'), padded20);
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(
      (app.backend.sent('POST', 'lookups').single.data as Map)['value'],
      padded20,
    );
    expect(find.text('MA-2026-000035'), findsWidgets);
  });

  group('the repository on the real answers', () {
    late VerificationRepositoryImpl repository;
    late ScriptedAnswer next;
    setUp(() {
      final session = FakeSessionService();
      final dio = Dio(DioFactory.options('https://example.test/v1/clients/x/'))
        ..httpClientAdapter = ScriptedAdapter((_) async => next);
      repository = VerificationRepositoryImpl(
        DioVerificationApiService(ApiClient(dio)),
        session,
      );
      addTearDown(repository.dispose);
      addTearDown(session.dispose);
    });

    test('TC-STG-056 serial 0 and serial 1 padded to 41 characters are '
        'not found, never refused', () async {
      for (final (fixture, value) in [
        ('lookup_serial_zero_200.json', '0'),
        ('lookup_serial_padded41_200.json', '${'0' * 40}1'),
      ]) {
        next = stagingScripted(fixture);
        final result =
            await repository.lookup(LookupWay.serial, value)
                as Success<LookupResult>;
        expect(result.value.outcome, LookupOutcome.notFound, reason: fixture);
      }
    });

    test('TC-STG-057 a stack with 0 and a padded serial: every row '
        'shown', () async {
      next = stagingScripted('stack_with_zero_200.json');
      final withZero =
          await repository.serials(['1000001', '0'])
              as Success<SerialStackResult>;
      expect(withZero.value.items.map((r) => r.serial), ['1000001', '0']);
      expect(withZero.value.items.last.result.outcome, LookupOutcome.notFound);

      next = stagingScripted('stack_padded20_200.json');
      final padded =
          await repository.serials([padded20]) as Success<SerialStackResult>;
      expect(padded.value.items.single.serial, padded20);
      expect(
        padded.value.items.single.result.outcome,
        LookupOutcome.warning,
      );
    });
  });
}
