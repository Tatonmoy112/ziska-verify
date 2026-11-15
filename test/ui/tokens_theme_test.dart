import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';

import '../flow/harness.dart';
import 'source_scan.dart';
import 'ui_helpers.dart';

/// Section A of docs/test-cases/15-ui.md: every colour, size, gap, radius,
/// and text style comes from the tokens, and the theme maps them
/// (TC-UI-013 … -025).
void main() {
  group('static scans of lib/', () {
    test('TC-UI-013 no colour outside the colour tokens', () {
      final found = scan(
        RegExp(r'Color\(0x|\bColors\.(?!transparent\b)'),
        except: {'lib/shared/design_system/tokens/app_colors.dart'},
      );
      expect(found, isEmpty);
    });

    test('TC-UI-014 no font size outside the type tokens', () {
      final found = scan(
        RegExp(r'fontSize:|\bTextStyle\('),
        except: {
          'lib/shared/design_system/tokens/app_typography.dart',
          // Drawn at its set width (TC-UI-001 … -009).
          'lib/shared/widgets/app_logo.dart',
        },
      );
      expect(found, isEmpty);
    });

    test('TC-UI-015 gaps and padding from the spacing tokens', () {
      const logo = {'lib/shared/widgets/app_logo.dart'};
      final found = [
        // A number inside any EdgeInsets constructor, over several lines.
        ...scanCalls('EdgeInsets.', except: logo),
        // A gap: a SizedBox with only a width or only a height.
        ...scan(
          RegExp(r'SizedBox\((width|height): \d'),
          except: logo,
        ),
        ...scan(RegExp(r'\b(run)?[sS]pacing: \d'), except: logo),
      ];
      expect(found, isEmpty);
    });

    test('TC-UI-016 corner radii from the radius tokens', () {
      final found = scan(
        RegExp(r'Radius\.circular\(\d'),
        except: {'lib/shared/design_system/tokens/app_radius.dart'},
      );
      expect(found, isEmpty);
    });

    test('TC-UI-025 icons come from Lucide only', () {
      expect(scan(RegExp(r'\bIcons\.')), isEmpty);
    });
  });

  test('TC-UI-017 the spacing scale is a 4-point scale', () {
    const values = [
      AppSpacing.xxs,
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xxl,
      AppSpacing.xxxl,
      AppSpacing.screen,
    ];
    for (final v in values) {
      expect(v % 4, 0, reason: '$v');
    }
  });

  testWidgets('TC-UI-018 the colour scheme maps the tokens', (tester) async {
    final theme = await _theme(tester);
    final scheme = theme.colorScheme;
    expect(theme.brightness, Brightness.light);
    expect(scheme.primary, AppColors.primary);
    expect(scheme.onPrimary, AppColors.onPrimary);
    // A chosen segment or chip: navy, white text (decision sheet Q21).
    expect(scheme.secondaryContainer, AppColors.primary);
    expect(scheme.onSecondaryContainer, AppColors.onPrimary);
    expect(scheme.error, AppColors.danger);
    expect(scheme.surface, AppColors.background);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    // The roles Material widgets draw with (sheets, dialogs, menus, switch
    // tracks, list text, outlines): tokens, not the generated palette.
    expect(scheme.onSurface, AppColors.textStrong);
    expect(scheme.onSurfaceVariant, AppColors.textBody);
    for (final c in [
      scheme.surfaceContainerLowest,
      scheme.surfaceContainerLow,
      scheme.surfaceContainer,
      scheme.surfaceContainerHigh,
      scheme.surfaceContainerHighest,
      scheme.surfaceTint,
    ]) {
      expect(c, AppColors.background);
    }
    expect(scheme.outline, AppColors.textMuted);
    expect(scheme.outlineVariant, AppColors.border);
    expect(scheme.inverseSurface, AppColors.textStrong);
    expect(scheme.onInverseSurface, AppColors.onPrimary);
    // A floating main action: the main button's colours.
    final fab = theme.floatingActionButtonTheme;
    expect(fab.backgroundColor, AppColors.primary);
    expect(fab.foregroundColor, AppColors.onPrimary);
  });

  testWidgets('TC-UI-019 the input theme maps the tokens', (tester) async {
    final input = (await _theme(tester)).inputDecorationTheme;
    expect(input.filled, isTrue);
    expect(
      WidgetStateProperty.resolveAs(input.fillColor, {}),
      AppColors.background,
    );
    expect(
      WidgetStateProperty.resolveAs(input.fillColor, {WidgetState.disabled}),
      AppColors.surfaceMuted,
    );
    expect(
      (input.disabledBorder! as OutlineInputBorder).borderSide.color,
      AppColors.border,
    );
    expect(input.contentPadding, const EdgeInsets.all(AppSpacing.md));

    OutlineInputBorder outline(InputBorder? b) => b! as OutlineInputBorder;
    for (final b in [input.border, input.enabledBorder]) {
      expect(outline(b).borderRadius, AppRadius.input);
      expect(outline(b).borderSide.color, AppColors.border);
    }
    expect(outline(input.focusedBorder).borderSide.color, AppColors.primary);
    expect(outline(input.focusedBorder).borderSide.width, 1.5);
    expect(outline(input.errorBorder).borderSide.color, AppColors.danger);
    expect(
      outline(input.focusedErrorBorder).borderSide.color,
      AppColors.danger,
    );
    expect(input.hintStyle?.color, AppColors.textMuted);
    expect(input.hintStyle?.fontSize, AppTypography.body.fontSize);
    expect(input.prefixIconColor, AppColors.textMuted);
  });

  group('contrast (WCAG)', () {
    test('TC-UI-020 text colours meet 4.5:1', () {
      const surfaces = [AppColors.background, AppColors.surfaceMuted];
      final pairs = <(String, Color, Color)>[
        for (final (name, text) in const [
          ('textStrong', AppColors.textStrong),
          ('textBody', AppColors.textBody),
          ('textLabel', AppColors.textLabel),
          ('textMuted', AppColors.textMuted),
          ('primary', AppColors.primary),
          ('success', AppColors.success),
          ('warning', AppColors.warning),
          ('danger', AppColors.danger),
          ('infoAccent', AppColors.infoAccent),
        ])
          for (final s in surfaces) (name, text, s),
        ('onPrimary', AppColors.onPrimary, AppColors.primary),
        ('onPrimary', AppColors.onPrimary, AppColors.primaryDark),
        ('successOnDark', AppColors.successOnDark, AppColors.primary),
        ('successOnDark', AppColors.successOnDark, AppColors.primaryDark),
        ('success', AppColors.success, AppColors.successBackground),
        ('warning', AppColors.warning, AppColors.warningBackground),
        ('danger', AppColors.danger, AppColors.dangerBackground),
        ('infoAccent', AppColors.infoAccent, AppColors.infoBackground),
        ('textBody', AppColors.textBody, AppColors.infoBackground),
        for (final bg in const [
          AppColors.successBackground,
          AppColors.warningBackground,
          AppColors.dangerBackground,
        ]) ...[
          ('textStrong', AppColors.textStrong, bg),
          ('textBody', AppColors.textBody, bg),
          ('textMuted', AppColors.textMuted, bg),
        ],
      ];
      final failing = [
        for (final (name, fg, bg) in pairs)
          if (_contrast(fg, bg) < 4.5)
            '$name on $bg: ${_contrast(fg, bg).toStringAsFixed(2)}',
      ];
      expect(failing, isEmpty);
    });

    test('TC-UI-021 icons and large text meet 3:1', () {
      const icons = [
        AppColors.primary,
        AppColors.success,
        AppColors.warning,
        AppColors.danger,
        AppColors.textMuted,
        AppColors.infoAccent,
      ];
      final failing = [
        for (final icon in icons)
          for (final bg in const [AppColors.background, AppColors.surfaceMuted])
            if (_contrast(icon, bg) < 3) '$icon on $bg',
      ];
      expect(failing, isEmpty);
    });
  });

  testWidgets('TC-UI-022 the bottom bar colours', (tester) async {
    await startApp(tester);
    final bar = tester
        .widget<NavigationBarTheme>(find.byType(NavigationBarTheme).last)
        .data;
    expect(bar.backgroundColor, AppColors.background);
    expect(bar.indicatorColor, Colors.transparent);

    const selected = {WidgetState.selected};
    const other = <WidgetState>{};
    expect(bar.iconTheme!.resolve(selected)!.color, AppColors.primary);
    expect(bar.iconTheme!.resolve(other)!.color, AppColors.textMuted);
    final on = bar.labelTextStyle!.resolve(selected)!;
    final off = bar.labelTextStyle!.resolve(other)!;
    expect(on.color, AppColors.primary);
    expect(off.color, AppColors.textMuted);
    expect(on.fontSize, AppTypography.caption.fontSize);
    expect(off.fontSize, AppTypography.caption.fontSize);
  });

  testWidgets('TC-UI-023 the header gradient', (tester) async {
    const gradient = AppColors.headerGradient;
    expect(gradient.colors, [AppColors.primary, AppColors.primaryDark]);
    expect(gradient.begin, Alignment.topLeft);
    expect(gradient.end, Alignment.bottomRight);

    await pumpUi(tester, const GradientHeader(title: 'Request access'));
    final boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(GradientHeader),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>();
    expect(boxes.map((d) => d.gradient), contains(gradient));
  });

  testWidgets('TC-UI-024 light theme only, also with the phone in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await startApp(tester, loggedIn: false);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.darkTheme, isNull);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);
  });
}

/// The app theme as a screen sees it.
Future<ThemeData> _theme(WidgetTester tester) async {
  await pumpUi(tester, const SizedBox());
  return Theme.of(tester.element(find.byType(SizedBox).last));
}

/// The WCAG contrast ratio of two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
