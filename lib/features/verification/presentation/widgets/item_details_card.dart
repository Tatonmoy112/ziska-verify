import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/label_value_row.dart';

/// The item's details (final.md Section 13.1, SRS FR-LKP-06): every field
/// of a found item — the product (name, generic, short), the batch and its
/// dates, the serial, and the masked hidden code — and, with [count], a
/// "Check N" pill and the previous check time. A missing field shows as a
/// blank "—". The picture has its own card. Never names the officials of
/// earlier checks (FR-LKP-09).
class ItemDetailsCard extends StatelessWidget {
  const ItemDetailsCard({required this.item, this.count, super.key});

  final ItemDetails item;

  /// The check count of the answer, when it has one.
  final CheckCount? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final product = item.product;
    final batch = item.batch;
    final count = this.count;
    String? date(DateTime? d) => d == null ? null : DisplayTime.date(d, locale);

    final rows = <(String, String?)>[
      (l10n.productLabel, product.name),
      (l10n.genericLabel, product.genericName),
      (l10n.shortNameLabel, product.shortName),
      (l10n.batchLabel, batch.number),
      (l10n.madeLabel, date(batch.made)),
      (l10n.expiresLabel, date(batch.expires)),
      (l10n.serialLabel, item.serial),
      (l10n.codeLabel2, item.maskedCode),
      // The previous check, when there was one.
      if (count?.lastAt != null)
        (
          l10n.previousCheckLabel,
          DisplayTime.dateTime(count!.lastAt!, locale),
        ),
    ];
    // A missing field stays, blank (FR-LKP-06: "missing ones are blank").
    final shown = [for (final (label, value) in rows) (label, value ?? '—')];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.detailsProductTitle.toUpperCase(),
                    style: AppTypography.sectionTitle,
                  ),
                ),
                if (count == null)
                  const Icon(
                    LucideIcons.package,
                    size: 20,
                    color: AppColors.textMuted,
                  )
                else
                  _CheckPill(
                    label: l10n.checkNumber(count.thisCheck),
                    // The first check is no warning: green, not amber.
                    first: count.thisCheck <= 1,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final (i, (label, value)) in shown.indexed) ...[
              if (i > 0) const Divider(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                // A long value (a generic name, say) wraps instead of
                // running off the screen.
                child: LabelValueRow(label: label, value: value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Check N": this check's number for the item, never a uses limit
/// (backend D31).
class _CheckPill extends StatelessWidget {
  const _CheckPill({required this.label, required this.first});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: first ? AppColors.successBackground : AppColors.warningBackground,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: first ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
