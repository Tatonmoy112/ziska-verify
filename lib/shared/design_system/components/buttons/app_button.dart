import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

enum AppButtonVariant {
  /// Filled navy ("Login securely").
  primary,

  /// Navy outline ("Sign up" on Login).
  outlined,

  /// White with a light border and navy text: a low-emphasis action
  /// ("Back to login", "Back to Check"). Visible on white and on grey
  /// (`surfaceMuted`) screens alike.
  tonal,

  /// White, red text, a light red border ("Log out").
  danger,
}

/// The app's button. While [loading] it shows a spinner and ignores taps,
/// so a request is never sent twice from one screen.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (background, foreground, side) = switch (variant) {
      AppButtonVariant.primary => (
        AppColors.primary,
        AppColors.onPrimary,
        BorderSide.none,
      ),
      AppButtonVariant.outlined => (
        AppColors.background,
        AppColors.primary,
        const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      AppButtonVariant.tonal => (
        AppColors.background,
        AppColors.primary,
        const BorderSide(color: AppColors.border, width: 1.5),
      ),
      AppButtonVariant.danger => (
        AppColors.background,
        AppColors.danger,
        const BorderSide(color: AppColors.dangerBackground, width: 1.5),
      ),
    };

    final child = loading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              // A screen reader still hears what the button does (or is
              // doing: "Checking 3 items…").
              semanticsLabel: label,
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.button,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style:
            FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              disabledBackgroundColor: loading
                  ? background
                  : background.withValues(alpha: 0.45),
              disabledForegroundColor: loading
                  ? foreground
                  : foreground.withValues(alpha: 0.7),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.button,
              ),
              elevation: 0,
            ).copyWith(
              // Disabled (not loading): the border fades with the fill.
              side: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.disabled) &&
                        !loading &&
                        side != BorderSide.none
                    ? side.copyWith(color: side.color.withValues(alpha: 0.45))
                    : side,
              ),
            ),
        child: child,
      ),
    );
  }
}
