import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

import '../fakes/fake_preferences_service.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart';
import 'source_scan.dart';
import 'ui_helpers.dart';

/// Sections D (consistency across screens), E (text and fit), and G (the
/// component inventory) of docs/test-cases/15-ui.md (TC-UI-134 … -146,
/// TC-UI-159).
void main() {
  setUpAll(loadUiFonts);
  hideFlavourRibbon();
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<FlowApp> start(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    bool loggedIn = true,
    Map<String, Answer> overrides = const {},
    String? language,
  }) async {
    final app = await startApp(
      tester,
      profile: profile,
      loggedIn: loggedIn,
      overrides: overrides,
      preferences: FakePreferencesService(language: language),
    );
    await atOneX(tester);
    return app;
  }

  Future<void> openTile(FlowApp app, Key key) async {
    await app.tester.scrollUntilVisible(
      find.byKey(key),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(key));
  }

  Future<void> lookUp(FlowApp app) async {
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
  }

  /// A `POST lookups` answer with [item] fields and [count] replaced.
  ScriptedAnswer lookup({
    String result = 'valid',
    List<String> reasons = const [],
    Map<String, Object?> product = const {},
    Map<String, Object?> batch = const {},
    int thisCheck = 1,
  }) => ok({
    'ref': 'MA-2026-000777',
    'result': result,
    'reasons': reasons,
    'count': {'this_check': thisCheck, 'last_at': '2026-11-10T04:00:00Z'},
    'item': {
      'serial': '1000001',
      'code': '*****7K2',
      'product': {
        'name': 'Paracetamol 500',
        'generic_name': 'Paracetamol',
        'short_name': 'PCM500',
        'picture_url': null,
        ...product,
      },
      'batch': {
        'number': 'B-1042',
        'made': '2026-01-10',
        'expires': '2027-09-30',
        ...batch,
      },
    },
  });

  /// The History first page with [check] fields and [totals] replaced.
  ScriptedAnswer checks({
    Map<String, Object?> check = const {},
    Map<String, Object?> totals = const {},
  }) => ok({
    'checks': [
      {
        'ref': 'MA-2026-000124',
        'at': '2026-10-28T10:02:11Z',
        'way': 'qr',
        'result': 'warning',
        'reasons': ['checked_before'],
        'serial': '1000001',
        'product': 'Paracetamol 500',
        'batch': 'B-1042',
        'official': 'Asha Rao',
        ...check,
      },
    ],
    'totals': {
      'total': 120,
      'valid': 80,
      'warning': 30,
      'not_found': 9,
      'unassigned': 1,
      ...totals,
    },
    'next_cursor': null,
  });

  /// Nothing drawn past an edge, and no "null" shown.
  void expectFits(WidgetTester tester) {
    expect(tester.takeException(), isNull);
    expect(find.textContaining('null'), findsNothing);
  }

  /// No text on screen ends with "…": nothing is cut off.
  void expectNothingCut(WidgetTester tester, String screen) {
    final cut = [
      for (final e in find.byType(RichText).evaluate())
        if (e.renderObject case final RenderParagraph p
            when p.didExceedMaxLines && p.attached)
          p.text.toPlainText(),
    ];
    expect(cut, isEmpty, reason: screen);
  }

  group('D. Consistency', () {
    uiTest('TC-UI-134 side padding on every main screen', (
      tester,
      shot,
    ) async {
      final app = await start(tester, profile: Roles.supervisor);

      /// [finder] starts and ends 24 from the screen sides.
      void sides(Finder finder, String screen) {
        final rect = tester.getRect(finder.first);
        expect(rect.left, AppSpacing.screen, reason: screen);
        expect(rect.right, phone.width - AppSpacing.screen, reason: screen);
      }

      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      sides(find.byKey(const Key('verify.tool.serials')), 'Check');
      await openTile(app, const Key('verify.tool.serials'));
      sides(find.byKey(const Key('serials.input')), 'Serial stack');
      await back();
      await openTile(app, const Key('verify.tool.report'));
      sides(find.byKey(const Key('report.note')), 'Report incident');
      await back();
      await openTile(app, const Key('verify.tool.myReports'));
      sides(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('reports.row.'),
        ),
        'My reports',
      );
      await back();
      await app.tap(tab(l10n.tabHistory));
      final search = tester.getRect(find.byKey(const Key('history.search')));
      final filters = tester.getRect(find.byKey(const Key('history.filters')));
      expect(search.left, AppSpacing.screen, reason: 'History search');
      expect(
        filters.right,
        phone.width - AppSpacing.screen,
        reason: 'History filters',
      );
      sides(
        find.descendant(
          of: find.byType(CheckTile),
          matching: find.byType(DecoratedBox),
        ),
        'History rows',
      );
      await app.tap(tab(l10n.tabProfile));
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.logout')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      sides(find.byKey(const Key('profile.logout')), 'Profile');
    });

    test('TC-UI-135 every main action is an AppButton', () {
      expect(
        scan(
          RegExp(r'\b(FilledButton|ElevatedButton|OutlinedButton)\b[.(]'),
          except: {
            'lib/shared/design_system/components/buttons/app_button.dart',
          },
        ),
        isEmpty,
      );
    });

    test('TC-UI-136 every text field is a design-system field', () {
      expect(
        sources().keys
            .where(
              (p) =>
                  !p.startsWith('lib/shared/design_system/components/inputs/'),
            )
            .expand((p) => scan(RegExp(r'\b(TextField|TextFormField)\(')))
            .where(
              (l) =>
                  !l.startsWith('lib/shared/design_system/components/inputs/'),
            )
            .toSet(),
        isEmpty,
      );
    });

    uiTest('TC-UI-137 every field label in capitals', (tester, shot) async {
      /// The text just above [field], left-aligned with it: its label.
      void expectLabel(Finder field, String screen) {
        final box = tester.getRect(field);
        final labels = [
          for (final e in find.byType(Text).evaluate())
            if (tester.getRect(find.byWidget(e.widget)) case final r
                when r.bottom <= box.top + 1 &&
                    box.top - r.bottom <= AppSpacing.md &&
                    (r.left - box.left).abs() <= 1)
              e.widget as Text,
        ];
        expect(labels, isNotEmpty, reason: '$screen: $field');
        final label = labels.last;
        expect(label.data, label.data!.toUpperCase(), reason: screen);
        expect(
          label.style?.fontSize,
          AppTypography.fieldLabel.fontSize,
          reason: screen,
        );
        expect(
          label.style?.letterSpacing,
          AppTypography.fieldLabel.letterSpacing,
          reason: screen,
        );
      }

      void labels(List<String> keys, String screen) {
        for (final k in keys) {
          expectLabel(find.byKey(Key(k)), screen);
        }
      }

      var app = await start(tester, loggedIn: false);
      labels(['login.email', 'login.password'], 'Login');
      await logInToCode(app);
      labels(['verify.code'], 'Check your email');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await app.tapText(l10n.forgotPassword);
      labels(['forgot.email'], 'Forgot password');
      await app.enter(const Key('forgot.email'), 'official@example.com');
      await app.tap(find.byKey(const Key('forgot.submit')));
      labels(['reset.code', 'reset.new', 'reset.repeat'], 'Reset password');

      app = await start(
        tester,
        profile: {...Roles.supervisor, 'must_change_password': true},
      );
      labels(['change.old', 'change.new', 'change.repeat'], 'Set password');

      app = await start(tester, profile: Roles.supervisor);
      labels(['verify.input'], 'Check');
      await openTile(app, const Key('verify.tool.serials'));
      labels(['serials.input'], 'Serial stack');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await openTile(app, const Key('verify.tool.report'));
      labels(['report.note'], 'Report incident');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      app = await start(tester, loggedIn: false);
      await app.tapText(l10n.requestAccessButton);
      labels([
        'access.name',
        'access.password',
        'access.email',
      ], 'Request access');
    });

    test('TC-UI-138 one error banner look', () {
      // The error box is drawn only by ErrorBanner (and the not-found
      // result card, a result, not an error); a reference line only inside
      // it, or on the splash's full-screen error.
      expect(
        scan(
          RegExp(r'AppColors\.dangerBackground'),
          except: {
            'lib/shared/widgets/error_banner.dart',
            'lib/features/verification/presentation/widgets/verification_result_card.dart',
            'lib/shared/design_system/components/buttons/app_button.dart',
          },
        ),
        isEmpty,
      );
      expect(
        scan(
          RegExp(r'\bReferenceText\('),
          except: {
            'lib/shared/widgets/error_banner.dart',
            'lib/shared/widgets/reference_text.dart',
            'lib/features/authentication/presentation/screens/splash_screen.dart',
          },
        ),
        isEmpty,
      );
    });

    test('TC-UI-139 one empty state look', () {
      // Every "nothing here" text is the title or body of an empty state
      // (AppEmptyState, or AppPaginatedList's emptyTitle and emptyBody,
      // which builds one). The serial stack's empty-list text is the
      // form's instruction under the field, not a list.
      final key = RegExp(
        r'l10n\.([a-zA-Z]*(Empty[A-Za-z]*|NoAttention|noFeatures[A-Za-z]*|NoRoles))',
      );
      final found = <String>[];
      for (final MapEntry(key: path, value: text) in sources().entries) {
        for (final m in key.allMatches(text)) {
          final name = m.group(1)!;
          if (name == 'bulkEmpty' || name == 'inputEmpty') continue;
          final before = text.substring(
            (m.start - 300).clamp(0, m.start),
            m.start,
          );
          final inEmptyState =
              before.contains('AppEmptyState(') ||
              // Directly, or one of the texts a choice in the argument
              // picks (no comma: still the same argument).
              RegExp(r'empty(Title|Body):[^,]*$').hasMatch(before);
          if (!inEmptyState) found.add('$path: $name');
        }
      }
      expect(found, isEmpty);
    });

    uiTest('TC-UI-140 logout confirmation follows the design tokens', (
      tester,
      shot,
    ) async {
      final app = await start(tester, profile: Roles.supervisor);
      await app.tap(tab(l10n.tabProfile));
      await app.tap(find.byKey(const Key('profile.logout')));
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect((dialog.title! as Text).data, l10n.logoutConfirmTitle);
      expect(
        drawnStyle(tester, find.text(l10n.logoutConfirmTitle)).fontSize,
        AppTypography.headline.fontSize,
      );
      expect(find.text(l10n.cancel), findsOneWidget);
      await shot('dialog_logout');
    });
    test('TC-UI-141 every icon button has a label', () {
      final missing = [
        for (final (at, args) in callArguments('IconButton'))
          if (!args.contains('tooltip:')) at,
      ];
      expect(missing, isEmpty);
    });
  });

  group('E. Text and fit', () {
    uiTest('TC-UI-142 key screens at font size 2×', (tester, shot) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      var app = await start(tester, loggedIn: false);
      expectFits(tester);
      expectNothingCut(tester, 'login');
      await shot('font2x_login');

      app = await start(tester);
      expectFits(tester);
      expectNothingCut(tester, 'verify');
      await shot('font2x_verify');
      await lookUp(app);
      expectFits(tester);
      expect(find.byType(VerificationResultCard), findsOneWidget);
      expectNothingCut(tester, 'result');
      await shot('font2x_result');

      app = await start(tester);
      await app.tap(tab(l10n.tabHistory));
      expectFits(tester);
      expectNothingCut(tester, 'history');
      await shot('font2x_history');
      await app.tap(tab(l10n.tabProfile));
      expectFits(tester);
      expectNothingCut(tester, 'profile');
      await shot('font2x_profile');
    });

    for (final scale in [1.0, 2.0]) {
      final name = scale == 1 ? 'bn' : 'bn_font2x';
      uiTest('TC-PROF-031 key screens in Bangla at font size ${scale}x', (
        tester,
        shot,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final bn = lookupAppLocalizations(const Locale('bn'));

        var app = await start(tester, loggedIn: false, language: 'bn');
        expect(find.text(bn.loginTitle), findsOneWidget);
        expectFits(tester);
        expectNothingCut(tester, 'login');
        await shot('${name}_login');

        app = await start(tester, language: 'bn');
        expectFits(tester);
        expectNothingCut(tester, 'check');
        await shot('${name}_check');
        await lookUp(app);
        expect(find.byType(VerificationResultCard), findsOneWidget);
        expectFits(tester);
        expectNothingCut(tester, 'result');
        await shot('${name}_result');

        app = await start(tester, language: 'bn');
        await app.tap(tab(bn.tabProfile));
        expectFits(tester);
        expectNothingCut(tester, 'profile');
        await shot('${name}_profile');
      });
    }

    uiTest('TC-UI-143 long texts', (tester, shot) async {
      final longName =
          ('Paracetamol and Caffeine Extended Release Film Coated '
                      'Tablets for Adults ' *
                  4)
              .substring(0, 200);
      var app = await start(
        tester,
        overrides: {
          'POST lookups': always(lookup(product: {'name': longName})),
        },
      );
      await lookUp(app);
      expectFits(tester);
      expect(find.text(longName), findsOneWidget);
      await shot('long_result');

      final longShop = ('Rahim Store and Pharmacy, Mirpur Road, Dhanmondi ' * 3)
          .substring(0, 100);
      app = await start(
        tester,
        profile: Roles.supervisor,
        overrides: {
          'GET retail-users': always(
            ok({
              'retail_users': [
                {'id': '1', 'name': longShop, 'email': 'ra***@gmail.com'},
              ],
              'next_cursor': null,
            }),
          ),
        },
      );
      await openTile(app, const Key('verify.tool.report'));
      await app.tap(find.byKey(const Key('report.retailUser')));
      expectFits(tester);
      await shot('long_retail_users');

      final longNote = ('The seal is cut and the label is blurred. ' * 30)
          .substring(0, 1000);
      app = await start(
        tester,
        overrides: {
          'GET incidents': always(
            ok({
              'reports': [
                {
                  'id': 1042,
                  'at': '2026-11-12T04:30:00Z',
                  'note': longNote,
                  'photos': 3,
                  'check_ref': 'MA-2026-000777',
                  'retail_user': {'id': '1', 'name': longShop},
                },
              ],
              'next_cursor': null,
            }),
          ),
        },
      );
      await openTile(app, const Key('verify.tool.myReports'));
      expectFits(tester);
      await shot('long_my_reports');
    });

    uiTest('TC-UI-144 missing values', (tester, shot) async {
      var app = await start(
        tester,
        overrides: {
          'POST lookups': always(
            lookup(
              product: {'generic_name': null, 'short_name': null},
              batch: {'made': null, 'expires': null},
            ),
          ),
        },
      );
      await lookUp(app);
      expectFits(tester);
      // SRS FR-LKP-06: every field appears; a missing one is blank ("—").
      for (final label in [
        l10n.genericLabel,
        l10n.shortNameLabel,
        l10n.madeLabel,
        l10n.expiresLabel,
      ]) {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('—'), findsNWidgets(4));
      expect(find.text(l10n.batchLabel), findsOneWidget);
      await shot('missing_result');

      app = await start(
        tester,
        overrides: {
          'GET checks': always(
            checks(
              check: {
                'serial': null,
                'product': null,
                'batch': null,
                'reasons': <String>[],
                'result': 'not_found',
              },
            ),
          ),
        },
      );
      await app.tap(tab(l10n.tabHistory));
      expectFits(tester);
      await shot('missing_history');
    });

    uiTest('TC-UI-145 large numbers', (tester, shot) async {
      var app = await start(
        tester,
        overrides: {
          'GET checks': always(
            checks(
              totals: {
                'total': 999999,
                'valid': 999999,
                'warning': 999999,
                'not_found': 999999,
                'unassigned': 999999,
              },
            ),
          ),
        },
      );
      await app.tap(tab(l10n.tabHistory));
      expectFits(tester);
      expect(historyChipCount(tester, 'all'), 999999);
      expect(find.text('999999'), findsNWidgets(5));
      await shot('big_history');

      app = await start(
        tester,
        overrides: {
          'POST lookups': always(
            lookup(
              result: 'warning',
              reasons: const ['checked_before'],
              thisCheck: 99999,
            ),
          ),
        },
      );
      await lookUp(app);
      expectFits(tester);
      expect(find.textContaining('check number 99999'), findsOneWidget);
      await shot('big_result');

      app = await start(tester);
      await openTile(app, const Key('verify.tool.serials'));
      await app.enter(
        const Key('serials.input'),
        List.generate(50, (i) => '${i + 1}').join(','),
      );
      await app.tap(find.byKey(const Key('serials.submit')));
      expectFits(tester);
      expect(find.bySemanticsLabel('Scanned: 50'), findsOneWidget);
      await shot('big_serial_stack');
    });

    uiTest('TC-UI-146 the smallest width', (tester, shot) async {
      Future<void> narrow() async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        await tester.pumpAndSettle();
      }

      await start(tester, loggedIn: false);
      await narrow();
      expectFits(tester);
      await shot('narrow_login');

      final app = await start(
        tester,
        overrides: {
          'POST lookups': always(
            lookup(
              result: 'warning',
              reasons: const ['checked_before', 'expired', 'recalled'],
            ),
          ),
        },
      );
      await narrow();
      await lookUp(app);
      expectFits(tester);
      // checked_before is the badge; expired and recalled are rows.
      expect(find.byType(ReasonChip), findsNWidgets(2));
      await shot('narrow_result_warning');
    });
  });

  test('TC-UI-159 components of §14.1 exist', () {
    final spec = File('final.md').readAsStringSync();
    final table = spec.substring(
      spec.indexOf('### 14.1 Reusable Components'),
      spec.indexOf('### 14.2 UI States'),
    );
    final names = {
      for (final row in table.split('\n').where((l) => l.startsWith('| `')))
        for (final m in RegExp(
          '`([A-Z][A-Za-z]+)(<T>)?`',
        ).allMatches(row.split('|')[1]))
          m.group(1)!,
    };
    expect(names, contains('AppButton'));
    final code = sources().values.join('\n');
    final missing = {
      for (final n in names)
        if (!RegExp('class $n\\b').hasMatch(code)) n,
    };

    // Each component not built by its name is recorded in decision sheet
    // Q20 (built under another name, or not built).
    final sheet = File('docs/decision-sheet.md').readAsStringSync();
    final q20 = sheet.substring(
      sheet.indexOf('### Q20.'),
      sheet.indexOf('### Q21.'),
    );
    expect([
      for (final n in missing)
        if (!q20.contains('`$n`')) n,
    ], isEmpty);
    // And Q20 lists nothing that is built now.
    final listed = RegExp(r'not built \(([^)]*)\)').firstMatch(q20)!.group(1)!;
    final built = [
      for (final m in RegExp('`([A-Za-z]+)`').allMatches(listed))
        if (!missing.contains(m.group(1))) m.group(1),
    ];
    expect(built, isEmpty);
  });
}
