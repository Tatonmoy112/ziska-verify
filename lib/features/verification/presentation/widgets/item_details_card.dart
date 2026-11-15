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

/// The item's details (final.md Section 13.1.4). **PRODUCT DETAILS**: the
/// product, its batch and dates, the serial, and the masked hidden code.
/// With [tracking] (a `checked_before` result) it is **TRACKING DETAILS**:
/// a "Check N" pill, the item first, the previous check time, and the
/// earlier checkers when the API sends them. A `null` field is left out;
/// the picture has its own card.
class ItemDetailsCard extends StatelessWidget {
  const ItemDetailsCard({required this.item, this.tracking, super.key});

  final ItemDetails item;

  /// The check count of a `checked_before` result.
  final CheckCount? tracking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final product = item.product;
    final batch = item.batch;
    final count = tracking;
    String? date(DateTime? d) => d == null ? null : DisplayTime.date(d, locale);

    final rows = <(String, String?)>[
      if (count == null) ...[
        (l10n.productLabel, product.name),
        (l10n.genericLabel, product.genericName),
        (l10n.shortNameLabel, product.shortName),
        (l10n.batchLabel, batch.number),
        (l10n.madeLabel, date(batch.made)),
        (l10n.expiresLabel, date(batch.expires)),
        (l10n.serialLabel, item.serial),
        (l10n.codeLabel2, item.maskedCode),
      ] else ...[
        (l10n.serialLabel, item.serial),
        (l10n.codeLabel2, item.maskedCode),
        (l10n.batchLabel, batch.number),
        (l10n.productLabel, product.name),
        (l10n.genericLabel, product.genericName),
        (
          l10n.previousCheckLabel,
          count.lastAt == null
              ? null
              : DisplayTime.dateTime(count.lastAt!, locale),
        ),
        (
          l10n.checkedByLabel,
          count.by == null || count.by!.isEmpty ? null : count.by!.join(', '),
        ),
      ],
    ];
    final shown = [
      for (final (label, value) in rows)
        if (value != null) (label, value),
    ];

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
                    (count == null
                            ? l10n.detailsProductTitle
                            : l10n.detailsTrackingTitle)
                        .toUpperCase(),
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
                  _CheckPill(label: l10n.checkNumber(count.thisCheck)),
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
  const _CheckPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.warningBackground,
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
