import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The three password rules, shown before typing starts, each ticked as it
/// is met (app build guide §4.9).
class PasswordRules extends StatelessWidget {
  const PasswordRules({required this.check, super.key});

  final PasswordCheck check;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rule(met: check.hasLength, label: l10n.ruleLength),
        _Rule(met: check.hasLetter, label: l10n.ruleLetter),
        _Rule(met: check.hasNumber, label: l10n.ruleNumber),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.textMuted;
    return Semantics(
      checked: met,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: [
            Icon(
              met ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 18,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            // Wraps on a narrow screen or a large font.
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
