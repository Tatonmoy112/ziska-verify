import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/item_details_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/product_picture_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// Flow tests: the result screen without an item (final.md Section
/// 13.1.4, decision 49): what was entered, hints, and the actions
/// (docs/test-cases/04-lookup.md, TC-LOOK-094 … -101).
void main() {
  const notFound = {'ref': 'MA-2026-000999', 'result': 'not_found'};

  Map<String, Object?> formats({
    int maxDigits = 19,
    List<int> hidden = const [12],
  }) => {
    'hidden_code': [
      for (final n in hidden) {'length': n, 'characters': '0123456789'},
    ],
    'serial': {'max_digits': maxDigits},
    'qr': {'length': 12, 'characters': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'},
  };

  Future<FlowApp> lookUp(
    WidgetTester tester, {
    String way = 'serial',
    String value = '1000999',
    Map<String, Object?> answer = notFound,
    Map<String, dynamic>? profile,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(
      tester,
      profile: profile,
      overrides: {'POST lookups': always(ok(answer)), ...overrides},
    );
    if (way == 'hidden_code') await app.tapText('Hidden code');
    await app.enter(const Key('verify.input'), value);
    await app.tap(find.byKey(const Key('verify.submit')));
    return app;
  }

  Finder row(String label) => find.text(label);

  testWidgets('TC-LOOK-089 every path opens the same result screen', (
    tester,
  ) async {
    /// The genuine result screen: the top card, the details, the picture.
    Future<void> expectGenuineScreen(String path) async {
      expect(find.byType(LookupResultScreen), findsOneWidget, reason: path);
      expect(find.byType(VerificationResultCard), findsOneWidget);
      expect(find.byType(ItemDetailsCard), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(ProductPictureCard),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byType(ProductPictureCard), findsOneWidget, reason: path);
    }

    // Typed.
    var app = await startApp(tester);
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    await expectGenuineScreen('typed');

    // Scanned.
    app = await startApp(tester);
    await app.tap(find.byKey(const Key('verify.scan')));
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    await expectGenuineScreen('scanned');

    // A row of the Bulk lookup results (one genuine item, as sent).
    app = await startApp(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          ok({
            'summary': {
              'total': 1,
              'valid': 1,
              'warning': 0,
              'by_reason': <String, int>{},
              'not_found': 0,
              'unassigned': 0,
            },
            'results': [
              {
                'ref': 'MA-2026-000901',
                'result': 'valid',
                'reasons': <String>[],
                'count': {'this_check': 1, 'last_at': null},
                'item': {
                  'serial': '1000001',
                  'code': '*****7K2',
                  'product': {
                    'name': 'Paracetamol 500',
                    'generic_name': 'Paracetamol',
                    'short_name': null,
                    'picture_url': 'https://pictures.example.com/53/9f2c.png',
                  },
                  'batch': {'number': 'B-1042', 'made': null, 'expires': null},
                },
              },
            ],
          }),
        ),
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    await app.enter(const Key('bulk.input'), '1000001');
    await app.tap(find.byKey(const Key('bulk.add')));
    await app.tap(find.byKey(const Key('bulk.send')));
    await app.tap(find.textContaining('1. ').first);
    await expectGenuineScreen('bulk row');
  });

  testWidgets('TC-LOOK-094 not found: what you entered', (tester) async {
    await lookUp(tester);
    expect(find.text('WHAT YOU ENTERED'), findsOneWidget);
    expect(row('Serial'), findsOneWidget);
    expect(find.text('1000999'), findsOneWidget);
    expect(row('Checked at'), findsOneWidget);
    expect(row('Result'), findsOneWidget);
    // "Not found" as the title and as the result row, in red.
    final result = find.descendant(
      of: find.ancestor(of: row('Result'), matching: find.byType(Row)).first,
      matching: find.text('Not found'),
    );
    expect(result, findsOneWidget);
    expect(
      (tester
                  .widget<RichText>(
                    find.descendant(
                      of: result,
                      matching: find.byType(RichText),
                    ),
                  )
                  .text
              as TextSpan)
          .style!
          .color,
      AppColors.danger,
    );
    // The reference in the top card and in the rows.
    expect(find.text('MA-2026-000999'), findsNWidgets(2));
  });

  testWidgets('TC-LOOK-095 not found by hidden code: masked only', (
    tester,
  ) async {
    await lookUp(tester, way: 'hidden_code', value: '481516234999');
    expect(row('Hidden code'), findsOneWidget);
    expect(find.text('*****999'), findsOneWidget);
    expect(find.textContaining('481516234999'), findsNothing);
    // Nor in the route's extra.
    final screen = tester.widget<LookupResultScreen>(
      find.byType(LookupResultScreen),
    );
    expect(screen.view.input.shown, '*****999');
  });

  testWidgets('TC-LOOK-096 hints from the formats', (tester) async {
    await lookUp(
      tester,
      overrides: {
        'GET formats': always(ok(formats(maxDigits: 10, hidden: [16, 12]))),
      },
    );
    await tester.scrollUntilVisible(
      find.text('HINTS'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.text('A serial has digits only, up to 10 digits.'),
      findsOneWidget,
    );
    expect(find.text('A hidden code has 12 or 16 characters.'), findsOneWidget);
    expect(
      find.text('Scratch the panel off fully before typing the hidden code.'),
      findsOneWidget,
    );
    // No fixed lengths from the Figma (backend D41).
    expect(find.textContaining('7 digits'), findsNothing);
  });

  testWidgets('TC-LOOK-097 the QR hint only when not scanned', (
    tester,
  ) async {
    const qrHint = 'Scan the QR code instead of typing.';
    await lookUp(tester);
    await tester.scrollUntilVisible(
      find.text(qrHint),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(qrHint), findsOneWidget);

    final app = await startApp(
      tester,
      overrides: {'POST lookups': always(ok(notFound))},
    );
    await app.tap(find.byKey(const Key('verify.scan')));
    app.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    expect(find.text('Q8F2KD91XA7M'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('HINTS'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(qrHint), findsNothing);
  });

  testWidgets('TC-LOOK-098 Try again returns to where it started', (
    tester,
  ) async {
    final app = await lookUp(
      tester,
      way: 'hidden_code',
      value: '481516234999',
    );
    await app.tap(find.byKey(const Key('result.tryAgain')));
    expect(find.byType(LookupResultScreen), findsNothing);
    expect(app.fieldText(const Key('verify.input')), isEmpty);

    final scanned = await startApp(
      tester,
      overrides: {'POST lookups': always(ok(notFound))},
    );
    await scanned.tap(find.byKey(const Key('verify.scan')));
    scanned.scanner.scan('https://www.ziskaverify.com/q/Q8F2KD91XA7M');
    await tester.pumpAndSettle();
    await scanned.tap(find.byKey(const Key('result.tryAgain')));
    expect(find.byKey(const Key('fake.camera')), findsOneWidget);
  });

  testWidgets('TC-LOOK-099 Contact support only when set', (tester) async {
    var app = await lookUp(tester, way: 'hidden_code', value: '481516234999');
    await app.tap(find.byKey(const Key('result.contactSupport')));
    final mail = app.launcher.emails.single;
    expect(mail.to, 'help@ziska.example');
    expect(mail.subject, contains('MA-2026-000999'));
    expect(mail.body, contains('Hidden code: *****999'));
    expect(mail.body, isNot(contains('481516234999')));

    app = await lookUp(
      tester,
      profile: {
        ...Roles.fieldInspector,
        'support': {'email': null, 'phone': '+880 2 0000 0000'},
      },
    );
    await app.tap(find.byKey(const Key('result.contactSupport')));
    expect(app.launcher.calls, ['+880 2 0000 0000']);
    expect(app.launcher.emails, isEmpty);

    await lookUp(tester, profile: Roles.noSupport);
    await tester.scrollUntilVisible(
      find.byKey(const Key('result.backToVerify')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const Key('result.contactSupport')), findsNothing);
  });

  testWidgets('TC-LOOK-100 Back to Verify', (tester) async {
    final app = await startApp(
      tester,
      overrides: {
        'POST lookups/bulk': always(
          ok({
            'summary': {
              'total': 1,
              'valid': 0,
              'warning': 0,
              'by_reason': <String, int>{},
              'not_found': 1,
              'unassigned': 0,
            },
            'results': [notFound],
          }),
        ),
      },
    );
    await app.tap(find.byKey(const Key('verify.tool.bulk')));
    await app.enter(const Key('bulk.input'), '1000999');
    await app.tap(find.byKey(const Key('bulk.add')));
    await app.tap(find.byKey(const Key('bulk.send')));
    await app.tapText('1. 1000999');
    expect(find.byType(LookupResultScreen), findsOneWidget);
    await app.tap(find.byKey(const Key('result.backToVerify')));
    expect(find.byKey(const Key('verify.input')), findsOneWidget);
    expect(find.byType(LookupResultScreen), findsNothing);
  });

  testWidgets('TC-LOOK-101 not in a batch and unknown use the same layout', (
    tester,
  ) async {
    for (final (result, title) in [
      ('unassigned', 'Not in a batch'),
      ('something_new', 'Unable to verify'),
    ]) {
      await lookUp(tester, answer: {'ref': 'MA-2026-000555', 'result': result});
      expect(find.text(title), findsNWidgets(2), reason: result);
      expect(find.text('WHAT YOU ENTERED'), findsOneWidget);
      expect(find.text('HINTS'), findsNothing);
      expect(find.text('Genuine product'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('result.backToVerify')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(const Key('result.tryAgain')), findsOneWidget);
    }
  });
}
