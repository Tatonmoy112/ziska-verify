import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';

/// The official's own check counts, shown on Profile (final.md §13.7):
/// Checks, Valid (green) and Needs attention (amber: warnings, not found
/// and not in a batch), so the three add up. Reads the [CheckTotalsCubit]
/// above it; Try again asks it once more.
class CheckTotalsCard extends StatelessWidget {
  const CheckTotalsCard({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CheckTotalsCubit, CheckTotalsState>(
        builder: (context, state) => _Stats(
          state: state,
          onRetry: () => unawaited(context.read<CheckTotalsCubit>().load()),
        ),
      );
}

/// The three count cards. Grey bars while the first counts load; one line
/// with Try again when they cannot load.
class _Stats extends StatelessWidget {
  const _Stats({required this.state, required this.onRetry});

  final CheckTotalsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = state.totals;
    if (totals == null && state.status == CheckTotalsStatus.failed) {
      return Row(
        key: const Key('profile.stats.failed'),
        children: [
          Expanded(
            child: Text(l10n.statsFailed, style: AppTypography.caption),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      );
    }
    final cards = [
      (l10n.statChecks, totals?.total, AppColors.textStrong),
      (l10n.statValid, totals?.valid, AppColors.success),
      // Everything that is not valid, so the three add up (Checks = Valid
      // + Needs attention): warnings, not found, not in a batch.
      (
        l10n.statNotVerified,
        totals == null
            ? null
            : totals.warning + totals.notFound + totals.unassigned,
        AppColors.warning,
      ),
    ];
    final stacked = isLargeText(context);
    final children = [
      for (final (label, count, color) in cards)
        _StatCard(label: label, count: count, color: color, wide: stacked),
    ];
    if (stacked) {
      return Column(
        key: const Key('profile.stats'),
        children: [
          for (final (i, card) in children.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs),
            card,
          ],
        ],
      );
    }
    return IntrinsicHeight(
      key: const Key('profile.stats'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, card) in children.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: card),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.wide,
  });

  final String label;

  /// `null` while loading: a grey bar takes its place.
  final int? count;
  final Color color;

  /// At a large font: the label on the left, the count on the right.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final number = count == null
        ? DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
            child: SizedBox.fromSize(size: const Size(40, 28)),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: AppTypography.title.copyWith(color: color),
            ),
          );
    final text = Text(
      label,
      textAlign: wide ? TextAlign.start : TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w500,
      ),
    );
    return Semantics(
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: AppSpacing.sm),
                    number,
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    number,
                    const SizedBox(height: AppSpacing.xxs),
                    text,
                  ],
                ),
        ),
      ),
    );
  }
}
