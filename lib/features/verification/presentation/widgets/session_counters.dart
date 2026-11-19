import 'package:flutter/material.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A session's totals as the backend sends them (app API guide §4.3–4.7,
/// SRS FR-SCN-04): scanned, valid, warning, not found, not in a batch, and
/// how many more the session can take. Never counted in the app. One small
/// cell per total, coloured like the results; they wrap at large text.
class SessionCounters extends StatelessWidget {
  const SessionCounters({required this.totals, super.key});

  final SessionTotals totals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final left = totals.left;
    return Wrap(
      key: const Key('session.counters'),
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _Cell(l.sessionScanned, totals.scanned, AppColors.textStrong),
        _Cell(l.sessionValid, totals.valid, AppColors.success),
        _Cell(l.sessionWarning, totals.warning, AppColors.warning),
        _Cell(l.sessionNotFound, totals.notFound, AppColors.danger),
        _Cell(l.sessionUnassigned, totals.unassigned, AppColors.textBody),
        if (left != null) _Cell(l.sessionLeft, left, AppColors.textMuted),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$value',
                style: AppTypography.bodyStrong.copyWith(color: color),
              ),
              TextSpan(text: ' $label', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    ),
  );
}
