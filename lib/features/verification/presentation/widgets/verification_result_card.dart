import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The look of each result (final.md §13.1). An unknown
/// result is never shown as valid.
({Color color, Color background, IconData icon, String title, String body})
outcomeStyle(LookupOutcome outcome, AppLocalizations l10n) => switch (outcome) {
  LookupOutcome.valid => (
    color: AppColors.success,
    background: AppColors.successBackground,
    icon: LucideIcons.shieldCheck,
    title: l10n.resultValidTitle,
    body: l10n.resultValidBody,
  ),
  LookupOutcome.warning => (
    color: AppColors.warning,
    background: AppColors.warningBackground,
    icon: LucideIcons.triangleAlert,
    title: l10n.resultWarningTitle,
    body: l10n.resultWarningBody,
  ),
  LookupOutcome.notFound => (
    color: AppColors.danger,
    background: AppColors.dangerBackground,
    icon: LucideIcons.shieldX,
    title: l10n.resultNotFoundTitle,
    body: l10n.resultNotFoundBody,
  ),
  LookupOutcome.unassigned => (
    color: AppColors.textLabel,
    background: AppColors.surfaceMuted,
    icon: LucideIcons.packageX,
    title: l10n.resultUnassignedTitle,
    body: l10n.resultUnassignedBody,
  ),
  LookupOutcome.unknown => (
    color: AppColors.textLabel,
    background: AppColors.surfaceMuted,
    icon: LucideIcons.circleHelp,
    title: l10n.resultUnknownTitle,
    body: l10n.resultUnknownBody,
  ),
};

/// The top card of the result screen (final.md §13.1, decision
/// 46): a round icon, the title, a badge, what the result means, any
/// further reasons, and the reference number.
class VerificationResultCard extends StatelessWidget {
  const VerificationResultCard({required this.result, super.key});

  final LookupResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = outcomeStyle(result.outcome, l10n);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final reasons = result.outcome == LookupOutcome.warning
        ? result.reasons
        : const <LookupReason>[];
    final checkedBefore = reasons.contains(LookupReason.checkedBefore);
    // `checked_before` is told by the badge and the text; every other
    // reason is a row of its own.
    final others = [
      for (final r in reasons)
        if (r != LookupReason.checkedBefore) r,
    ];
    final badge = switch (result.outcome) {
      LookupOutcome.valid => l10n.badgeGenuine,
      LookupOutcome.warning =>
        checkedBefore ? l10n.reasonCheckedBefore : l10n.reasonUnknown,
      LookupOutcome.notFound => l10n.resultNotFoundTitle,
      LookupOutcome.unassigned => l10n.resultUnassignedTitle,
      LookupOutcome.unknown => l10n.resultUnknownTitle,
    };
    final count = result.count;
    final body = checkedBefore && count != null
        ? l10n.reasonCheckedBeforeDetail(
            count.thisCheck,
            count.lastAt == null
                ? '—'
                : DisplayTime.dateTime(count.lastAt!, locale),
          )
        : style.body;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: AppRadius.card,
        border: Border.all(color: style.color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The round icon in a soft halo of its colour (the Figma result).
            Center(
              child: DecoratedBox(
                key: const Key('result.icon.halo'),
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: SizedBox.square(
                    dimension: 64,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: style.color.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        style.icon,
                        color: AppColors.onPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                style.title,
                style: AppTypography.headline,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: ResultBadge(label: badge, color: style.color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: AppTypography.body, textAlign: TextAlign.center),
            if (others.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              for (final reason in others) ReasonChip(reason: reason),
            ],
            const Divider(height: AppSpacing.xl),
            _ReferenceRow(reference: result.ref),
          ],
        ),
      ),
    );
  }
}

/// The result's badge: upper-case white text on the result colour.
class ResultBadge extends StatelessWidget {
  const ResultBadge({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.fieldLabel.copyWith(color: AppColors.onPrimary),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// One `warning` reason, each with its own label and icon.
class ReasonChip extends StatelessWidget {
  const ReasonChip({required this.reason, this.detail, super.key});

  final LookupReason reason;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label) = switch (reason) {
      LookupReason.checkedBefore => (
        LucideIcons.history,
        l10n.reasonCheckedBefore,
      ),
      LookupReason.recalled => (LucideIcons.undo2, l10n.reasonRecalled),
      LookupReason.expired => (LucideIcons.calendarX, l10n.reasonExpired),
      LookupReason.damaged => (LucideIcons.packageX, l10n.reasonDamaged),
      LookupReason.switchedOff => (LucideIcons.ban, l10n.reasonSwitchedOff),
      LookupReason.unknown => (LucideIcons.triangleAlert, l10n.reasonUnknown),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.input,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.bodyStrong),
                    if (detail != null)
                      Text(detail!, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.referenceNumber.toUpperCase(),
                style: AppTypography.fieldLabel,
              ),
              SelectableText(reference, style: AppTypography.bodyStrong),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.copyReference,
          icon: const Icon(LucideIcons.copy, size: 20),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: reference));
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.copied)));
          },
        ),
      ],
    );
  }
}
