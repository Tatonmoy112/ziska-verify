import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 4 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): one check, on the server's real answers replayed
/// offline through the whole app (TC-STG-019 … -024).
void main() {
  /// The server's answers by the value sent, as found on 2026-11-22.
  const byValue = {
    '1': 'lookup_serial_valid_200.json',
    '0000000000000000001': 'lookup_serial_checked_before_200.json',
    '1000001': 'lookup_serial_unassigned_200.json',
    '1234567890': 'lookup_serial_not_found_200.json',
    'Q8F2KD91XA7M': 'lookup_qr_not_found_200.json',
  };

  Map<String, Answer> server() => {
    'GET me': (_) => stagingScripted('me_200.json'),
    'GET formats': (_) => stagingScripted('formats_200.json'),
    'POST lookups': (r) => stagingScripted(byValue[(r.data as Map)['value']]!),
  };

  Future<FlowApp> check(WidgetTester tester, String serial) async {
    final app = await startApp(tester, overrides: server());
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
    return app;
  }

  testWidgets('TC-STG-019 genuine: every field of the item as sent', (
    tester,
  ) async {
    final app = await check(tester, '1');
    expect(app.backend.sent('POST', 'lookups').single.data, {
      'way': 'serial',
      'value': '1',
    });
    expect(find.text('Genuine product'), findsOneWidget);
    expect(find.text('MA-2026-000005'), findsOneWidget);
    for (final text in [
      'Napa Extra 500',
      'Paracetamol + Caffeine',
      'Napa Extra',
      'ZT-2509-001',
      'Sep 18, 2025',
      'Sep 18, 2027',
      '*****BQQ',
    ]) {
      await tester.scrollUntilVisible(
        find.text(text).first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(text), findsWidgets, reason: text);
    }
    // No picture_url: the card at the bottom says so; nothing is loaded.
    await tester.scrollUntilVisible(
      find.text('No picture for this product'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No picture for this product'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-STG-020 checked before: the number and the last time in '
      'Bangladesh time (the server writes +00:00 with 5 decimals)', (
    tester,
  ) async {
    await check(tester, '0000000000000000001');
    expect(find.text('Genuine, needs attention'), findsOneWidget);
    // 06:30:49 UTC on 22 Nov is 12:30 PM in Dhaka.
    final detail = find.textContaining('This is check number 2 of this item.');
    expect(detail, findsWidgets);
    final text = tester.widget<Text>(detail.first).data!;
    expect(text, contains('Nov 22, 2026'));
    expect(text, contains('12:30'));
  });

  testWidgets('TC-STG-021 not in a batch: no item in the answer', (
    tester,
  ) async {
    await check(tester, '1000001');
    expect(find.text('Not in a batch'), findsWidgets);
    expect(find.text('MA-2026-000001'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TC-STG-022 not found: the reference and what was entered', (
    tester,
  ) async {
    await check(tester, '1234567890');
    expect(find.text('Not found'), findsWidgets);
    expect(find.text('MA-2026-000006'), findsWidgets);
    expect(find.text('1234567890'), findsWidgets);
  });

  testWidgets('TC-STG-023 a QR from the camera: only its 12 characters '
      'sent; not found', (tester) async {
    final app = await startApp(tester, overrides: server());
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pump();
    await tester.pumpAndSettle();
    expect(app.backend.sent('POST', 'lookups').single.data, {
      'way': 'qr',
      'value': 'Q8F2KD91XA7M',
    });
    expect(find.text('Not found'), findsWidgets);
    expect(find.text('MA-2026-000008'), findsWidgets);
  });

  group('TC-STG-024 what the app never sends', () {
    test('the hidden-code way: 400, a validation error', () {
      final answer = stagingAnswer('lookup_hidden_code_400.json');
      final error = ErrorMapper.fromResponse(
        statusCode: answer['status'] as int,
        body: answer['body'],
      );
      expect(error, isA<ValidationException>());
      expect(error.requestId, 'req-staging');
    });

    test('letters in a serial: the server records it as not found (the '
        'app refuses it before sending)', () {
      final answer = stagingAnswer('lookup_serial_letters_200.json');
      final data =
          (answer['body'] as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      final result = LookupResultDto.fromJson(data).toEntity();
      expect(result.outcome, LookupOutcome.notFound);
    });
  });
}
