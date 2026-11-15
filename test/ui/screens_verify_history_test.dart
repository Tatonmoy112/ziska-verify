import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/bulk_results_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/item_details_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/product_picture_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/result_entry_cards.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_frame.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/chips/count_chip.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart';
import 'ui_helpers.dart';

/// Section C, part 2 of docs/test-cases/15-ui.md: Verify, the scanner, the
/// result, Bulk lookup, and History in each state, through the flow harness
/// and the fake backend (TC-UI-087 … -113).
void main() {
  setUpAll(loadUiFonts);
  hideFlavourRibbon();
  final l10n = lookupAppLocalizations(const Locale('en'));
  final input = find.byKey(const Key('verify.input'));

  /// The app at 1 ×, before anything slow is asked, so a loading state can
  /// be caught (`atOneX` waits for everything to settle).
  Future<FlowApp> start(
    WidgetTester tester, {
    Map<String, dynamic>? profile,
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, profile: profile, overrides: overrides);
    await atOneX(tester);
    return app;
  }

  /// A few frames, as a loading screen shows while its request runs.
  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Lets a slow answer arrive and the screen settle.
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  bool loading() =>
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
      find
          .byWidgetPredicate(
            (w) => w.runtimeType.toString().startsWith('Skeleton'),
          )
          .evaluate()
          .isNotEmpty;

  /// A `POST lookups` answer (app API guide §4.2).
  ScriptedAnswer lookup(
    String result, {
    List<String> reasons = const [],
  }) => ok({
    'ref': 'MA-2026-000777',
    'result': result,
    'reasons': reasons,
    if (result == 'valid' || result == 'warning') ...{
      'count': {'this_check': 3, 'last_at': '2026-11-10T04:00:00Z'},
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
    },
  });

  Future<FlowApp> lookUp(
    WidgetTester tester,
    Answer answer, {
    Map<String, dynamic>? profile,
    String serial = '1000001',
  }) async {
    final app = await start(
      tester,
      profile: profile,
      overrides: {'POST lookups': answer},
    );
    await app.enter(const Key('verify.input'), serial);
    await app.tap(find.byKey(const Key('verify.submit')));
    return app;
  }

  group('Verify tab', () {
    uiTest('TC-UI-087 verify tab, every tile', (tester, shot) async {
      await start(tester, profile: Roles.supervisor);
      expect(find.text(l10n.welcomeBack), findsOneWidget);
      expect(find.text('Karim Supervisor'), findsOneWidget);
      expect(find.byIcon(LucideIcons.user), findsWidgets);
      expect(find.text(l10n.verifyItemTitle), findsOneWidget);
      expect(find.byType(SegmentedButton<Object?>), findsNothing);
      expect(find.text(l10n.waySerial), findsOneWidget);
      expect(find.text(l10n.wayHiddenCode), findsOneWidget);
      expect(input, findsOneWidget);
      expect(find.text(l10n.verifyButtonLookup), findsOneWidget);
      expect(find.text(l10n.clear), findsOneWidget);
      expect(find.byKey(const Key('verify.scan')), findsOneWidget);
      // The Figma's decoration: a faint honeycomb in the header and a large
      // QR corner on the Scan card, both hidden from TalkBack.
      final pattern = tester.widget<PatternBackground>(
        find.byKey(const Key('verify.header.pattern')),
      );
      expect(pattern.kind, PatternKind.hexagons);
      expect(pattern.color, AppColors.onPrimaryFaint);
      final motif = find.byKey(const Key('verify.scan.motif'));
      expect(
        find.ancestor(
          of: motif,
          matching: find.byKey(const Key('verify.scan')),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: motif, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
      // The serial's # and the hidden code's tag (the Figma "Label ID").
      Finder fieldIcon(IconData icon) => find.descendant(
        of: find.byKey(const Key('verify.input')),
        matching: find.byIcon(icon),
      );
      expect(fieldIcon(LucideIcons.hash), findsOneWidget);
      await tester.tap(find.text(l10n.wayHiddenCode));
      await tester.pumpAndSettle();
      expect(fieldIcon(LucideIcons.tag), findsOneWidget);
      await tester.tap(find.text(l10n.waySerial));
      await tester.pumpAndSettle();
      await shot('screen_verify_all');
      await expectRole(
        tester,
        history: true,
        lookupForm: true,
        tileNames: tiles.keys.toSet(),
      );
    });

    uiTest('TC-UI-088 verify tab, no features', (tester, shot) async {
      await start(tester, profile: Roles.trainee);
      expect(find.text(l10n.welcomeBack), findsOneWidget);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text(l10n.noFeaturesTitle), findsOneWidget);
      expect(input, findsNothing);
      expect(find.byKey(const Key('verify.scan')), findsNothing);
      await shot('screen_verify_none');
    });

    uiTest('TC-UI-089 verify tab: formats loading', (tester, shot) async {
      var calls = 0;
      final formats = FakeBackend.example(
        200,
        'Input formats',
        '200 The formats',
      );
      await start(
        tester,
        overrides: {
          'GET formats': (r) async {
            if (calls++ == 0) return apiError(500, 'internal_error');
            await Future<void>.delayed(const Duration(seconds: 3));
            return formats;
          },
        },
      );
      await tester.tap(find.text(l10n.retry));
      await frames(tester);
      final spinner = find.byType(CircularProgressIndicator);
      expect(spinner, findsOneWidget);
      expect(tester.getCenter(spinner).dx, phone.width / 2);
      expect(input, findsNothing);
      await shot('screen_verify_formats_loading');
      await finish(tester);
      expect(input, findsOneWidget);
    });

    uiTest('TC-UI-090 verify tab: formats failed', (tester, shot) async {
      await start(
        tester,
        overrides: {
          'GET formats': always(
            apiError(500, 'internal_error', requestId: 'req-formats'),
          ),
        },
      );
      expect(find.textContaining(l10n.formatsFailed), findsOneWidget);
      expect(find.text('Reference: req-formats'), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);
      await shot('screen_verify_formats_failed');
    });

    uiTest('TC-UI-091 verify tab: input refused', (tester, shot) async {
      final app = await start(tester);
      await app.enter(const Key('verify.input'), '1' * 20);
      await app.tap(find.byKey(const Key('verify.submit')));
      const message = 'A serial has digits only, up to 19 digits.';
      expect(find.text(message), findsOneWidget);
      expect(drawnStyle(tester, find.text(message)).color, AppColors.danger);
      expect(
        tester.getRect(find.text(message)).top,
        greaterThan(tester.getRect(input).top),
      );
      expect(app.backend.sent('POST', 'lookups'), isEmpty);
      await shot('screen_verify_refused');
    });

    uiTest('TC-UI-092 verify tab: rate limited', (tester, shot) async {
      await lookUp(
        tester,
        always(apiError(429, 'rate_limited', retryAfter: 30, requestId: 'r')),
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.textContaining('Too many attempts'), findsOneWidget);
      expect(
        tester.getRect(find.byType(ErrorBanner)).top,
        greaterThan(tester.getRect(input).bottom),
      );
      await shot('screen_verify_limited');
    });

    uiTest('TC-UI-093 verify tab: app being prepared', (tester, shot) async {
      await lookUp(tester, always(apiError(503, 'app_preparing')));
      expect(find.text(l10n.errorPreparing), findsOneWidget);
      await shot('screen_verify_preparing');
    });
  });

  group('Scanner', () {
    uiTest('TC-UI-094 scanner', (tester, shot) async {
      final app = await start(tester);
      await app.tap(find.byKey(const Key('verify.scan')));
      expect(find.byKey(const Key('fake.camera')), findsOneWidget);
      expect(find.text(l10n.scanQrTitle), findsOneWidget);
      expect(
        find.byTooltip(const DefaultMaterialLocalizations().backButtonTooltip),
        findsOneWidget,
      );
      // Hint above the frame, status below it, the bar at the bottom.
      final hint = tester.getRect(find.byKey(const Key('scanner.hint')));
      final frame = tester.getRect(find.byKey(const Key('scanner.frame')));
      final status = tester.getRect(find.byKey(const Key('scanner.status')));
      final bar = tester.getRect(
        find.byKey(const Key('scanner.enterManually')),
      );
      expect(find.text(l10n.scanFrameHint.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.scanLooking), findsOneWidget);
      expect(hint.bottom, lessThan(frame.top));
      expect(status.top, greaterThan(frame.bottom));
      expect(bar.top, greaterThan(status.bottom));
      expect(frame.width, frame.height);
      expect(frame.center.dx, moreOrLessEquals(phone.width / 2));
      // One torch, in the bottom bar.
      expect(find.byTooltip(l10n.torch), findsOneWidget);
      expect(
        tester.getRect(find.byTooltip(l10n.torch)).top,
        greaterThan(status.bottom),
      );
      await shot('screen_scanner');
    });

    uiTest('TC-UI-095 scanner: camera refused', (tester, shot) async {
      final app = await start(tester);
      app.scanner.problem = ScannerProblem.permissionDenied;
      await app.tap(find.byKey(const Key('verify.scan')));
      expect(find.text(l10n.scannerPermissionDenied), findsOneWidget);
      expect(find.text(l10n.openSettings), findsOneWidget);
      // Nothing is drawn over the message: no frame, no camera hint.
      expect(find.byKey(const Key('scanner.hint')), findsNothing);
      expect(find.byKey(const Key('scanner.frame')), findsNothing);
      expect(find.byKey(const Key('scanner.status')), findsNothing);
      // Typing is still one tap away; there is no torch without a camera.
      expect(find.byKey(const Key('scanner.enterManually')), findsOneWidget);
      expect(find.byTooltip(l10n.torch), findsNothing);
      await shot('screen_scanner_denied');
    });

    uiTest('TC-UI-172 scanner: enter manually', (tester, _) async {
      final app = await start(tester);
      await app.tap(find.byKey(const Key('verify.scan')));
      await app.tap(find.byKey(const Key('scanner.enterManually')));
      expect(find.byKey(const Key('fake.camera')), findsNothing);
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('verify.input')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.focusNode.hasFocus, isTrue);
    });

    uiTest('TC-UI-173 scanner: the torch', (tester, _) async {
      final app = await start(tester);
      await app.tap(find.byKey(const Key('verify.scan')));
      await app.tap(find.byTooltip(l10n.torch));
      expect(app.scanner.session!.torchToggles, 1);
      await app.tap(find.byTooltip(l10n.torch));
      expect(app.scanner.session!.torchToggles, 2);
    });

    testWidgets('TC-UI-174 the scan line moves, and holds still when '
        'animations are off', (tester) async {
      double line() =>
          (tester
                      .widget<CustomPaint>(
                        find.descendant(
                          of: find.byType(ScanFrame),
                          matching: find.byType(CustomPaint),
                        ),
                      )
                      .painter!
                  as ScanFramePainter)
              .line;

      await pumpUi(tester, const ScanFrame(size: 240), settle: false);
      final first = line();
      await tester.pump(ScanFrame.sweep ~/ 4);
      expect(line(), isNot(first), reason: 'the line moves');

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      expect(line(), 0.5);
      await tester.pump(ScanFrame.sweep ~/ 4);
      expect(line(), 0.5, reason: 'holds still in the middle');
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Result', () {
    uiTest('TC-UI-096 result: genuine', (tester, shot) async {
      await lookUp(tester, always(lookup('valid')));
      expect(find.text(l10n.resultValidTitle), findsOneWidget);
      expect(find.byType(VerificationResultCard), findsOneWidget);
      expect(find.byType(ItemDetailsCard), findsOneWidget);
      expect(find.text('MA-2026-000777'), findsOneWidget);
      expect(
        find.text(l10n.detailsProductTitle.toUpperCase()),
        findsOneWidget,
      );
      await shot('screen_result_valid');
      await tester.scrollUntilVisible(
        find.text(l10n.verifyAnother),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // The order: details, the picture, then the actions.
      expect(find.byType(ProductPictureCard), findsOneWidget);
      expect(
        tester.getRect(find.byType(ProductPictureCard)).bottom,
        lessThan(tester.getRect(find.byKey(const Key('result.report'))).top),
      );
      expect(find.byKey(const Key('result.report')), findsOneWidget);
      expect(find.text(l10n.verifyAnother), findsOneWidget);
    });

    uiTest('TC-UI-097 result: needs attention', (tester, shot) async {
      await lookUp(
        tester,
        always(
          lookup(
            'warning',
            reasons: const [
              'checked_before',
              'recalled',
              'expired',
              'damaged',
              'switched_off',
            ],
          ),
        ),
      );
      expect(find.text(l10n.resultWarningTitle), findsOneWidget);
      // checked_before is the badge; the 4 other reasons are rows.
      expect(find.text(l10n.reasonCheckedBefore.toUpperCase()), findsOneWidget);
      expect(find.byType(ReasonChip), findsNWidgets(4));
      expect(
        find.text(l10n.detailsTrackingTitle.toUpperCase()),
        findsOneWidget,
      );
      expect(find.byType(ItemDetailsCard), findsOneWidget);
      await shot('screen_result_warning');
    });

    uiTest('TC-UI-166 result: checked before', (tester, shot) async {
      await lookUp(
        tester,
        always(
          ok({
            'ref': 'MA-2026-000778',
            'result': 'warning',
            'reasons': ['checked_before'],
            'count': {'this_check': 2, 'last_at': '2026-11-10T04:36:00Z'},
            'item': {
              'serial': '1000001',
              'code': '*****7K2',
              'product': {
                'name': 'Paracetamol 500',
                'generic_name': 'Paracetamol',
                'short_name': 'PCM500',
                'picture_url': 'https://pictures.example.com/53/9f2c.png',
              },
              'batch': {
                'number': 'B-1042',
                'made': '2026-01-10',
                'expires': '2027-09-30',
              },
            },
          }),
        ),
      );
      expect(find.text(l10n.reasonCheckedBefore.toUpperCase()), findsOneWidget);
      expect(find.byType(ReasonChip), findsNothing);
      expect(find.textContaining('check number 2'), findsOneWidget);
      // Backend D16, D31: no uses limit, no network address.
      expect(find.textContaining('uses'), findsNothing);
      expect(find.textContaining('IP'), findsNothing);
      await shot('screen_result_checked_before');
      await tester.scrollUntilVisible(
        find.byType(ProductPictureCard),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text(l10n.detailsTrackingTitle.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(l10n.checkNumber(2)), findsOneWidget);
      expect(find.text(l10n.previousCheckLabel), findsOneWidget);
    });

    uiTest('TC-UI-098 result: not found', (tester, shot) async {
      await lookUp(tester, always(lookup('not_found')));
      // The title, and the result row of WHAT YOU ENTERED.
      expect(find.text(l10n.resultNotFoundTitle), findsNWidgets(2));
      expect(find.byType(ItemDetailsCard), findsNothing);
      // TC-LOOK-115: no item, no picture card.
      expect(find.byType(ProductPictureCard), findsNothing);
      expect(find.byType(EnteredCard), findsOneWidget);
      expect(find.text('MA-2026-000777'), findsNWidgets(2));
      await shot('screen_result_not_found');
      await tester.scrollUntilVisible(
        find.byKey(const Key('result.backToVerify')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(HintsCard), findsOneWidget);
      expect(find.byKey(const Key('result.tryAgain')), findsOneWidget);
      expect(find.byKey(const Key('result.contactSupport')), findsOneWidget);
      expect(find.text(l10n.verifyAnother), findsNothing);
    });

    uiTest('TC-UI-099 result: not in a batch', (tester, shot) async {
      await lookUp(tester, always(lookup('unassigned')));
      expect(find.text(l10n.resultUnassignedTitle), findsNWidgets(2));
      expect(find.byType(ItemDetailsCard), findsNothing);
      expect(find.byType(ProductPictureCard), findsNothing);
      expect(find.byType(EnteredCard), findsOneWidget);
      await shot('screen_result_unassigned');
      await tester.scrollUntilVisible(
        find.byKey(const Key('result.backToVerify')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // The item exists: no typing hints.
      expect(find.byType(HintsCard), findsNothing);
    });

    uiTest('TC-UI-165 the verification loader', (tester, shot) async {
      final app = await start(
        tester,
        overrides: {'POST lookups': slow(always(lookup('valid')))},
      );
      await app.enter(const Key('verify.input'), '1000001');
      await tester.tap(find.byKey(const Key('verify.submit')));
      await tester.pump();
      // The loader appears at 300 ms; then its arc moves for a moment.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VerifyingView), findsOneWidget);
      expect(find.text(l10n.verifyingTitle), findsOneWidget);
      expect(find.text(l10n.verifyingBody), findsOneWidget);
      for (final step in [
        l10n.stepCodeFormat,
        l10n.stepItemRecord,
        l10n.stepCheckCount,
      ]) {
        expect(find.text(step), findsOneWidget, reason: step);
      }
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      // The Figma marks: a filled navy shield; a filled green circle with a
      // white tick for the done step; a navy dot for the waiting ones.
      expect(find.byKey(const Key('verifying.shield')), findsOneWidget);
      final done =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byKey(const Key('verifying.step.done')),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(done.color, AppColors.success);
      expect(
        find.byKey(const Key('verifying.step.waiting')),
        findsNWidgets(2),
      );
      await shot('screen_verifying');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(VerifyingView), findsNothing);
    });

    uiTest('TC-UI-167 result screens at 2× and 320 px', (tester, shot) async {
      /// Nothing drawn past an edge and no text ending with "…".
      void expectFits(String screen) {
        expect(tester.takeException(), isNull, reason: screen);
        final cut = [
          for (final e in find.byType(RichText).evaluate())
            if (e.renderObject case final RenderParagraph p
                when p.attached && p.didExceedMaxLines)
              p.text.toPlainText(),
        ];
        expect(cut, isEmpty, reason: screen);
      }

      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await lookUp(tester, always(lookup('valid')));
      expectFits('genuine at 2×');
      await shot('font2x_result_valid');
      tester.platformDispatcher.clearTextScaleFactorTestValue();

      final app = await start(
        tester,
        overrides: {'POST lookups': always(lookup('not_found'))},
      );
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      expectFits('not found at 320 px');
      await shot('narrow_result_not_found');
      for (final card in [EnteredCard, HintsCard]) {
        await tester.scrollUntilVisible(
          find.byType(card),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expectFits('not found at 320 px, $card');
      }
    });

    uiTest('TC-UI-168 a low-emphasis button stands out on its screen', (
      tester,
      shot,
    ) async {
      /// The tonal button's box differs from the screen behind it: its fill
      /// on a grey screen, its border on a white one.
      void expectVisible(Finder button, String screen) {
        final style = tester
            .widget<FilledButton>(
              find.descendant(of: button, matching: find.byType(FilledButton)),
            )
            .style!;
        final fill = style.backgroundColor!.resolve({})!;
        final side = style.side!.resolve({})!;
        final scaffold = find.ancestor(
          of: button,
          matching: find.byType(Scaffold),
        );
        final behind =
            tester.widget<Scaffold>(scaffold.first).backgroundColor ??
            AppColors.background;
        expect(
          fill != behind || (side.width > 0 && side.color != behind),
          isTrue,
          reason: '$screen: fill $fill, border $side, screen $behind',
        );
        expect(side.width, greaterThan(0), reason: screen);
      }

      final tonal = find.byWidgetPredicate(
        (w) => w is AppButton && w.variant == AppButtonVariant.tonal,
      );

      // The not-found result: a grey screen.
      await lookUp(tester, always(lookup('not_found')));
      await tester.scrollUntilVisible(
        find.byKey(const Key('result.backToVerify')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expectVisible(find.byKey(const Key('result.backToVerify')), 'not found');
      await shot('screen_result_not_found_actions');

      // Request access: a grey screen.
      var app = await startApp(tester, loggedIn: false);
      await atOneX(tester);
      await app.tapText(l10n.requestAccessButton);
      await tester.scrollUntilVisible(
        tonal,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expectVisible(tonal, 'request access');

      // Check your email: a white screen.
      app = await startApp(tester, loggedIn: false);
      await atOneX(tester);
      await logInToCode(app);
      expectVisible(tonal, 'check your email');
    });

    uiTest('TC-UI-100 result without the Report button', (tester, shot) async {
      await lookUp(tester, always(lookup('valid')), profile: Roles.auditor);
      await tester.scrollUntilVisible(
        find.text(l10n.verifyAnother),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('result.report')), findsNothing);
      expect(find.byType(ItemDetailsCard), findsOneWidget);
      expect(find.text(l10n.verifyAnother), findsOneWidget);
    });
  });

  group('Bulk lookup', () {
    Map<String, Object?> row(String result, {List<String> reasons = const []}) {
      final full =
          (lookup(result, reasons: reasons).body as Map)['data']
              as Map<String, Object?>;
      return full;
    }

    ScriptedAnswer bulk(List<Map<String, Object?>> rows) {
      int count(String r) => rows.where((x) => x['result'] == r).length;
      return ok({
        'summary': {
          'total': rows.length,
          'valid': count('valid'),
          'warning': count('warning'),
          'by_reason': {
            'checked_before': rows
                .where(
                  (x) => (x['reasons']! as List).contains('checked_before'),
                )
                .length,
          },
          'not_found': count('not_found'),
          'unassigned': count('unassigned'),
        },
        'results': rows,
      });
    }

    final threeRows = bulk([
      row('valid'),
      row('warning', reasons: const ['checked_before']),
      row('not_found'),
    ]);

    Future<FlowApp> openBulk(
      WidgetTester tester, {
      Map<String, Answer> overrides = const {},
    }) async {
      final app = await start(tester, overrides: overrides);
      await app.tap(find.byKey(const Key('verify.tool.bulk')));
      return app;
    }

    Future<void> addThree(FlowApp app) async {
      for (final s in ['1000001', '1000002', '1000003']) {
        await app.enter(const Key('bulk.input'), s);
        await app.tap(find.byKey(const Key('bulk.add')));
      }
    }

    uiTest('TC-UI-101 bulk lookup: empty', (tester, shot) async {
      final app = await openBulk(tester);
      expect(find.text(l10n.waySerial), findsOneWidget);
      expect(find.byKey(const Key('bulk.input')), findsOneWidget);
      expect(find.byKey(const Key('bulk.add')), findsOneWidget);
      expect(find.byKey(const Key('bulk.scan')), findsOneWidget);
      expect(find.text(l10n.bulkEmpty), findsOneWidget);
      expect(find.text(l10n.bulkCount(0, 500)), findsWidgets);
      expect(app.enabled(const Key('bulk.send')), isFalse);
      await shot('screen_bulk_empty');
    });

    uiTest('TC-UI-102 bulk lookup: a list', (tester, shot) async {
      final app = await openBulk(tester);
      await addThree(app);
      expect(find.text(l10n.bulkCount(3, 500)), findsWidgets);
      expect(find.text(l10n.bulkClearList), findsOneWidget);
      for (final s in ['1000001', '1000002', '1000003']) {
        expect(find.text(s), findsOneWidget);
      }
      expect(find.text(l10n.bulkSend(3)), findsOneWidget);
      await shot('screen_bulk_list');
    });

    uiTest('TC-UI-103 bulk lookup: sending', (tester, shot) async {
      final app = await openBulk(
        tester,
        overrides: {
          'POST lookups/bulk': slow(
            always(threeRows),
            const Duration(seconds: 3),
          ),
        },
      );
      await addThree(app);
      final semantics = tester.ensureSemantics();
      await tester.tap(find.byKey(const Key('bulk.send')));
      await frames(tester);
      // The send bar shows a spinner; a screen reader hears what it does.
      expect(find.bySemanticsLabel(l10n.bulkSending(3)), findsOneWidget);
      expect(loading(), isTrue);
      semantics.dispose();
      await shot('screen_bulk_sending');
      await finish(tester);
      expect(find.byType(BulkSummaryCard), findsOneWidget);
    });

    uiTest('TC-UI-104 bulk lookup: results', (tester, shot) async {
      final app = await openBulk(
        tester,
        overrides: {'POST lookups/bulk': always(threeRows)},
      );
      await addThree(app);
      await app.tap(find.byKey(const Key('bulk.send')));
      expect(find.byType(BulkSummaryCard), findsOneWidget);
      expect(find.byKey(const Key('bulk.onlyAttention')), findsOneWidget);
      expect(find.text(l10n.bulkNewList), findsOneWidget);
      for (final t in ['1. 1000001', '2. 1000002', '3. 1000003']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      await shot('screen_bulk_results');
    });

    uiTest('TC-UI-105 bulk lookup: only items needing attention', (
      tester,
      shot,
    ) async {
      final app = await openBulk(
        tester,
        overrides: {'POST lookups/bulk': always(threeRows)},
      );
      await addThree(app);
      await app.tap(find.byKey(const Key('bulk.send')));
      await app.tap(find.byKey(const Key('bulk.onlyAttention')));
      expect(find.text('1. 1000001'), findsNothing);
      expect(find.text('2. 1000002'), findsOneWidget);
      expect(find.text('3. 1000003'), findsOneWidget);
      await shot('screen_bulk_attention');
    });

    uiTest('TC-UI-106 bulk lookup: nothing checked', (tester, shot) async {
      final app = await openBulk(
        tester,
        overrides: {
          'POST lookups/bulk': always(
            apiError(503, 'service_unavailable', requestId: 'req-bulk'),
          ),
        },
      );
      await addThree(app);
      await app.tap(find.byKey(const Key('bulk.send')));
      expect(find.textContaining(l10n.bulkNothingChecked), findsOneWidget);
      expect(find.text(l10n.bulkSendAgain), findsOneWidget);
      // The list is kept, ready to send again.
      expect(find.text('1000001'), findsOneWidget);
      await shot('screen_bulk_503');
    });
  });

  group('History', () {
    Future<void> openHistory(FlowApp app) => app.tap(tab(l10n.tabHistory));

    uiTest('TC-UI-107 history: loading', (tester, shot) async {
      // Only the first page is slow: the next pages answer at once.
      var calls = 0;
      await start(
        tester,
        overrides: {
          'GET checks': (r) async {
            if (calls++ == 0) {
              await Future<void>.delayed(const Duration(seconds: 3));
            }
            return FakeBackend.example(
              200,
              'History of checks',
              '200 A later page',
            );
          },
        },
      );
      await tester.tap(tab(l10n.tabHistory));
      await frames(tester);
      expect(find.byKey(const Key('history.search')), findsOneWidget);
      expect(find.byKey(const Key('history.filters')), findsOneWidget);
      expect(loading(), isTrue);
      await shot('screen_history_loading');
      await finish(tester);
    });

    uiTest('TC-UI-108 history: rows and totals', (tester, shot) async {
      final app = await start(tester);
      await openHistory(app);
      expect(find.byKey(const Key('history.search')), findsOneWidget);
      // The result chips with their counts, All chosen: navy, white text.
      expectHistoryChipCounts(tester);
      final all = tester.widget<CountChip>(
        find.byKey(const Key('history.chip.all')),
      );
      expect(all.selected, isTrue);
      expect(
        tester
            .widget<Material>(
              find
                  .descendant(
                    of: find.byKey(const Key('history.chip.all')),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .color,
        AppColors.primary,
      );
      // Chips under the search, starting at the screen side.
      final search = tester.getRect(find.byKey(const Key('history.filters')));
      final chip = tester.getRect(find.byKey(const Key('history.chip.all')));
      expect(chip.top, greaterThan(search.bottom));
      expect(chip.left, AppSpacing.screen);
      // A row: the serial and its badge; batch, day, and time; the grey
      // sentence; the way and the reference.
      final tile = find.byType(CheckTile).first;
      expect(
        find.descendant(
          of: tile,
          matching: find.byKey(const Key('checkTile.sentence')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tile,
          matching: find.textContaining('Batch B-1042'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('checkTile.number')), findsNothing);
      expect(find.textContaining('by '), findsNothing);
      await shot('screen_history');
    });

    uiTest('TC-UI-109 history: empty', (tester, shot) async {
      final app = await start(
        tester,
        overrides: {
          'GET checks': (_) =>
              FakeBackend.example(200, 'History of checks', '200 A later page'),
        },
      );
      await openHistory(app);
      expect(find.text(l10n.historyEmptyTitle), findsOneWidget);
      expect(find.text(l10n.historyEmptyBody), findsOneWidget);
      await shot('screen_history_empty');
    });

    uiTest('TC-UI-110 history: failed', (tester, shot) async {
      final app = await start(
        tester,
        overrides: {
          'GET checks': always(
            apiError(500, 'internal_error', requestId: 'req-hist'),
          ),
        },
      );
      await openHistory(app);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Reference: req-hist'), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);
      await shot('screen_history_error');
    });

    uiTest('TC-UI-111 history: filters', (tester, shot) async {
      final app = await start(tester, profile: Roles.supervisor);
      await openHistory(app);
      await app.tap(find.byKey(const Key('history.filters')));
      for (final t in [
        l10n.bulkValid,
        l10n.bulkWarning,
        l10n.bulkNotFound,
        l10n.wayQr,
        l10n.waySerial,
        l10n.historyPickDates,
        l10n.historyScopeAll,
        l10n.historyApply,
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      await shot('screen_history_filters');
    });

    uiTest('TC-UI-112 history: item tracking', (tester, shot) async {
      final app = await start(tester);
      await openHistory(app);
      await app.enter(const Key('history.search'), '1000001');
      await app.settleAfter(const Duration(milliseconds: 500));
      expectTrackingLog('1000001');
      // The item card, then the log title, then the numbered checks.
      final card = tester.getRect(find.byKey(const Key('history.itemCard')));
      final title = tester.getRect(
        find.byKey(const Key('history.trackingLog')),
      );
      final first = tester.getRect(find.byType(CheckTile).first);
      expect(card.bottom, lessThan(title.top));
      expect(title.bottom, lessThanOrEqualTo(first.top));
      expect(find.text('01'), findsOneWidget);
      expect(find.text(l10n.historyCheckCount(120)), findsOneWidget);
      await shot('screen_history_tracking');
    });

    uiTest("TC-UI-113 history: everyone's checks", (tester, shot) async {
      final app = await start(tester, profile: Roles.supervisor);
      await openHistory(app);
      await app.tap(find.byKey(const Key('history.filters')));
      await app.tap(find.byKey(const Key('history.scopeAll')));
      await app.tapText(l10n.historyApply);
      expect(find.textContaining(l10n.historyBy('Asha Rao')), findsWidgets);
      await shot('screen_history_all');
    });
  });
}
