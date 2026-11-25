import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';

class CheckHeader extends StatelessWidget {
  const CheckHeader({
    required this.organisation,
    required this.name,
    required this.onOpenProfile,
    super.key,
  });

  final String organisation;
  final String name;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Stack(
        children: [
          // The Figma's faint honeycomb, strongest at the end.
          const Positioned.fill(
            child: PatternBackground(
              key: Key('verify.header.pattern'),
              color: AppColors.onPrimaryFaint,
              kind: PatternKind.hexagons,
              spacing: AppSpacing.xxxl,
              fade: PatternFade.towardStart,
            ),
          ),
          _HeaderContent(
            organisation: organisation,
            name: name,
            onOpenProfile: onOpenProfile,
          ),
        ],
      ),
    );
  }
}

/// The organisation, the Profile button, and the welcome line.
class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.organisation,
    required this.name,
    required this.onOpenProfile,
  });

  final String organisation;
  final String name;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
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
            Row(
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    organisation,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Material(
                  color: AppColors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.button,
                  child: IconButton(
                    onPressed: onOpenProfile,
                    icon: const Icon(LucideIcons.user),
                    color: AppColors.onPrimary,
                    tooltip: l10n.tabProfile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.welcomeBack,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              name,
              style: AppTypography.title.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
