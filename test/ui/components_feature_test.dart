import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/item_details_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/label_value_row.dart';

import '../fakes/roles.dart';
import '../flow/harness.dart';
import 'ui_helpers.dart';

/// Section B, part 2 of docs/test-cases/15-ui.md: the result card, item
/// details, History rows, the bulk views, the retail user picker, and the
/// bottom bar (TC-UI-056 … -074).
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadUiFonts();
  });
  hideFlavourRibbon();
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('result card', () {
    Future<void> card(WidgetTester tester, LookupResult result) => pumpUi(
      tester,
      ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [VerificationResultCard(result: result)],
      ),
    );

    /// The card's fill, round icon, title, and badge as drawn (final.md
    /// Section 13.1.4).
    void expectLook(
      WidgetTester tester, {
      required Color color,
      required Color fill,
      required IconData icon,
      required String title,
      required String badge,
    }) {
      final cardBox = find
          .descendant(
            of: find.byType(VerificationResultCard),
            matching: find.byType(DecoratedBox),
          )
          .first;
      final box =
          tester.widget<DecoratedBox>(cardBox).decoration as BoxDecoration;
      expect(box.color, fill);
      expect(box.borderRadius, AppRadius.card);

      final drawn = tester.widget<Icon>(find.byIcon(icon));
      expect(drawn.color, AppColors.onPrimary);
      expect(drawn.size, 32);
      final circle =
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(
                          of: find.byIcon(icon),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(circle.shape, BoxShape.circle);
      expect(circle.color, color);
      expect(
        tester.getSize(
          find
              .ancestor(
                of: find.byIcon(icon),
                matching: find.byType(DecoratedBox),
              )
              .first,
        ),
        const Size(64, 64),
      );
      // A soft halo of the same colour around the circle (the Figma).
      final halo =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('result.icon.halo')),
                  )
                  .decoration
              as BoxDecoration;
      expect(halo.shape, BoxShape.circle);
      expect(halo.color, color.withValues(alpha: 0.12));
      expect(circle.boxShadow, isNotEmpty);

      final text = drawnStyle(tester, find.text(title));
      expect(text.color, AppColors.textStrong);
      expect(text.fontSize, AppTypography.headline.fontSize);

      final pill = tester.widget<ResultBadge>(find.byType(ResultBadge));
      expect(pill.color, color);
      expect(find.text(badge.toUpperCase()), findsOneWidget);
      expect(
        drawnStyle(tester, find.text(badge.toUpperCase())).color,
        AppColors.onPrimary,
      );
    }

    uiTest('TC-UI-056 result card: valid', (tester, shot) async {
      await card(tester, _result(LookupOutcome.valid));
      expectLook(
        tester,
        color: AppColors.success,
        fill: AppColors.successBackground,
        icon: LucideIcons.shieldCheck,
        title: l10n.resultValidTitle,
        badge: l10n.badgeGenuine,
      );
      expect(find.text(l10n.resultValidBody), findsOneWidget);
      expect(find.byType(ReasonChip), findsNothing);
      await shot('result_valid');
    });

    uiTest('TC-UI-057 result card: warning', (tester, shot) async {
      await card(
        tester,
        _result(
          LookupOutcome.warning,
          reasons: [LookupReason.checkedBefore],
          count: CheckCount(thisCheck: 3, lastAt: DateTime.utc(2026, 11, 10)),
        ),
      );
      expectLook(
        tester,
        color: AppColors.warning,
        fill: AppColors.warningBackground,
        icon: LucideIcons.triangleAlert,
        title: l10n.resultWarningTitle,
        badge: l10n.reasonCheckedBefore,
      );
      // The check number in the card; no row for `checked_before`.
      expect(find.textContaining('check number 3'), findsOneWidget);
      expect(find.byType(ReasonChip), findsNothing);
      await shot('result_warning');
    });

    uiTest('TC-UI-058 result card: not found', (tester, shot) async {
      await card(tester, _result(LookupOutcome.notFound));
      expectLook(
        tester,
        color: AppColors.danger,
        fill: AppColors.dangerBackground,
        icon: LucideIcons.shieldX,
        title: l10n.resultNotFoundTitle,
        badge: l10n.resultNotFoundTitle,
      );
      await shot('result_not_found');
    });

    uiTest('TC-UI-059 result card: not in a batch', (tester, shot) async {
      await card(tester, _result(LookupOutcome.unassigned));
      expectLook(
        tester,
        color: AppColors.textLabel,
        fill: AppColors.surfaceMuted,
        icon: LucideIcons.packageX,
        title: l10n.resultUnassignedTitle,
        badge: l10n.resultUnassignedTitle,
      );
      await shot('result_unassigned');
    });

    uiTest('TC-UI-060 result card: unknown result', (tester, shot) async {
      await card(tester, _result(LookupOutcome.unknown));
      expectLook(
        tester,
        color: AppColors.textLabel,
        fill: AppColors.surfaceMuted,
        icon: LucideIcons.circleHelp,
        title: l10n.resultUnknownTitle,
        badge: l10n.resultUnknownTitle,
      );
      expect(find.byIcon(LucideIcons.shieldCheck), findsNothing);
      expect(find.text(l10n.resultValidTitle), findsNothing);
      expect(find.text(l10n.badgeGenuine.toUpperCase()), findsNothing);
      await shot('result_unknown');
    });

    uiTest('TC-UI-061 result card: every reason', (tester, shot) async {
      await card(
        tester,
        _result(
          LookupOutcome.warning,
          reasons: LookupReason.values,
          count: CheckCount(thisCheck: 4, lastAt: DateTime.utc(2026, 11, 10)),
        ),
      );
      expect(find.text(l10n.reasonCheckedBefore.toUpperCase()), findsOneWidget);
      expect(find.textContaining('check number 4'), findsOneWidget);
      expect(find.byType(ReasonChip), findsNWidgets(5));
      for (final (icon, label) in [
        (LucideIcons.undo2, l10n.reasonRecalled),
        (LucideIcons.calendarX, l10n.reasonExpired),
        (LucideIcons.packageX, l10n.reasonDamaged),
        (LucideIcons.ban, l10n.reasonSwitchedOff),
        (LucideIcons.triangleAlert, l10n.reasonUnknown),
      ]) {
        expect(find.text(label), findsOneWidget);
        final chip = find.ancestor(
          of: find.text(label),
          matching: find.byType(ReasonChip),
        );
        final drawn = tester.widget<Icon>(
          find.descendant(of: chip, matching: find.byType(Icon)),
        );
        expect(drawn.icon, icon);
        expect(drawn.color, AppColors.warning);
      }
      await shot('result_all_reasons');
    });

    uiTest('TC-UI-062 result card: the reference row', (tester, shot) async {
      for (final outcome in LookupOutcome.values) {
        await card(tester, _result(outcome));
        expect(
          find.byWidgetPredicate((w) => w is SelectableText && w.data == _ref),
          findsOneWidget,
          reason: '$outcome',
        );
        expect(find.byIcon(LucideIcons.copy), findsOneWidget);
        // The button says what it does, before anything is copied.
        expect(find.byTooltip(l10n.copyReference), findsOneWidget);
      }
    });
  });

  group('item details', () {
    Future<void> details(WidgetTester tester, {CheckCount? count}) => pumpUi(
      tester,
      ColoredBox(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [ItemDetailsCard(item: _item(), count: count)],
        ),
      ),
      size: const Size(390, 600),
    );

    uiTest('TC-UI-063 product details card', (tester, shot) async {
      await details(tester);
      final title = find.text(l10n.detailsProductTitle.toUpperCase());
      expect(title, findsOneWidget);
      expect(
        drawnStyle(tester, title).fontSize,
        AppTypography.sectionTitle.fontSize,
      );
      for (final (label, value) in [
        (l10n.productLabel, 'Paracetamol 500'),
        (l10n.genericLabel, 'Paracetamol'),
        (l10n.shortNameLabel, 'Napa'),
        (l10n.batchLabel, 'B-1042'),
        (l10n.serialLabel, '1000001'),
        (l10n.codeLabel2, '*****200'),
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
        expect(find.text(value), findsOneWidget, reason: value);
      }
      expect(find.byType(LabelValueRow), findsNWidgets(8));
      // No picture inside: the picture has its own card.
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(LucideIcons.pill), findsNothing);

      // A row: the label on the left in caption, the value on the right.
      final card = tester.getRect(find.byType(ItemDetailsCard));
      final rowLabel = find.text(l10n.batchLabel);
      final value = find.text('B-1042');
      expect(drawnStyle(tester, rowLabel).fontSize, 13);
      expect(drawnStyle(tester, value).fontWeight, FontWeight.w600);
      expect(tester.getRect(rowLabel).left, card.left + AppSpacing.lg);
      expect(
        tester.getRect(value).right,
        moreOrLessEquals(card.right - AppSpacing.lg),
      );
      // At 1 × every label sits beside its value, on the same line.
      expect(
        tester.getRect(find.text(l10n.genericLabel)).top,
        moreOrLessEquals(
          tester.getRect(find.text('Paracetamol')).top,
          epsilon: 4,
        ),
      );
      await shot('details_product');
    });

    // Audit H5: one card for every found item; the check count adds the
    // pill and the previous check, never a field less (SRS FR-LKP-06).
    uiTest('TC-UI-064 details card with the check count', (tester, shot) async {
      await details(
        tester,
        count: CheckCount(
          thisCheck: 3,
          lastAt: DateTime.utc(2026, 11, 10, 4),
        ),
      );
      expect(
        find.text(l10n.detailsProductTitle.toUpperCase()),
        findsOneWidget,
      );
      // Every field, then the previous check.
      expect(find.byType(LabelValueRow), findsNWidgets(9));
      expect(find.text(l10n.shortNameLabel), findsOneWidget);
      final pill = find.text(l10n.checkNumber(3));
      expect(pill, findsOneWidget);
      expect(drawnStyle(tester, pill).color, AppColors.warning);
      expect(find.text(l10n.previousCheckLabel), findsOneWidget);
      expect(find.textContaining('Nov 10, 2026'), findsOneWidget);
      expect(find.text(l10n.checkedByLabel), findsNothing);
      expect(find.text('Asha Rao, Karim'), findsNothing);
      // Never a uses limit (backend D31).
      expect(find.textContaining('/'), findsNothing);
      expect(find.textContaining('uses'), findsNothing);
      await shot('details_tracking');
    });
  });

  group('History rows', () {
    Future<void> tiles(
      WidgetTester tester,
      List<CheckRecord> checks, {
      double height = 844,
    }) => pumpUi(
      tester,
      ColoredBox(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          children: [
            for (final c in checks) CheckTile(check: c),
          ],
        ),
      ),
      size: Size(phone.width, height),
    );

    uiTest('TC-UI-065 history rows: every result badge', (tester, shot) async {
      await tiles(tester, [for (final r in CheckResult.values) _check(r)]);
      for (final r in CheckResult.values) {
        final (label, color) = checkResultStyle(r, l10n);
        final text = find.text(label);
        expect(text, findsOneWidget, reason: '$r');
        expect(drawnStyle(tester, text).color, color);
        final badge =
            tester
                    .widget<DecoratedBox>(
                      find
                          .ancestor(
                            of: text,
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(badge.color, color.withValues(alpha: 0.12));
        expect(
          badge.borderRadius,
          const BorderRadius.all(Radius.circular(AppRadius.pill)),
        );
      }
      await shot('check_tiles');
    });

    uiTest('TC-UI-066 history row without a serial', (tester, shot) async {
      await tiles(tester, [
        _check(CheckResult.notFound, serial: null, product: null, batch: null),
      ], height: 240);
      final title = find.byWidgetPredicate(
        (w) =>
            w is Text && w.data == _ref && w.style == AppTypography.bodyStrong,
      );
      expect(title, findsOneWidget);
      expect(find.textContaining(l10n.batchLabel), findsNothing);
      expect(find.textContaining('Paracetamol'), findsNothing);
    });

    // SRS FR-HIS-04: the session if any; never a checker's name (D61).
    uiTest('TC-UI-067 history row: the session marker', (tester, shot) async {
      await tiles(tester, [_check(CheckResult.valid)], height: 240);
      expect(find.textContaining(l10n.historyInSession), findsNothing);
      expect(find.textContaining('Asha Rao'), findsNothing);
      await tiles(tester, [
        _check(CheckResult.valid, sessionId: '7f3c2a10'),
      ], height: 240);
      expect(find.textContaining(l10n.historyInSession), findsOneWidget);
      await shot('check_tile_session');
    });

    uiTest('TC-UI-068 history row: the way', (tester, shot) async {
      await tiles(tester, [
        for (final w in CheckWay.values) _check(CheckResult.valid, way: w),
      ]);
      for (final (icon, label) in [
        (LucideIcons.qrCode, l10n.wayQr),
        (LucideIcons.hash, l10n.waySerial),
        (LucideIcons.tag, l10n.wayHiddenCode),
      ]) {
        expect(find.byIcon(icon), findsOneWidget);
        expect(find.text(label), findsOneWidget);
        expect(
          tester.widget<Icon>(find.byIcon(icon)).color,
          AppColors.textMuted,
        );
      }
    });
  });

  uiTest('TC-UI-072 retail user picker', (tester, shot) async {
    final app = await startApp(tester);
    await app.tap(find.byKey(const Key('verify.tool.report')));
    await app.tap(find.byKey(const Key('report.retailUser')));
    await atOneX(tester);
    expect(find.byKey(const Key('picker.search')), findsOneWidget);
    expect(find.text('Rahim Store'), findsOneWidget);
    expect(find.text('ra***@gmail.com'), findsOneWidget);
    await shot('picker');
  });

  group('bottom bar', () {
    List<NavigationDestination> destinations(WidgetTester tester) => tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .toList();

    uiTest('TC-UI-073 bottom bar with three tabs', (tester, shot) async {
      await startApp(tester, profile: Roles.fieldInspector);
      await atOneX(tester);
      final tabs = destinations(tester);
      expect(tabs.map((d) => d.label), [
        l10n.tabVerify,
        l10n.tabHistory,
        l10n.tabProfile,
      ]);
      expect(tabs.map((d) => (d.icon as Icon).icon), [
        LucideIcons.shieldCheck,
        LucideIcons.clock,
        LucideIcons.user,
      ]);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 0);
      expect(
        drawnStyle(tester, tab(l10n.tabVerify)).color,
        AppColors.primary,
      );
      expect(
        drawnStyle(tester, find.text(l10n.tabHistory)).color,
        AppColors.textMuted,
      );
      await shot('bar_three_tabs');
    });

    uiTest('TC-UI-074 bottom bar without History', (tester, shot) async {
      await startApp(tester, profile: Roles.retailSellerNoHistory);
      await atOneX(tester);
      expect(destinations(tester).map((d) => d.label), [
        l10n.tabVerify,
        l10n.tabProfile,
      ]);
      expect(find.text(l10n.tabHistory), findsNothing);
      await shot('bar_two_tabs');
    });
  });
}

