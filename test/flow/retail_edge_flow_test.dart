import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: retail user edge, worst, and failure cases
/// (docs/test-cases/08-retail-users.md, TC-RTL-012 and later).
void main() {
  const general = 'Something went wrong. Try again.';
  const userPath = 'retail-users/9d2e7c1b-3a4f-4e5d-8b6c-1f2a3b4c5d6e/password';
  final confirmEmail = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text('Email it'),
  );

  Future<void> openTile(FlowApp app, Key key) async {
    await app.tester.scrollUntilVisible(
      find.byKey(key),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(key));
  }

  Future<FlowApp> openList(
    WidgetTester tester, {
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      overrides: overrides,
    );
    await openTile(app, const Key('verify.tool.retailUsers'));
    return app;
  }

  Future<FlowApp> openAdd(
    WidgetTester tester, {
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await openList(tester, overrides: overrides);
    await app.tap(find.byKey(const Key('retailUsers.add')));
    return app;
  }

  Future<void> fill(
    FlowApp app, {
    String name = 'Rahim Store',
    String email = 'rahim.store@gmail.com',
    String password = '1234567890',
    String role = 'Retail seller',
  }) async {
    await app.enter(const Key('addRetail.name'), name);
    await app.enter(const Key('addRetail.email'), email);
    await app.tap(find.byKey(const Key('addRetail.role')));
    await app.tapText(role);
    await app.enter(const Key('addRetail.password'), password);
  }

  Future<void> add(FlowApp app) =>
      app.tap(find.byKey(const Key('addRetail.submit')));

  Map<String, dynamic> sentUser(FlowApp app) =>
      app.backend.sent('POST', 'retail-users').last.data
          as Map<String, dynamic>;

  ScriptedAnswer added({bool? emailed}) => ok({
    'id': 'new-1',
    'name': 'Rahim Store',
    'email': 'rahim.store@gmail.com',
    'email_sent': emailed,
  }, status: 201);

  group('Add form', () {
    testWidgets('TC-RTL-012 an empty name, or one over 100 characters', (
      tester,
    ) async {
      final app = await openAdd(tester);
      await fill(app, name: '');
      expect(app.enabled(const Key('addRetail.submit')), isFalse);
      await app.enter(const Key('addRetail.name'), 'n' * 101);
      expect(app.fieldText(const Key('addRetail.name')), hasLength(100));
    });

    for (final name in ['R', 'n' * 100]) {
      testWidgets('TC-RTL-013 a name of ${name.length} characters is sent', (
        tester,
      ) async {
        final app = await openAdd(tester);
        await fill(app, name: name);
        await add(app);
        expect(sentUser(app)['name'], name);
      });
    }

    testWidgets('TC-RTL-014 an email that is not an address', (tester) async {
      final app = await openAdd(tester);
      for (final email in ['rahim.store', 'rahim@']) {
        await fill(app, email: email);
        expect(app.enabled(const Key('addRetail.submit')), isFalse);
      }
      expect(app.backend.sent('POST', 'retail-users'), isEmpty);
    });

    testWidgets('TC-RTL-016 an empty first password', (tester) async {
      final app = await openAdd(tester);
      await fill(app, password: '');
      expect(app.enabled(const Key('addRetail.submit')), isFalse);
    });

    for (final password in ['1', 'abc']) {
      testWidgets('TC-RTL-017 first password "$password": no rule', (
        tester,
      ) async {
        final app = await openAdd(tester);
        await fill(app, password: password);
        expect(find.text('8 characters or more'), findsNothing);
        await add(app);
        expect(sentUser(app)['password'], password);
      });
    }

    testWidgets('TC-RTL-018 first password of 128, never 129', (
      tester,
    ) async {
      final app = await openAdd(tester);
      await fill(app, password: 'p' * 129);
      expect(app.fieldText(const Key('addRetail.password')), hasLength(128));
      await add(app);
      expect(sentUser(app)['password'], hasLength(128));
    });

    testWidgets('TC-RTL-019 a first password with a control character', (
      tester,
    ) async {
      final app = await openAdd(tester);
      await fill(app, password: 'abc\t123');
      expect(app.enabled(const Key('addRetail.submit')), isFalse);
      expect(app.backend.sent('POST', 'retail-users'), isEmpty);
    });

    testWidgets('TC-RTL-020 several retail roles', (tester) async {
      final app = await openAdd(
        tester,
        overrides: {
          'GET retail-roles': always(
            ok([
              {'id': 7, 'name': 'Retail seller'},
              {'id': 8, 'name': 'Senior seller'},
            ]),
          ),
        },
      );
      await fill(app, role: 'Senior seller');
      await add(app);
      expect(sentUser(app)['role_id'], 8);
    });

    testWidgets('TC-RTL-021 the role is no longer a retail role', (
      tester,
    ) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': always(apiError(404, 'not_found'))},
      );
      await fill(app);
      await add(app);
      expect(
        find.text('This role is no longer a retail role. Choose another.'),
        findsOneWidget,
      );
    });

    testWidgets('TC-RTL-022 one press, one account', (tester) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': slow(always(added(emailed: true)))},
      );
      await fill(app);
      final submit = find.byKey(const Key('addRetail.submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(submit, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', 'retail-users'), hasLength(1));
    });

    testWidgets('TC-RTL-023 adding rate limited counts down and waits', (
      tester,
    ) async {
      final app = await openAdd(
        tester,
        overrides: {
          'POST retail-users': always(
            apiError(429, 'rate_limited', retryAfter: 120),
          ),
        },
      );
      await fill(app);
      await add(app);
      expect(
        find.textContaining('Too many attempts. Try again in 120 s.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Too many attempts. Try again in 119 s.'),
        findsOneWidget,
      );
      await add(app);
      expect(app.backend.sent('POST', 'retail-users'), hasLength(1));
    });

    testWidgets('TC-RTL-024 adding offline', (tester) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': offline()},
      );
      await fill(app);
      await add(app);
      expect(
        find.text('No connection. Check the internet and try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('was added'), findsNothing);
    });

    testWidgets('TC-RTL-025 send_email follows the switch', (tester) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': always(added())},
      );
      await fill(app);
      await app.tap(find.byKey(const Key('addRetail.sendEmail')));
      await add(app);
      expect(sentUser(app)['send_email'], isFalse);
    });

    testWidgets('TC-RTL-027 copy the first password', (tester) async {
      String? copied;
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': always(added())},
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await fill(app, password: 'first-pass-1');
      await app.tap(find.byKey(const Key('addRetail.sendEmail')));
      await add(app);
      await app.tap(find.byIcon(LucideIcons.copy));
      expect(copied, 'first-pass-1');
    });

    testWidgets('TC-RTL-028 retail roles fail to load, then Try again', (
      tester,
    ) async {
      var calls = 0;
      final app = await openAdd(
        tester,
        overrides: {
          'GET retail-roles': (_) => calls++ == 0
              ? apiError(500, 'internal_error', requestId: 'req-r')
              : ok([
                  {'id': 7, 'name': 'Retail seller'},
                ]),
        },
      );
      expect(find.text(general), findsOneWidget);
      expect(find.textContaining('req-r'), findsOneWidget);
      expect(find.byKey(const Key('addRetail.name')), findsNothing);
      await app.tapText('Try again');
      expect(find.byKey(const Key('addRetail.name')), findsOneWidget);
    });

    testWidgets('TC-RTL-029 the first password is never logged', (
      tester,
    ) async {
      final app = await openAdd(tester);
      await fill(app, password: 'secret-first-77');
      await add(app);
      expect(app.logger.lines.join('\n'), isNot(contains('secret-first-77')));
    });
  });

  group('Email a new first password', () {
    Future<void> askEmail(FlowApp app) async {
      await app.tap(find.byIcon(LucideIcons.ellipsisVertical));
      await app.tapText('Email a new first password');
    }

    testWidgets('TC-RTL-032 Cancel sends nothing', (tester) async {
      final app = await openList(tester);
      await askEmail(app);
      await app.tapText('Cancel');
      expect(app.backend.sent('POST', userPath), isEmpty);
    });

    testWidgets('TC-RTL-033 not found or blocked', (tester) async {
      final app = await openList(
        tester,
        overrides: {'POST $userPath': always(apiError(404, 'not_found'))},
      );
      await askEmail(app);
      await app.tap(confirmEmail);
      expect(
        find.textContaining('This retail user was not found or is blocked.'),
        findsOneWidget,
      );
    });

    testWidgets('TC-RTL-034 rate limited: counts down and waits', (
      tester,
    ) async {
      final app = await openList(
        tester,
        overrides: {
          'POST $userPath': always(
            apiError(429, 'rate_limited', retryAfter: 120),
          ),
        },
      );
      await askEmail(app);
      await tester.tap(confirmEmail);
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.textContaining('Too many attempts. Try again in 120 s.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Too many attempts. Try again in 119 s.'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await askEmail(app);
      await app.tap(confirmEmail);
      expect(app.backend.sent('POST', userPath), hasLength(1));
    });

    testWidgets('TC-RTL-035 one press, one mail', (tester) async {
      final app = await openList(
        tester,
        overrides: {
          'POST $userPath': slow(
            always(ok({'email_sent': true})),
            const Duration(seconds: 10),
          ),
        },
      );
      await askEmail(app);
      await tester.tap(confirmEmail);
      await tester.pump(const Duration(milliseconds: 500));

      // A second try while the first mail is still being sent; pumps only,
      // so the first answer cannot arrive in between.
      Future<void> tapIfThere(Finder f) async {
        if (f.evaluate().isNotEmpty) {
          await tester.tap(f.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      await tapIfThere(find.byIcon(LucideIcons.ellipsisVertical));
      await tapIfThere(find.text('Email a new first password'));
      await tapIfThere(confirmEmail);
      expect(app.backend.sent('POST', userPath), hasLength(1));

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(app.backend.sent('POST', userPath), hasLength(1));
    });
  });

  group('List and picker', () {
    Map<String, Object?> user(String id, String name, String email) => {
      'id': id,
      'name': name,
      'email': email,
    };

    ScriptedAnswer users(List<Map<String, Object?>> list, {String? next}) =>
        ok({'retail_users': list, 'next_cursor': next});

    testWidgets('TC-RTL-037 the next page', (tester) async {
      final app = await openList(
        tester,
        overrides: {
          'GET retail-users': (r) => r.queryParameters['cursor'] == null
              ? users([user('a', 'Alpha Store', 'al***@x.com')], next: 'c1')
              : users([user('b', 'Beta Store', 'be***@x.com')]),
        },
      );
      expect(
        app.backend.sent('GET', 'retail-users').last.queryParameters['cursor'],
        'c1',
      );
      expect(find.text('Alpha Store'), findsOneWidget);
      expect(find.text('Beta Store'), findsOneWidget);
    });

    testWidgets('TC-RTL-038 the search waits for typing to stop', (
      tester,
    ) async {
      final app = await openList(tester);
      final before = app.backend.sent('GET', 'retail-users').length;
      await tester.enterText(
        find.byKey(const Key('retailUsers.search')),
        'RAHIM',
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(app.backend.sent('GET', 'retail-users'), hasLength(before));
      await app.settleAfter(const Duration(milliseconds: 200));
      final searched = app.backend
          .sent('GET', 'retail-users')
          .where((r) => r.queryParameters['search'] == 'RAHIM');
      expect(searched, hasLength(1));
    });

    testWidgets('TC-RTL-039 never more than 100 search characters', (
      tester,
    ) async {
      final app = await openList(tester);
      await app.enter(const Key('retailUsers.search'), 's' * 101);
      await app.settleAfter(const Duration(milliseconds: 500));
      for (final r in app.backend.sent('GET', 'retail-users')) {
        final search = r.queryParameters['search'] as String?;
        expect((search ?? '').length, lessThanOrEqualTo(100));
      }
    });

    testWidgets('TC-RTL-041 a short masked email shown as received', (
      tester,
    ) async {
      await openList(
        tester,
        overrides: {
          'GET retail-users': always(
            users([user('r', 'Ra Store', 'r***@gmail.com')]),
          ),
        },
      );
      expect(find.text('r***@gmail.com'), findsOneWidget);
    });

    testWidgets('TC-RTL-042 no retail users yet', (tester) async {
      await openList(
        tester,
        overrides: {'GET retail-users': always(users([]))},
      );
      expect(find.text('No retail user yet.'), findsOneWidget);
    });

    Future<FlowApp> openPicker(
      WidgetTester tester,
      Map<String, Answer> overrides,
    ) async {
      final app = await startApp(tester, overrides: overrides);
      await openTile(app, const Key('verify.tool.report'));
      await app.tap(find.byKey(const Key('report.retailUser')));
      return app;
    }

    testWidgets('TC-RTL-040 no retail user matches in the picker', (
      tester,
    ) async {
      final app = await openPicker(tester, {
        'GET retail-users': (r) => r.queryParameters['search'] == null
            ? FakeBackend.example(
                200,
                'Pick a retail user',
                '200 The retail users',
              )
            : users([]),
      });
      await app.enter(const Key('picker.search'), 'zzz');
      await app.settleAfter(const Duration(milliseconds: 500));
      expect(find.text('No retail user found'), findsOneWidget);
    });

    testWidgets('TC-RTL-043 a new picker search starts again', (
      tester,
    ) async {
      final app = await openPicker(tester, {
        'GET retail-users': (r) => r.queryParameters['cursor'] == null
            ? users([user('a', 'Alpha Store', 'al***@x.com')], next: 'c1')
            : users([user('b', 'Beta Store', 'be***@x.com')]),
      });
      await app.enter(const Key('picker.search'), 'beta');
      await app.settleAfter(const Duration(milliseconds: 500));
      final searched = app.backend
          .sent('GET', 'retail-users')
          .firstWhere((r) => r.queryParameters['search'] == 'beta');
      expect(searched.queryParameters.containsKey('cursor'), isFalse);
    });

    testWidgets('TC-RTL-044 the picker offline', (tester) async {
      await openPicker(tester, {'GET retail-users': offline()});
      expect(
        find.text('No connection. Check the internet and try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
