import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The navy header of the Sign up design: a back button, a title,
/// and a subtitle.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Shows the back button when set.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.md,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null) ...[
                Material(
                  color: AppColors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.button,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(LucideIcons.arrowLeft),
                    color: AppColors.onPrimary,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                title,
                style: AppTypography.title.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
