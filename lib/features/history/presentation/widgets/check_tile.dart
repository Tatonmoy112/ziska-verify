import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';

/// The label and colour of each result in History.
(String, Color) checkResultStyle(CheckResult result, AppLocalizations l10n) =>
    switch (result) {
      CheckResult.valid => (l10n.bulkValid, AppColors.success),
      CheckResult.warning => (l10n.bulkWarning, AppColors.warning),
      CheckResult.notFound => (l10n.bulkNotFound, AppColors.danger),
      CheckResult.unassigned => (l10n.bulkUnassigned, AppColors.textLabel),
      CheckResult.unknown => (l10n.resultUnknownTitle, AppColors.textLabel),
    };

String checkReasonLabel(CheckReason reason, AppLocalizations l10n) =>
    switch (reason) {
      CheckReason.checkedBefore => l10n.reasonCheckedBefore,
      CheckReason.recalled => l10n.reasonRecalled,
      CheckReason.expired => l10n.reasonExpired,
      CheckReason.damaged => l10n.reasonDamaged,
      CheckReason.switchedOff => l10n.reasonSwitchedOff,
      CheckReason.unknown => l10n.reasonUnknown,
    };

/// The sentence in a check's grey box: what the result means; for a
/// warning, its reasons.
String checkSentence(CheckRecord check, AppLocalizations l10n) =>
    switch (check.result) {
      CheckResult.valid => l10n.resultValidTitle,
      CheckResult.warning when check.reasons.isNotEmpty =>
        check.reasons.map((r) => checkReasonLabel(r, l10n)).join(' · '),
      CheckResult.warning => l10n.resultWarningTitle,
      CheckResult.notFound => l10n.resultNotFoundBody,
      CheckResult.unassigned => l10n.resultUnassignedBody,
      CheckResult.unknown => l10n.resultUnknownBody,
    };

/// One check in History (final.md §13.4), in the Figma "product
/// history" layout: the serial and the result badge; batch, day, and time;
/// who checked it; a grey box saying what the result means; the way, the
/// session when the check belongs to one, and the reference (SRS
/// FR-HIS-04: "the official, and the session if any"). The official is
/// always the one logged in (backend D61).
class CheckTile extends StatelessWidget {
  const CheckTile({required this.check, this.number, super.key});

  final CheckRecord check;

  /// The place in a tracking log ("01"), newest first; none in the plain
  /// list.
  final int? number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (label, color) = checkResultStyle(check.result, l10n);
    final (wayIcon, wayLabel) = switch (check.way) {
      CheckWay.qr => (LucideIcons.qrCode, l10n.wayQr),
      CheckWay.serial => (LucideIcons.hash, l10n.waySerial),
      CheckWay.hiddenCode => (LucideIcons.tag, l10n.wayHiddenCode),
      CheckWay.unknown => (LucideIcons.circleHelp, l10n.wayOther),
    };
    final when = DisplayTime.dayAndTime(
      check.at,
      locale,
      now: clock.now(),
      today: l10n.historyToday,
      yesterday: l10n.historyYesterday,
    );
    final details = [
      ?check.product,
      if (check.batch != null) '${l10n.batchLabel} ${check.batch}',
    ].join(' · ');
    final number = this.number;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (number != null) ...[
                    _Number(number),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          check.serial ?? check.ref,
                          style: AppTypography.bodyStrong,
                        ),
                        if (details.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            details,
                            key: const Key('checkTile.details'),
                            style: AppTypography.caption,
                          ),
                        ],
                        Text(
                          when,
                          key: const Key('checkTile.when'),
                          style: AppTypography.caption,
                        ),
                        if (check.official.trim().isNotEmpty)
                          Text(
                            l10n.historyCheckedBy(check.official.trim()),
                            key: const Key('checkTile.official'),
                            style: AppTypography.caption,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _Badge(label: label, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              DecoratedBox(
                key: const Key('checkTile.sentence'),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.sm),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      checkSentence(check, l10n),
                      style: AppTypography.caption.copyWith(
                        color: check.result == CheckResult.warning
                            ? AppColors.warning
                            : AppColors.textStrong,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Footer(
                way: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(wayIcon, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        switch (check.sessionId) {
                          final id? => [
                            wayLabel,
                            l10n.historySession(shortSessionId(id)),
                          ].join(' · '),
                          null => wayLabel,
                        },
                        key: const Key('checkTile.way'),
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
                reference: Text(
                  check.ref,
                  key: const Key('checkTile.ref'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A session as officials see it: the ID's first 8 characters in capitals
/// ("7F3C2A10"), enough to tell sessions apart on a screen.
String shortSessionId(String id) {
  final plain = id.replaceAll('-', '').toUpperCase();
  return plain.length <= 8 ? plain : plain.substring(0, 8);
}

/// The result as a coloured pill.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A check's place in a tracking log: "01" in a small grey square.
class _Number extends StatelessWidget {
  const _Number(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('checkTile.number'),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          number.toString().padLeft(2, '0'),
          style: AppTypography.bodyStrong.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

/// The way on the left, the reference on the right; one above the other
/// at a large font, so the reference never breaks.
class _Footer extends StatelessWidget {
  const _Footer({required this.way, required this.reference});

  final Widget way;
  final Text reference;

  @override
  Widget build(BuildContext context) {
    if (isLargeText(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          way,
          const SizedBox(height: AppSpacing.xxs),
          reference,
        ],
      );
    }
    // The reference keeps its own width (it is short); the way takes
    // what is left and wraps if it must.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: way),
        const SizedBox(width: AppSpacing.sm),
        reference,
      ],
    );
  }
}