const _ref = 'MA-2026-000123';

ItemDetails _item({String? pictureUrl}) => ItemDetails(
  serial: '1000001',
  maskedCode: '*****200',
  product: Product(
    name: 'Paracetamol 500',
    genericName: 'Paracetamol',
    shortName: 'Napa',
    pictureUrl: pictureUrl,
  ),
  batch: Batch(
    number: 'B-1042',
    made: DateTime.utc(2025, 1, 10),
    expires: DateTime.utc(2027, 1, 9),
  ),
);

LookupResult _result(
  LookupOutcome outcome, {
  List<LookupReason> reasons = const [],
  CheckCount? count,
}) => LookupResult(
  ref: _ref,
  outcome: outcome,
  reasons: reasons,
  count: count,
  item: outcome == LookupOutcome.valid || outcome == LookupOutcome.warning
      ? _item()
      : null,
);

CheckRecord _check(
  CheckResult result, {
  CheckWay way = CheckWay.qr,
  String? serial = '1000001',
  String? product = 'Paracetamol 500',
  String? batch = 'B-1042',
  String? sessionId,
}) => CheckRecord(
  ref: _ref,
  at: DateTime.utc(2026, 11, 14, 4, 30),
  way: way,
  result: result,
  reasons: result == CheckResult.warning ? const ['checked_before'] : const [],
  official: 'Asha Rao',
  serial: serial,
  product: product,
  batch: batch,
  sessionId: sessionId,
);
