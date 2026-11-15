import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/label_value_row.dart';

/// The name of a lookup way ("Serial", "Hidden code", "QR code").
String wayName(LookupWay way, AppLocalizations l10n) => switch (way) {
  LookupWay.serial => l10n.waySerial,
  LookupWay.hiddenCode => l10n.wayHiddenCode,
  LookupWay.qr => l10n.wayQr,
};

/// **WHAT YOU ENTERED** for a result without an item (final.md Section
/// 13.1.4, decision 49): the way and the value (a hidden code only masked),
/// the check time in Bangladesh time, the result, and the reference.
class EnteredCard extends StatelessWidget {
  const EnteredCard({required this.view, super.key});

  final ResultView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final style = outcomeStyle(view.result.outcome, l10n);
    final rows = <(String, String, Color?)>[
      (wayName(view.input.way, l10n), view.input.shown, null),
      (l10n.checkedAtLabel, DisplayTime.dateTime(view.input.at, locale), null),
      (l10n.resultRowLabel, style.title, style.color),
      (l10n.referenceNumber, view.result.ref, null),
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
            Text(
              l10n.enteredTitle.toUpperCase(),
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final (i, (label, value, color)) in rows.indexed) ...[
              if (i > 0) const Divider(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: LabelValueRow(
                  label: label,
                  value: value,
                  valueColor: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// **HINTS** for a `not_found` result, built from `GET formats` (final.md
/// Section 13.1.4; backend D41: no fixed lengths): the serial's digits and
/// length, each hidden code length, scratching the panel fully, and
/// scanning the QR code when it was not scanned.
class HintsCard extends StatelessWidget {
  const HintsCard({required this.way, this.formats, super.key});

  final LookupWay way;
  final InputFormats? formats;

  /// The hints, in order.
  static List<String> hints(
    AppLocalizations l10n,
    LookupWay way,
    InputFormats? formats,
  ) {
    final f = formats;
    final lengths = f == null
        ? <int>[]
        : ({for (final c in f.hiddenCodes) c.length}.toList()..sort());
    String joined() {
      final words = [for (final n in lengths) '$n'];
      return words.length == 1
          ? words.single
          : l10n.lengthsOr(
              words.sublist(0, words.length - 1).join(', '),
              words.last,
            );
    }

    return [
      if (f != null) l10n.inputWrongSerial(f.serialMaxDigits),
      if (lengths.isNotEmpty) l10n.hintHiddenCodeLength(joined()),
      l10n.hintScratch,
      if (way != LookupWay.qr) l10n.hintScanQr,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.lightbulb,
                  size: 20,
                  color: AppColors.infoAccent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.hintsTitle.toUpperCase(),
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.infoAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final hint in hints(l10n, way, formats))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•', style: AppTypography.body),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(hint, style: AppTypography.body)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
