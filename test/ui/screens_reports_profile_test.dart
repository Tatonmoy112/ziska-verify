import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart';
import 'ui_helpers.dart';

/// Section C, part 3 of docs/test-cases/15-ui.md: Report incident, My
/// reports, Retail users, Add retail user, Profile, and the bottom bar in
/// each state, through the flow harness and the fake backend
/// (TC-UI-114 … -133).
void main() {
  setUpAll(loadUiFonts);
  hideFlavourRibbon();
  final l10n = lookupAppLocalizations(const Locale('en'));
  const photosPath = 'incidents/1042/photos';

  Future<FlowApp> start(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, profile: profile, overrides: overrides);
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

  group('Report incident', () {
    /// The report screen's own list (not the Verify list under it).
    Finder reportList(WidgetTester tester) {
      final list = find
          .ancestor(
            of: find.byKey(const Key('report.note')),
            matching: find.byType(Scrollable),
          )
          .last
          .evaluate()
          .single;
      return find.byElementPredicate((e) => identical(e, list));
    }

    /// Scrolls the report list to its end, where File report is built.
    Future<void> toEnd(WidgetTester tester, Finder list) async {
      final button = find.byKey(const Key('report.submit'));
      for (var i = 0; i < 10 && button.evaluate().isEmpty; i++) {
        final position = tester.state<ScrollableState>(list).position;
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
      }
    }

    Future<FlowApp> openReport(
      WidgetTester tester, {
      Map<String, Answer> overrides = const {},
    }) async {
      final app = await start(tester, overrides: overrides);
      await openTile(app, const Key('verify.tool.report'));
      return app;
    }

    Future<void> addPhoto(FlowApp app) async {
      await app.tap(find.byKey(const Key('report.addPhoto')));
      await app.tapText('Choose from gallery');
    }

    uiTest('TC-UI-114 report incident', (tester, shot) async {
      final app = await openReport(tester);
      expect(find.text(l10n.reportWhenNotNeeded), findsOneWidget);
      expect(find.byKey(const Key('report.note')), findsOneWidget);
      expect(find.byKey(const Key('report.retailUser')), findsOneWidget);
      expect(find.byKey(const Key('report.addPhoto')), findsOneWidget);
      await shot('screen_report');
      await toEnd(tester, reportList(tester));
      expect(app.enabled(const Key('report.submit')), isFalse);
    });

    uiTest('TC-UI-115 report incident with links', (tester, shot) async {
      final app = await start(tester);
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await app.tap(find.byKey(const Key('result.report')));
      await app.tap(find.byKey(const Key('report.retailUser')));
      await app.tapText('Rahim Store');
      expect(find.text(l10n.reportCheckLabel), findsWidgets);
      expect(find.textContaining('MA-2026-'), findsWidgets);
      expect(find.text('Rahim Store'), findsOneWidget);
      // Each link can be removed.
      expect(find.byIcon(LucideIcons.x), findsNWidgets(2));
      await shot('screen_report_linked');
    });

    uiTest('TC-UI-116 report filed', (tester, shot) async {
      var n = 0;
      final app = await openReport(
        tester,
        overrides: {
          'POST $photosPath': (_) => switch (n++) {
            0 => ok({'n': 1}, status: 201),
            1 => apiError(500, 'internal_error'),
            _ => apiError(409, 'conflict'),
          },
        },
      );
      final list = reportList(tester);
      for (var i = 0; i < 3; i++) {
        await addPhoto(app);
      }
      await app.enter(const Key('report.note'), 'Seal is cut');
      await toEnd(tester, list);
      await app.tap(find.byKey(const Key('report.submit')));
      expect(find.text(l10n.reportFiled(1042)), findsOneWidget);
      expect(find.text('Photo 1'), findsOneWidget);
      expect(find.text('Not sent. Tap to send again.'), findsOneWidget);
      expect(find.text(l10n.reportPhotoRefused), findsOneWidget);
      expect(find.text(l10n.reportDone), findsOneWidget);
      await shot('screen_report_filed');
    });

    uiTest('TC-UI-117 report: filing failed', (tester, shot) async {
      final app = await openReport(
        tester,
        overrides: {
          'POST incidents': always(
            apiError(404, 'not_found', requestId: 'req-rep'),
          ),
        },
      );
      final list = reportList(tester);
      await app.enter(const Key('report.note'), 'Seal is cut');
      await toEnd(tester, list);
      await app.tap(find.byKey(const Key('report.submit')));
      expect(find.text(l10n.reportNotFound), findsOneWidget);
      expect(find.text('Reference: req-rep'), findsOneWidget);
      await shot('screen_report_error');
    });
  });

  group('My reports', () {
    Map<String, Object?> report(int id) => {
      'id': id,
      'at': '2026-11-1${id % 10}T04:30:00Z',
      'note': 'Seal is cut on box $id',
      'photos': id % 3,
      'check_ref': id.isEven ? 'MA-2026-000$id' : null,
      'retail_user': id.isEven ? {'id': '9d2e', 'name': 'Rahim Store'} : null,
    };

    ScriptedAnswer reports(List<Map<String, Object?>> list) =>
        ok({'reports': list, 'next_cursor': null});

    Future<FlowApp> openMyReports(WidgetTester tester, Answer answer) async {
      final app = await start(tester, overrides: {'GET incidents': answer});
      await openTile(app, const Key('verify.tool.myReports'));
      return app;
    }

    uiTest('TC-UI-118 my reports', (tester, shot) async {
      await openMyReports(
        tester,
        always(reports([report(1042), report(1041), report(1040)])),
      );
      expect(find.textContaining('1042'), findsWidgets);
      expect(find.text('Seal is cut on box 1042'), findsOneWidget);
      expect(find.textContaining('Rahim Store'), findsWidgets);
      expect(find.byKey(const Key('reports.new')), findsOneWidget);
      await shot('screen_my_reports');
    });

    uiTest('TC-UI-119 my reports: empty', (tester, shot) async {
      await openMyReports(tester, always(reports([])));
      expect(find.text(l10n.myReportsEmpty), findsOneWidget);
      await shot('screen_my_reports_empty');
    });

    uiTest('TC-UI-120 my reports: failed', (tester, shot) async {
      await openMyReports(
        tester,
        always(apiError(500, 'internal_error', requestId: 'req-mine')),
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Reference: req-mine'), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);
      await shot('screen_my_reports_error');
    });
  });

  group('Retail users', () {
    Future<FlowApp> openList(
      WidgetTester tester, {
      Map<String, Answer> overrides = const {},
    }) async {
      final app = await start(
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

    Future<void> fill(FlowApp app) async {
      await app.enter(const Key('addRetail.name'), 'Rahim Store');
      await app.enter(const Key('addRetail.email'), 'rahim.store@gmail.com');
      await app.tap(find.byKey(const Key('addRetail.role')));
      await app.tapText('Retail seller');
      await app.enter(const Key('addRetail.password'), '1234567890');
    }

    ScriptedAnswer added({bool? emailed}) => ok({
      'id': 'new-1',
      'name': 'Rahim Store',
      'email': 'rahim.store@gmail.com',
      'email_sent': emailed,
    }, status: 201);

    uiTest('TC-UI-121 retail users', (tester, shot) async {
      await openList(tester);
      expect(find.byKey(const Key('retailUsers.search')), findsOneWidget);
      expect(find.text('Rahim Store'), findsOneWidget);
      expect(find.text('ra***@gmail.com'), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsisVertical), findsWidgets);
      expect(find.byKey(const Key('retailUsers.add')), findsOneWidget);
      await shot('screen_retail_users');
    });

    uiTest('TC-UI-122 retail users: empty', (tester, shot) async {
      await openList(
        tester,
        overrides: {
          'GET retail-users': always(
            ok({'retail_users': <Object?>[], 'next_cursor': null}),
          ),
        },
      );
      expect(find.text(l10n.retailUsersEmpty), findsOneWidget);
      await shot('screen_retail_users_empty');
    });

    uiTest('TC-UI-123 email a new first password: confirm', (
      tester,
      shot,
    ) async {
      final app = await openList(tester);
      await app.tap(find.byIcon(LucideIcons.ellipsisVertical).first);
      await app.tapText('Email a new first password');
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text(l10n.cancel)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Email it')),
        findsOneWidget,
      );
      await shot('screen_retail_confirm');
    });

    uiTest('TC-UI-124 add retail user', (tester, shot) async {
      await openAdd(tester);
      for (final key in [
        'addRetail.name',
        'addRetail.email',
        'addRetail.role',
        'addRetail.password',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
      expect(find.text(l10n.addRetailUserRole), findsWidgets);
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const Key('addRetail.sendEmail')),
      );
      expect(toggle.value, isTrue);
      expect(find.text(l10n.addRetailUserSendEmailOff), findsNothing);
      await shot('screen_add_retail');
    });

    uiTest('TC-UI-125 add retail user: switch off', (tester, shot) async {
      final app = await openAdd(tester);
      await app.tap(find.byKey(const Key('addRetail.sendEmail')));
      final note = find.text(l10n.addRetailUserSendEmailOff);
      expect(note, findsOneWidget);
      expect(drawnStyle(tester, note).color, AppColors.warning);
      await shot('screen_add_retail_off');
    });

    uiTest('TC-UI-126 added: emailed', (tester, shot) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': always(added(emailed: true))},
      );
      await fill(app);
      await app.tap(find.byKey(const Key('addRetail.submit')));
      expect(find.text(l10n.addRetailUserDoneTitle('Rahim Store')), findsOne);
      expect(
        find.text(l10n.addRetailUserEmailed('rahim.store@gmail.com')),
        findsOneWidget,
      );
      expect(find.text(l10n.addAnother), findsOneWidget);
      expect(find.byKey(const Key('addRetail.passwordOnce')), findsNothing);
      await shot('screen_added_emailed');
    });

    uiTest('TC-UI-127 added: password shown once', (tester, shot) async {
      final app = await openAdd(
        tester,
        overrides: {'POST retail-users': always(added())},
      );
      await fill(app);
      await app.tap(find.byKey(const Key('addRetail.submit')));
      expect(find.byKey(const Key('addRetail.passwordOnce')), findsOneWidget);
      expect(find.byTooltip(l10n.copyPassword), findsOneWidget);
      expect(find.text(l10n.addRetailUserFirstLogin), findsOneWidget);
      await shot('screen_added_password');
    });

    uiTest('TC-UI-128 add retail user: no retail role', (tester, shot) async {
      await openAdd(
        tester,
        overrides: {'GET retail-roles': always(ok(<Object?>[]))},
      );
      expect(find.text(l10n.addRetailUserNoRoles), findsOneWidget);
      expect(find.byKey(const Key('addRetail.name')), findsNothing);
      await shot('screen_add_retail_no_roles');
    });

    uiTest('TC-UI-129 add retail user: roles failed', (tester, shot) async {
      await openAdd(
        tester,
        overrides: {
          'GET retail-roles': always(
            apiError(500, 'internal_error', requestId: 'req-roles'),
          ),
        },
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Reference: req-roles'), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);
      await shot('screen_add_retail_roles_error');
    });
  });

  group('Profile', () {
    Future<FlowApp> openProfile(
      WidgetTester tester, {
      Map<String, dynamic>? profile,
      Map<String, Answer> overrides = const {},
    }) async {
      final app = await start(tester, profile: profile, overrides: overrides);
      await app.tap(tab(l10n.tabProfile));
      return app;
    }

    /// The count of the card [label]; `null` for a skeleton.
    String? statCount(WidgetTester tester, String label) {
      final card = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label != null,
        ),
      );
      final text = tester.widget<Semantics>(card.first).properties.label!;
      return text == label ? null : text.substring(label.length + 2);
    }

    Iterable<RequestOptions> countRequests(FlowApp app) => app.backend
        .sent('GET', 'checks')
        .where((r) => '${r.queryParameters['limit']}' == '1');

    uiTest('TC-UI-130 profile', (tester, shot) async {
      final app = await openProfile(tester);
      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
      // The Figma layout: the white identity card reaches up into the navy
      // band; the avatar stands over the card's top edge; the role is a
      // green pill.
      final card = tester.getRect(find.byKey(const Key('profile.identity')));
      final avatar = tester.getRect(find.byKey(const Key('profile.avatar')));
      expect(avatar.top, lessThan(card.top));
      expect(avatar.bottom, greaterThan(card.top));
      expect(card.left, AppSpacing.screen);
      expect(card.right, phone.width - AppSpacing.screen);
      final pill =
          tester
                  .widget<DecoratedBox>(find.byKey(const Key('profile.role')))
                  .decoration
              as BoxDecoration;
      expect(pill.color, AppColors.successBackground);
      // The check counts of the official, asked for once, one check long.
      expect(statCount(tester, l10n.statChecks), '120');
      expect(statCount(tester, l10n.statValid), '80');
      expect(statCount(tester, l10n.statNotVerified), '10');
      expect(countRequests(app), hasLength(1));
      expect(
        countRequests(app).single.queryParameters.keys.toSet(),
        {'limit'},
      );
      expect(drawnStyle(tester, find.text('80')).color, AppColors.success);
      expect(drawnStyle(tester, find.text('10')).color, AppColors.danger);
      expect(find.text(l10n.organisationLabel), findsOneWidget);
      expect(find.text(l10n.changePasswordRow), findsOneWidget);
      // The email fits: the label takes only its own width.
      final email = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text('official@example.com'),
          matching: find.byType(RichText),
        ),
      );
      expect(email.didExceedMaxLines, isFalse);
      await shot('screen_profile');
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.logout')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text(l10n.appVersionRow), findsOneWidget);
      expect(find.byKey(const Key('profile.logout')), findsOneWidget);
    });

    uiTest('TC-UI-175 profile: counts loading', (tester, shot) async {
      await openProfile(
        tester,
        overrides: {
          'GET checks': slow(
            (_) =>
                FakeBackend.example(200, 'History of checks', '200 First page'),
            const Duration(seconds: 3),
          ),
        },
      );
      // Grey bars in the cards, no numbers yet.
      expect(statCount(tester, l10n.statChecks), isNull);
      expect(find.text('120'), findsNothing);
      await shot('screen_profile_stats_loading');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(statCount(tester, l10n.statChecks), '120');
    });

    uiTest('TC-UI-176 profile: counts failed, then Try again', (
      tester,
      shot,
    ) async {
      var calls = 0;
      final app = await openProfile(
        tester,
        overrides: {
          'GET checks': (r) async => calls++ == 0
              ? apiError(500, 'internal_error')
              : FakeBackend.example(200, 'History of checks', '200 First page'),
        },
      );
      expect(find.byKey(const Key('profile.stats.failed')), findsOneWidget);
      expect(find.text(l10n.statsFailed), findsOneWidget);
      expect(find.byKey(const Key('profile.stats')), findsNothing);
      await shot('screen_profile_stats_failed');
      await app.tap(
        find.descendant(
          of: find.byKey(const Key('profile.stats.failed')),
          matching: find.text(l10n.retry),
        ),
      );
      expect(statCount(tester, l10n.statChecks), '120');
    });

    uiTest('TC-UI-177 profile: counts again when the tab comes back', (
      tester,
      _,
    ) async {
      final app = await openProfile(tester);
      expect(countRequests(app), hasLength(1));
      await app.tap(tab(l10n.tabVerify));
      await app.tap(tab(l10n.tabProfile));
      expect(countRequests(app), hasLength(2));
    });

    uiTest('TC-UI-178 profile without History: no counts', (tester, _) async {
      final app = await openProfile(
        tester,
        profile: Roles.retailSellerNoHistory,
      );
      expect(find.byKey(const Key('profile.stats')), findsNothing);
      expect(find.byKey(const Key('profile.stats.failed')), findsNothing);
      expect(find.text(l10n.statChecks), findsNothing);
      expect(app.backend.sent('GET', 'checks'), isEmpty);
    });

    uiTest('TC-UI-131 profile: support not set', (tester, shot) async {
      await openProfile(tester, profile: Roles.noSupport);
      await tester.scrollUntilVisible(
        find.text(l10n.supportNotSet).first,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text(l10n.supportNotSet), findsWidgets);
      await shot('screen_profile_no_support');
    });

    uiTest('TC-UI-132 profile: log out confirm', (tester, shot) async {
      final app = await openProfile(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.logout')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await app.tap(find.byKey(const Key('profile.logout')));
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text(l10n.logoutConfirmTitle), findsOneWidget);
      expect(find.text(l10n.logoutConfirmBody), findsOneWidget);
      final logOut = tester.widget<TextButton>(
        find.ancestor(
          of: find.descendant(of: dialog, matching: find.text(l10n.logout)),
          matching: find.byType(TextButton),
        ),
      );
      expect(logOut.style!.foregroundColor!.resolve({}), AppColors.danger);
      await shot('screen_profile_logout');
    });
  });

  uiTest('TC-UI-133 the bar on every tab', (tester, shot) async {
    final app = await start(tester);
    final heights = <double>{};
    for (final (i, label) in [
      l10n.tabVerify,
      l10n.tabHistory,
      l10n.tabProfile,
    ].indexed) {
      await app.tap(tab(label));
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, i, reason: label);
      expect(drawnStyle(tester, tab(label)).color, AppColors.primary);
      heights.add(tester.getSize(find.byType(NavigationBar)).height);
    }
    expect(heights, hasLength(1));
  });
}
