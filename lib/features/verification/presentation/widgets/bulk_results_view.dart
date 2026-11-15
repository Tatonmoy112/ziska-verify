import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';

/// The bulk results: the summary and one row per item in the order sent
/// (final.md Sections 13.2, 14.1 `BulkSummaryCard`).
class BulkResultsView extends StatefulWidget {
  const BulkResultsView({
    required this.outcome,
    required this.onOpen,
    required this.onNewList,
    super.key,
  });

  final BulkOutcome outcome;
  final ValueChanged<BulkRow> onOpen;
  final VoidCallback onNewList;

  @override
  State<BulkResultsView> createState() => _BulkResultsViewState();
}

class _BulkResultsViewState extends State<BulkResultsView> {
  bool _onlyAttention = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      for (final (i, row) in widget.outcome.rows.indexed)
        if (!_onlyAttention || row.needsAttention) (i, row),
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              BulkSummaryCard(summary: widget.outcome.summary),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                key: const Key('bulk.onlyAttention'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.bulkOnlyAttention,
                  style: AppTypography.body,
                ),
                value: _onlyAttention,
                onChanged: (v) => setState(() => _onlyAttention = v),
              ),
              if (rows.isEmpty)
                AppEmptyState(
                  icon: LucideIcons.circleCheck,
                  title: l10n.bulkNoAttention,
                ),
              for (final (i, row) in rows)
                _ResultRow(
                  position: i + 1,
                  row: row,
                  onTap: () => widget.onOpen(row),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: l10n.bulkNewList,
              variant: AppButtonVariant.outlined,
              onPressed: widget.onNewList,
            ),
          ),
        ),
      ],
    );
  }
}

/// The bulk summary (`data.summary`).
class BulkSummaryCard extends StatelessWidget {
  const BulkSummaryCard({required this.summary, super.key});

  final BulkSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reasons = [
      (LookupReason.checkedBefore, l10n.reasonCheckedBefore),
      (LookupReason.recalled, l10n.reasonRecalled),
      (LookupReason.expired, l10n.reasonExpired),
      (LookupReason.damaged, l10n.reasonDamaged),
      (LookupReason.switchedOff, l10n.reasonSwitchedOff),
      (LookupReason.unknown, l10n.reasonUnknown),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bulkSummaryTitle, style: AppTypography.headline),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Count(l10n.bulkTotal, summary.total, AppColors.textStrong),
                _Count(l10n.bulkValid, summary.valid, AppColors.success),
                _Count(l10n.bulkWarning, summary.warning, AppColors.warning),
                _Count(l10n.bulkNotFound, summary.notFound, AppColors.danger),
                _Count(
                  l10n.bulkUnassigned,
                  summary.unassigned,
                  AppColors.textLabel,
                ),
              ],
            ),
            if (summary.warning > 0) ...[
              const Divider(height: AppSpacing.xl),
              for (final (reason, label) in reasons)
                if ((summary.byReason[reason] ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(label, style: AppTypography.caption),
                        ),
                        Text(
                          '${summary.byReason[reason]}',
                          style: AppTypography.bodyStrong,
                        ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.input,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTypography.headline.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.position,
    required this.row,
    required this.onTap,
  });

  final int position;
  final BulkRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = outcomeStyle(row.result.outcome, l10n);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        child: ListTile(
          onTap: onTap,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          leading: Icon(style.icon, color: style.color),
          title: Text(
            '$position. ${row.label}',
            style: AppTypography.bodyStrong,
          ),
          subtitle: Text(
            [
              style.title,
              if (row.result.item != null) row.result.item!.product.name,
              row.result.ref,
            ].join(' · '),
            style: AppTypography.caption,
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
