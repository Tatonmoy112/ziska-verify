import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_preferences_service.dart';
import '../fakes/roles.dart';
import 'harness.dart';

/// The language switch, English and Bangla (final.md Sections 13.7, 16;
/// docs/test-cases/09-profile.md TC-PROF-006, -019 … -035; TC-HIST-044;
/// TC-ERR-046).
void main() {
  final banglaDigit = RegExp('[০-৯]');

  /// Starts the app in Bangla, as after an earlier choice.
  Future<FlowApp> startInBangla(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    bool loggedIn = true,
    Map<String, Answer> overrides = const {},
  }) => startApp(
    tester,
    profile: profile,
    loggedIn: loggedIn,
    overrides: overrides,
    preferences: FakePreferencesService(language: 'bn'),
  );

  Future<void> chooseLanguage(FlowApp app, String name) async {
    // The Profile tab in whichever language is on screen.
    final english = tab('Profile').evaluate().isNotEmpty;
    await app.tap(tab(english ? 'Profile' : 'প্রোফাইল'));
    await app.tap(find.byKey(const Key('profile.language')));
    await app.tap(find.text(name).last);
  }

  testWidgets('TC-PROF-022 the switch on Profile: both offered, the current '
      'one marked', (tester) async {
    final app = await startApp(tester);
    await app.tap(tab('Profile'));
    final row = find.byKey(const Key('profile.language'));
    expect(
      find.descendant(of: row, matching: find.text('English')),
      findsOneWidget,
    );
    await app.tap(row);
    expect(find.text('App language'), findsOneWidget);
    final english = tester.widget<ListTile>(
      find.byKey(const Key('language.en')),
    );
    final bangla = tester.widget<ListTile>(
      find.byKey(const Key('language.bn')),
    );
    expect(english.selected, isTrue);
    expect(bangla.selected, isFalse);
    expect(find.text('বাংলা'), findsOneWidget);
  });

  testWidgets('TC-PROF-006 / -023 Bangla applies at once, without a restart', (
    tester,
  ) async {
    final app = await startApp(tester);
    await chooseLanguage(app, 'বাংলা');
    expect(app.preferences.language, 'bn');
    // Profile itself, then the Check tab, in Bangla at once.
    expect(find.text('ভাষা'), findsOneWidget);
    expect(find.text('Language'), findsNothing);
    await app.tap(tab('যাচাই'));
    expect(tab('Check'), findsNothing);
    expect(find.text('সত্যতা যাচাই করুন'), findsWidgets);

    // And back to English.
    await chooseLanguage(app, 'English');
    expect(app.preferences.language, 'en');
    expect(tab('Check'), findsOneWidget);
  });

  testWidgets('TC-PROF-019 kept after a restart', (tester) async {
    var app = await startApp(tester);
    await chooseLanguage(app, 'বাংলা');
    app = await startApp(tester, preferences: app.preferences);
    expect(tab('যাচাই'), findsOneWidget);
    expect(tab('ইতিহাস'), findsOneWidget);
  });

  testWidgets('TC-PROF-029 kept after logout: Login in Bangla', (tester) async {
    final app = await startInBangla(tester);
    await app.tap(tab('প্রোফাইল'));
    await app.tap(find.byKey(const Key('profile.logout')));
    await app.tapText('লগআউট');
    expect(find.text('Track & Trace-এ লগইন করুন'), findsOneWidget);
    expect(app.preferences.language, 'bn');
  });

  testWidgets('TC-PROF-030 the first start is in English, whatever the '
      "phone's language", (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('bn', 'BD')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await startApp(tester, loggedIn: false);
    expect(find.text('Login to Track & Trace'), findsOneWidget);
  });

  testWidgets('a stored value that cannot be read starts in English', (
    tester,
  ) async {
    final preferences = FakePreferencesService(language: 'bn')
      ..failure = Exception('unreadable');
    final app = await startApp(tester, preferences: preferences);
    expect(tab('Check'), findsOneWidget);
    // A save that fails still switches for this run.
    await chooseLanguage(app, 'বাংলা');
    expect(tab('যাচাই'), findsOneWidget);
  });

  testWidgets('TC-PROF-024 the reference line in Bangla, the reference '
      'unchanged', (tester) async {
    final app = await startInBangla(
      tester,
      overrides: {
        'POST lookups': always(
          apiError(500, 'internal_error', requestId: 'req-9'),
        ),
      },
    );
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(find.text('রেফারেন্স: req-9'), findsOneWidget);
  });

  testWidgets('TC-PROF-025 messages chosen by the error code, in Bangla', (
    tester,
  ) async {
    var app = await startInBangla(
      tester,
      loggedIn: false,
      overrides: {
        'POST auth/login': always(
          apiError(401, 'unauthenticated', message: 'Invalid credentials'),
        ),
      },
    );
    await logInToCode(app);
    expect(find.text('ইমেইল বা পাসওয়ার্ড সঠিক নয়।'), findsOneWidget);
    expect(find.textContaining('Invalid credentials'), findsNothing);

    app = await startInBangla(
      tester,
      overrides: {
        'POST lookups': always(
          apiError(503, 'app_preparing', message: 'Preparing'),
        ),
      },
    );
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(
      find.textContaining('অ্যাপটি প্রস্তুত হচ্ছে। পরে আবার চেষ্টা করুন।'),
      findsOneWidget,
    );
    expect(find.textContaining('Preparing'), findsNothing);
  });

  testWidgets('TC-PROF-026 an unknown code keeps the server text', (
    tester,
  ) async {
    final app = await startInBangla(
      tester,
      overrides: {
        'POST lookups': always(
          apiError(
            400,
            'brand_new',
            requestId: 'req-new',
            message: 'This client is under review.',
          ),
        ),
      },
    );
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    expect(find.textContaining('This client is under review.'), findsOneWidget);
    expect(find.text('রেফারেন্স: req-new'), findsOneWidget);
  });

  testWidgets('TC-PROF-027 times in Bangla digits on a result and My '
      'reports', (tester) async {
    final app = await startInBangla(
      tester,
      profile: Roles.supervisor,
      overrides: {
        'POST lookups': always(
          ok({
            'ref': 'MA-2026-000777',
            'result': 'warning',
            'reasons': ['checked_before'],
            'count': {'this_check': 2, 'last_at': '2026-10-12T20:30:00Z'},
            'item': {
              'serial': '1000001',
              'code': '*****7K2',
              'product': {
                'name': 'Paracetamol 500',
                'generic_name': 'Paracetamol',
                'short_name': 'PCM500',
                'picture_url': null,
              },
              'batch': {
                'number': 'B-1042',
                'made': '2026-01-10',
                'expires': '2027-09-30',
              },
            },
          }),
        ),
      },
    );
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    // 20:30 UTC on 12 Oct is 13 Oct in Dhaka.
    final last = find.textContaining('শেষ যাচাই:');
    expect(last, findsOneWidget);
    final text = tester.widget<Text>(last).data!;
    expect(text, contains('১৩'));
    expect(text, contains('২০২৬'));
    expect(text, isNot(contains('2026')));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(tiles['myReports']!),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(tiles['myReports']!));
    expect(find.text('আমার রিপোর্ট'), findsWidgets);
    expect(find.textContaining(banglaDigit), findsWidgets);
    // No time in Latin digits (references keep theirs).
    expect(find.textContaining(RegExp('[0-9]+:[0-9]{2}')), findsNothing);
  });

  testWidgets('TC-HIST-044 History times in Bangla digits', (tester) async {
    final app = await startInBangla(tester);
    await app.tap(tab('ইতিহাস'));
    final times = find.byKey(const Key('checkTile.when'));
    expect(times, findsWidgets);
    for (final time in tester.widgetList<Text>(times)) {
      expect(time.data, contains(banglaDigit));
      expect(time.data, isNot(contains(RegExp('[0-9]'))));
    }
  });

  testWidgets('TC-PROF-028 the date picker in Bangla; the dates sent in '
      'YYYY-MM-DD with Latin digits', (tester) async {
    await withClock(Clock.fixed(DateTime.utc(2026, 11, 10)), () async {
      final app = await startInBangla(tester);
      await app.tap(tab('ইতিহাস'));
      tester.view.devicePixelRatio = 1;
      await tester.pumpAndSettle();
      await app.tap(find.byKey(const Key('history.filters')));
      await app.tapText('তারিখ বেছে নিন');
      final picker = find.byType(DateRangePickerDialog);
      final material = MaterialLocalizations.of(tester.element(picker));
      expect(material.okButtonLabel, isNot('OK'));
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: picker,
        matching: find.byType(TextField),
      );
      // The fields read the Bangla date format and digits.
      final start = material.formatCompactDate(DateTime(2026, 10));
      final end = material.formatCompactDate(DateTime(2026, 10, 28));
      expect(start, contains('২০২৬'));
      await tester.enterText(fields.at(0), start);
      await tester.enterText(fields.at(1), end);
      await tester.pumpAndSettle();
      await tester.tap(find.text(material.okButtonLabel));
      await tester.pumpAndSettle();
      expect(picker, findsNothing);
      await app.tapText('প্রয়োগ করুন');
      final sent = app.backend.sent('GET', 'checks').last.queryParameters;
      // The UTC days the Bangladesh days overlap (TC-HIST-051).
      expect(sent['from'], '2026-09-30');
      expect(sent['to'], '2026-10-28');
    });
  });

  testWidgets('TC-PROF-033 the password rules in Bangla, a Bangla password '
      'accepted', (tester) async {
    final app = await startInBangla(tester);
    await app.tap(tab('প্রোফাইল'));
    await app.tapText('পাসওয়ার্ড বদলান');
    expect(find.text('৮ বা তার বেশি অক্ষর'), findsOneWidget);
    expect(find.text('একটি বর্ণ'), findsOneWidget);
    expect(find.text('একটি সংখ্যা'), findsOneWidget);
    await app.enter(const Key('change.old'), 'secret-pass');
    await app.enter(const Key('change.new'), 'পাসওয়ার্ড১');
    await app.enter(const Key('change.repeat'), 'পাসওয়ার্ড১');
    expect(app.enabled(const Key('change.submit')), isTrue);
  });

  testWidgets('TC-PROF-035 Bangla digits typed into a serial are sent as '
      '0-9', (tester) async {
    final app = await startInBangla(tester);
    const input = Key('verify.input');
    await app.enter(input, '');
    // One key at a time, as a Bangla keyboard types.
    for (final digit in '১০০০০০১'.split('')) {
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '${app.fieldText(input)}$digit',
          selection: TextSelection.collapsed(
            offset: app.fieldText(input).length + 1,
          ),
        ),
      );
      await tester.pump();
    }
    expect(app.fieldText(input), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    final body = app.backend.sent('POST', 'lookups').single.data as Map;
    expect(body.values, contains('1000001'));
  });

  testWidgets('TC-ERR-046 the offline banner in Bangla', (tester) async {
    final app = await startInBangla(tester);
    app.connectivity.set(online: false);
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();
    expect(
      find.text('ইন্টারনেট সংযোগ নেই। যাচাই করতে সংযোগ প্রয়োজন।'),
      findsOneWidget,
    );
  });
}
