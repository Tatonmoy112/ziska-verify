import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/features/authentication/presentation/widgets/password_rules.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_otp_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/reference_text.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

import 'ui_helpers.dart';

/// Section B, part 1 of docs/test-cases/15-ui.md: buttons, fields, banners,
/// and the small shared widgets (TC-UI-026 … -055).
void main() {
  setUpAll(loadUiFonts);
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('buttons', () {
    const label = 'Login securely';

    uiTest('TC-UI-026 primary button', (tester, shot) async {
      await _show(tester, const AppButton(label: label, onPressed: _noop));
      _expectButtonSize(tester);
      final style = _style(tester);
      expect(style.backgroundColor!.resolve({}), AppColors.primary);
      expect(
        (style.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
        AppRadius.button,
      );
      final text = drawnStyle(tester, find.text(label));
      expect(text.fontSize, AppTypography.button.fontSize);
      expect(text.fontWeight, AppTypography.button.fontWeight);
      expect(text.color, AppColors.onPrimary);
      await shot('button_primary');
    });

    uiTest('TC-UI-027 outlined button', (tester, shot) async {
      await _show(
        tester,
        const AppButton(
          label: label,
          variant: AppButtonVariant.outlined,
          onPressed: _noop,
        ),
      );
      _expectButtonSize(tester);
      final style = _style(tester);
      expect(style.backgroundColor!.resolve({}), AppColors.background);
      expect(
        style.side!.resolve({}),
        const BorderSide(color: AppColors.primary, width: 1.5),
      );
      expect(drawnStyle(tester, find.text(label)).color, AppColors.primary);
      await shot('button_outlined');
    });

    uiTest('TC-UI-028 tonal button', (tester, shot) async {
      await _show(
        tester,
        const AppButton(
          label: label,
          variant: AppButtonVariant.tonal,
          onPressed: _noop,
        ),
      );
      _expectButtonSize(tester);
      final style = _style(tester);
      // White with a light border: visible on white and grey screens.
      expect(style.backgroundColor!.resolve({}), AppColors.background);
      expect(
        style.side!.resolve({}),
        const BorderSide(color: AppColors.border, width: 1.5),
      );
      expect(drawnStyle(tester, find.text(label)).color, AppColors.primary);
      // Never the grey screen colour, where it would vanish (TC-UI-168).
      expect(
        style.backgroundColor!.resolve({}),
        isNot(AppColors.surfaceMuted),
      );
      await shot('button_tonal');
    });

    uiTest('TC-UI-029 disabled button of each variant', (tester, shot) async {
      await _show(
        tester,
        Column(
          children: [
            for (final v in AppButtonVariant.values) ...[
              AppButton(label: v.name, variant: v, onPressed: null),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
        height: 360,
      );
      final buttons = find.byType(FilledButton);
      expect(buttons, findsNWidgets(AppButtonVariant.values.length));
      for (final e in buttons.evaluate()) {
        final button = e.widget as FilledButton;
        expect(button.onPressed, isNull);
        final enabled = button.style!.backgroundColor!.resolve({})!;
        final disabled = button.style!.backgroundColor!.resolve({
          WidgetState.disabled,
        })!;
        expect(disabled, isNot(enabled));
        expect(disabled.a, lessThan(1));
        expect(tester.getSize(find.byWidget(button)).height, 56);
      }
      // The outlined and danger borders fade too.
      for (final i in [1, 3]) {
        final b = buttons.evaluate().elementAt(i).widget as FilledButton;
        expect(
          b.style!.side!.resolve({WidgetState.disabled})!.color.a,
          lessThan(1),
        );
      }
      await shot('button_disabled');
    });

    uiTest('TC-UI-030 loading button', (tester, shot) async {
      var taps = 0;
      await _show(
        tester,
        AppButton(label: label, loading: true, onPressed: () => taps++),
        settle: false,
      );
      _expectButtonSize(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(label), findsNothing);
      // A screen reader still hears the label.
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(label), findsOneWidget);
      semantics.dispose();
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
      final style = _style(tester);
      expect(
        style.backgroundColor!.resolve({WidgetState.disabled}),
        AppColors.primary,
      );
      await _finishAnimations(tester);
      await shot('button_loading');
    });

    uiTest('TC-UI-031 long button label', (tester, shot) async {
      final long =
          'Contact Ziska Pharma support to ask for access to the '
                  'Track and Trace app'
              .substring(0, 60);
      expect(long.length, 60);
      await _show(tester, AppButton(label: long, onPressed: _noop));
      expect(tester.takeException(), isNull);
      _expectButtonSize(tester);
      final button = tester.getRect(find.byType(FilledButton));
      final text = tester.getRect(find.text(long));
      expect(text.left, greaterThanOrEqualTo(button.left));
      expect(text.right, lessThanOrEqualTo(button.right));
      expect(text.top, greaterThanOrEqualTo(button.top));
      expect(text.bottom, lessThanOrEqualTo(button.bottom));
      await shot('button_long_label');
    });
  });

  group('text fields', () {
    uiTest('TC-UI-032 text field label above the input', (tester, shot) async {
      await _show(tester, const AppTextField(label: 'Email'));
      final label = drawnStyle(tester, find.text('EMAIL'));
      expect(label.fontSize, AppTypography.fieldLabel.fontSize);
      expect(label.fontWeight, AppTypography.fieldLabel.fontWeight);
      expect(label.letterSpacing, AppTypography.fieldLabel.letterSpacing);
      expect(label.color, AppColors.textLabel);
      expect(
        tester.getRect(find.byType(TextField)).top -
            tester.getRect(find.text('EMAIL')).bottom,
        AppSpacing.xs,
      );
      await tester.enterText(find.byType(TextField), 'ana@ziska.com');
      await _finishAnimations(tester);
      final input = tester.widget<EditableText>(find.byType(EditableText));
      expect(input.style.fontSize, AppTypography.body.fontSize);
      expect(input.style.color, AppColors.textStrong);
      await shot('field_default');
    });

    uiTest('TC-UI-033 hint and prefix icon', (tester, shot) async {
      await _show(
        tester,
        const AppTextField(
          label: 'Email',
          hint: 'name@example.com',
          prefixIcon: LucideIcons.mail,
        ),
      );
      expect(
        drawnStyle(tester, find.text('name@example.com')).color,
        AppColors.textMuted,
      );
      expect(tester.widget<Icon>(find.byIcon(LucideIcons.mail)).size, 20);
      expect(
        drawnStyle(tester, find.byIcon(LucideIcons.mail)).color,
        AppColors.textMuted,
      );
      await shot('field_hint_icon');
    });

    uiTest('TC-UI-034 focused field', (tester, shot) async {
      await _show(tester, const AppTextField(label: 'Email'));
      await tester.tap(find.byType(TextField));
      await _finishAnimations(tester);
      final decorator = tester.widget<InputDecorator>(
        find.byType(InputDecorator),
      );
      expect(decorator.isFocused, isTrue);
      final border = decorator.decoration.focusedBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.primary);
      expect(border.borderSide.width, 1.5);
      await shot('field_focused');
    });

    uiTest('TC-UI-035 field with an error', (tester, shot) async {
      await _show(
        tester,
        const AppTextField(label: 'Email', errorText: 'Required'),
      );
      expect(drawnStyle(tester, find.text('Required')).color, AppColors.danger);
      final decoration = tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration;
      expect(
        (decoration.errorBorder! as OutlineInputBorder).borderSide.color,
        AppColors.danger,
      );
      await shot('field_error');
    });

    uiTest('TC-UI-036 disabled field', (tester, shot) async {
      await _show(
        tester,
        AppTextField(
          label: 'Email',
          controller: TextEditingController(text: 'ana@ziska.com'),
          enabled: false,
        ),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      // A muted look: the text is not drawn as an editable value.
      final input = tester.widget<EditableText>(find.byType(EditableText));
      expect(input.style.color, AppColors.textMuted);
      final decoration = tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration;
      expect(
        WidgetStateProperty.resolveAs(decoration.fillColor, {
          WidgetState.disabled,
        }),
        AppColors.surfaceMuted,
      );
      expect(
        (decoration.disabledBorder! as OutlineInputBorder).borderSide.color,
        AppColors.border,
      );
      await shot('field_disabled');
    });

    uiTest('TC-UI-037 password field hidden and shown', (tester, shot) async {
      await _show(
        tester,
        AppPasswordField(
          label: l10n.passwordLabel,
          showLabel: l10n.showPassword,
          hideLabel: l10n.hidePassword,
        ),
      );
      await tester.enterText(find.byType(TextField), 'abcd1234');
      await _finishAnimations(tester);
      EditableText input() =>
          tester.widget<EditableText>(find.byType(EditableText));
      expect(input().obscureText, isTrue);
      final link = drawnStyle(tester, find.text(l10n.showPassword));
      expect(link.fontSize, AppTypography.link.fontSize);
      expect(link.fontWeight, AppTypography.link.fontWeight);
      expect(link.color, AppColors.primary);
      expect(
        tester.getRect(find.byType(TextButton)).right,
        tester.getRect(find.byType(TextField)).right,
      );
      await shot('password_hidden');

      await tester.tap(find.text(l10n.showPassword));
      await _finishAnimations(tester);
      expect(input().obscureText, isFalse);
      expect(find.text(l10n.hidePassword), findsOneWidget);
      await shot('password_shown');
    });

    uiTest('TC-UI-038 code field', (tester, shot) async {
      await _show(tester, AppOtpField(label: l10n.codeLabel));
      await shot('otp_empty');
      await tester.enterText(find.byType(TextField), '12a34b56789');
      await _finishAnimations(tester);
      final input = tester.widget<EditableText>(find.byType(EditableText));
      expect(input.controller.text, '123456');
      expect(input.style.fontSize, AppTypography.headline.fontSize);
      expect(input.style.letterSpacing, 10);
      await shot('otp_filled');
    });
  });

  group('banners and small widgets', () {
    const message = 'Email or password is incorrect.';

    uiTest('TC-UI-039 error banner with a reference', (tester, shot) async {
      await _show(
        tester,
        const ErrorBanner(message: message, requestId: 'req-1'),
        height: 160,
      );
      final box = _bannerBox(tester);
      expect(box.color, AppColors.dangerBackground);
      expect(box.borderRadius, AppRadius.input);
      expect(
        tester.widget<Icon>(find.byIcon(LucideIcons.circleAlert)).color,
        AppColors.danger,
      );
      expect(drawnStyle(tester, find.text(message)).color, AppColors.danger);
      expect(_selectable('Reference: req-1'), findsOneWidget);
      expect(
        tester.getRect(_selectable('Reference: req-1')).top,
        greaterThanOrEqualTo(tester.getRect(find.text(message)).bottom),
      );
      await shot('error_banner');
    });

    uiTest('TC-UI-040 error banner without a reference', (tester, shot) async {
      await _show(tester, const ErrorBanner(message: message), height: 160);
      expect(find.byType(SelectableText), findsNothing);
      final text = tester.getSize(find.text(message)).height;
      final icon = tester.getSize(find.byIcon(LucideIcons.circleAlert)).height;
      expect(
        tester.getSize(find.byType(ErrorBanner)).height,
        2 * AppSpacing.sm + (text > icon ? text : icon),
      );
      await shot('error_banner_no_ref');
    });

    uiTest('TC-UI-041 rate-limit banner', (tester, shot) async {
      await _show(
        tester,
        FailureBanner(
          failure: const Failure(RateLimitedException(requestId: 'req-2')),
          message: message,
          retryAt: clock.now().add(const Duration(seconds: 30)),
        ),
        height: 160,
      );
      expect(find.text(l10n.errorRateLimited(30)), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(_selectable('Reference: req-2'), findsOneWidget);
      await shot('failure_banner_countdown');
      await tester.pump(const Duration(seconds: 30));
      expect(find.byType(ErrorBanner), findsNothing);
    });

    uiTest('TC-UI-042 reference text', (tester, shot) async {
      await _show(tester, const ReferenceText('req-1'), height: 80);
      final text = tester.widget<SelectableText>(
        _selectable('Reference: req-1'),
      );
      expect(text.style!.fontSize, AppTypography.caption.fontSize);
      expect(text.style!.color, AppColors.textMuted);
    });

    uiTest('TC-UI-043 countdown ticks', (tester, shot) async {
      final seen = <int>[];
      await _show(
        tester,
        RetryCountdown(
          until: clock.now().add(const Duration(seconds: 3)),
          builder: (context, s) {
            if (seen.isEmpty || seen.last != s) seen.add(s);
            return Text('$s');
          },
        ),
        height: 80,
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(seen, [3, 2, 1, 0]);
      await tester.pump(const Duration(seconds: 5));
      expect(seen, [3, 2, 1, 0]);
    });

    uiTest('TC-UI-044 empty state', (tester, shot) async {
      await pumpUi(
        tester,
        AppEmptyState(
          icon: LucideIcons.inbox,
          title: l10n.historyEmptyTitle,
          body: l10n.historyEmptyBody,
        ),
        size: const Size(390, 320),
      );
      final icon = find.byIcon(LucideIcons.inbox);
      expect(tester.getCenter(icon).dx, 195);
      expect(tester.widget<Icon>(icon).size, 48);
      expect(tester.widget<Icon>(icon).color, AppColors.textMuted);
      final title = drawnStyle(tester, find.text(l10n.historyEmptyTitle));
      expect(title.fontSize, AppTypography.bodyStrong.fontSize);
      expect(title.fontWeight, AppTypography.bodyStrong.fontWeight);
      final body = drawnStyle(tester, find.text(l10n.historyEmptyBody));
      expect(body.fontSize, AppTypography.caption.fontSize);
      expect(body.color, AppTypography.caption.color);
      expect(tester.getCenter(find.text(l10n.historyEmptyBody)).dx, 195);
      await shot('empty_state');
    });

    uiTest('TC-UI-045 header with back', (tester, shot) async {
      var back = 0;
      await pumpUi(
        tester,
        _inList(
          GradientHeader(
            title: l10n.requestAccessTitle,
            subtitle: l10n.requestAccessSubtitle,
            onBack: () => back++,
          ),
        ),
        size: const Size(390, 300),
      );
      expect(tester.getSize(find.byType(GradientHeader)).width, phone.width);
      final tile = tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(IconButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(tile.color, AppColors.onPrimary.withValues(alpha: 0.15));
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
      final title = drawnStyle(tester, find.text(l10n.requestAccessTitle));
      expect(title.fontSize, AppTypography.title.fontSize);
      expect(title.color, AppColors.onPrimary);
      final sub = drawnStyle(tester, find.text(l10n.requestAccessSubtitle));
      expect(sub.fontSize, AppTypography.subtitle.fontSize);
      expect(sub.color, AppColors.onPrimary.withValues(alpha: 0.85));
      await tester.tap(find.byType(IconButton));
      expect(back, 1);
      await shot('header_back');
    });

    uiTest('TC-UI-046 header without back', (tester, shot) async {
      await pumpUi(
        tester,
        _inList(GradientHeader(title: l10n.requestAccessTitle)),
        size: const Size(390, 200),
      );
      expect(tester.getSize(find.byType(GradientHeader)).width, phone.width);
      expect(find.byType(IconButton), findsNothing);
      final title = tester.getRect(find.text(l10n.requestAccessTitle));
      expect(title.top, AppSpacing.md);
      expect(title.left, AppSpacing.screen);
      await shot('header_no_back');
    });
  });

  group('password rules', () {
    Future<void> rules(WidgetTester tester, String password) => _show(
      tester,
      PasswordRules(check: const PasswordPolicy().check(password)),
      height: 160,
    );
    Color colour(WidgetTester tester, String label) =>
        drawnStyle(tester, find.text(label)).color!;

    uiTest('TC-UI-047 password rules not met', (tester, shot) async {
      await rules(tester, '');
      expect(find.byIcon(LucideIcons.circle), findsNWidgets(3));
      for (final l in [l10n.ruleLength, l10n.ruleLetter, l10n.ruleNumber]) {
        expect(colour(tester, l), AppColors.textMuted);
      }
      await shot('rules_none');
    });

    uiTest('TC-UI-048 password rules met', (tester, shot) async {
      await rules(tester, 'abcd1234');
      expect(find.byIcon(LucideIcons.circleCheck), findsNWidgets(3));
      for (final l in [l10n.ruleLength, l10n.ruleLetter, l10n.ruleNumber]) {
        expect(colour(tester, l), AppColors.success);
      }
      await shot('rules_all');
    });

    uiTest('TC-UI-049 password rules partly met', (tester, shot) async {
      await rules(tester, 'abcd');
      expect(find.byIcon(LucideIcons.circleCheck), findsOneWidget);
      expect(colour(tester, l10n.ruleLetter), AppColors.success);
      expect(colour(tester, l10n.ruleLength), AppColors.textMuted);
      expect(colour(tester, l10n.ruleNumber), AppColors.textMuted);
      await shot('rules_some');
    });
  });

  group('paginated list', () {
    const items = ['Check 1', 'Check 2', 'Check 3'];
    const failure = Failure(ServiceUnavailableException(requestId: 'req-3'));

    Future<_Calls> list(
      WidgetTester tester,
      PaginatedState<String> state, {
      bool settle = true,
    }) async {
      final calls = _Calls();
      await pumpUi(
        tester,
        AppPaginatedList<String>(
          state: state,
          itemBuilder: (context, s) => ListTile(title: Text(s)),
          placeholderItem: 'Placeholder check',
          onNextPage: () => calls.next++,
          onRetry: () => calls.retry++,
          onRefresh: () async {},
          emptyTitle: l10n.historyEmptyTitle,
          emptyBody: l10n.historyEmptyBody,
        ),
        size: const Size(390, 600),
        settle: settle,
      );
      return calls;
    }

    uiTest('TC-UI-050 list: first page loading', (tester, shot) async {
      await list(
        tester,
        const PaginatedState(status: PaginationStatus.loadingFirst),
        settle: false,
      );
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer),
        findsOneWidget,
      );
      expect(find.text('Placeholder check'), findsNWidgets(6));
      await shot('list_loading');
    });

    uiTest('TC-UI-051 list: empty', (tester, shot) async {
      await list(tester, const PaginatedState(status: PaginationStatus.empty));
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text(l10n.historyEmptyTitle), findsOneWidget);
      expect(find.text(l10n.historyEmptyBody), findsOneWidget);
      await shot('list_empty');
    });

    uiTest('TC-UI-052 list: first page failed', (tester, shot) async {
      final calls = await list(
        tester,
        const PaginatedState(
          status: PaginationStatus.failureFirst,
          failure: failure,
        ),
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(_selectable('Reference: req-3'), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.label, l10n.retry);
      expect(button.variant, AppButtonVariant.primary);
      expect(
        tester.getSize(find.byType(AppButton)).width,
        390 - 2 * AppSpacing.screen,
      );
      await tester.tap(find.byType(AppButton));
      expect(calls.retry, 1);
      await shot('list_error');
    });

    uiTest('TC-UI-053 list: next page loading', (tester, shot) async {
      await list(
        tester,
        const PaginatedState(
          items: items,
          nextCursor: 'c2',
          status: PaginationStatus.loadingMore,
        ),
        settle: false,
      );
      for (final i in items) {
        expect(find.text(i), findsOneWidget);
      }
      final spinner = find.byType(CircularProgressIndicator);
      expect(spinner, findsOneWidget);
      expect(tester.getCenter(spinner).dx, 195);
      expect(
        tester.getRect(spinner).top,
        greaterThan(tester.getRect(find.text('Check 3')).bottom),
      );
      await _finishAnimations(tester);
      await shot('list_loading_more');
    });

    uiTest('TC-UI-054 list: next page failed', (tester, shot) async {
      final calls = await list(
        tester,
        const PaginatedState(
          items: items,
          nextCursor: 'c2',
          status: PaginationStatus.failureMore,
          failure: failure,
        ),
      );
      for (final i in items) {
        expect(find.text(i), findsOneWidget);
      }
      expect(find.byType(ErrorBanner), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.variant, AppButtonVariant.outlined);
      expect(
        tester.getRect(find.byType(ErrorBanner)).top,
        greaterThan(tester.getRect(find.text('Check 3')).bottom),
      );
      await tester.tap(find.byType(AppButton));
      expect(calls.retry, 1);
      expect(calls.next, 0);
      await shot('list_retry_footer');
    });

    uiTest('TC-UI-055 list: the end', (tester, shot) async {
      final calls = await list(
        tester,
        const PaginatedState(
          items: items,
          status: PaginationStatus.success,
          hasReachedEnd: true,
        ),
      );
      for (final i in items) {
        expect(find.text(i), findsOneWidget);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AppButton), findsNothing);
      expect(calls.next, 0);
      await shot('list_end');
    });
  });
}

void _noop() {}

/// One frame to start an animation, then long enough for a focus border to
/// finish and a spinner to draw its arc.
Future<void> _finishAnimations(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

class _Calls {
  int next = 0;
  int retry = 0;
}

/// [child] as a screen places it: in a column, with the screen's side
/// padding, on a phone-wide frame [height] high.
Future<void> _show(
  WidgetTester tester,
  Widget child, {
  double height = 200,
  bool settle = true,
}) => pumpUi(
  tester,
  Padding(
    padding: const EdgeInsets.all(AppSpacing.screen),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [child],
    ),
  ),
  size: Size(phone.width, height),
  settle: settle,
);

/// [child] at the top of a screen's list, as the auth screens place the
/// header.
Widget _inList(Widget child) =>
    ListView(padding: EdgeInsets.zero, children: [child]);

ButtonStyle _style(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton)).style!;

/// Full width inside the side padding, 56 high.
void _expectButtonSize(WidgetTester tester) => expect(
  tester.getSize(find.byType(FilledButton)),
  Size(phone.width - 2 * AppSpacing.screen, 56),
);

BoxDecoration _bannerBox(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(ErrorBanner),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

Finder _selectable(String text) => find.byWidgetPredicate(
  (w) => w is SelectableText && w.data == text,
);
