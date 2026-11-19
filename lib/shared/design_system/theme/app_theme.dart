import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The Material 3 theme built from the tokens (final.md Section 14).
abstract final class AppTheme {
  static ThemeData light() {
    // Every role a widget draws with is a token. A chosen segment or chip
    // (and the tonal Filters button) is navy with white text, like the
    // Figma History chips (decision sheet Q21, option A).
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondaryContainer: AppColors.primary,
      onSecondaryContainer: AppColors.onPrimary,
      error: AppColors.danger,
      surface: AppColors.background,
      onSurface: AppColors.textStrong,
      onSurfaceVariant: AppColors.textBody,
      // Sheets, dialogs, menus, and switch tracks: white, like the cards.
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.background,
      surfaceContainerHighest: AppColors.background,
      surfaceTint: AppColors.background,
      outline: AppColors.textMuted,
      outlineVariant: AppColors.border,
      // Snack bars: the dark text colour as the surface, white text.
      inverseSurface: AppColors.textStrong,
      onInverseSurface: AppColors.onPrimary,
    );
    const inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: AppColors.border),
    );
    // The theme's own text styles carry the font family; a token is merged
    // over them, so a replaced style (an app bar or dialog title) keeps it.
    final text = ThemeData(
      useMaterial3: true,
      fontFamilyFallback: AppTypography.fontFallback,
    ).textTheme;
    final title = text.titleLarge!.merge(AppTypography.headline);
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: AppTypography.fontFallback,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      // One title style per level: app bars and dialogs use `headline`.
      appBarTheme: AppBarTheme(
        foregroundColor: AppColors.textStrong,
        titleTextStyle: title,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: title,
        contentTextStyle: text.bodyMedium!.merge(AppTypography.body),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // A disabled field is muted: a grey fill, the plain border.
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? AppColors.surfaceMuted
              : AppColors.background,
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        prefixIconColor: AppColors.textMuted,
      ),
      // A screen's main action ("New report"): the main button's colours.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
