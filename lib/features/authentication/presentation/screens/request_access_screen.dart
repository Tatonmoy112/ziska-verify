import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/request_access_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';
import 'package:ziska_verify/shared/widgets/numbered_step_row.dart';

/// Request access (final.md Section 13.9; backend D27): how an account is
/// made, the details to include, and the office's email and phone; nothing
/// is sent to the backend. The first password is emailed or handed over in
/// person (backend D55). The look follows the Figma "Request for id".
class RequestAccessScreen extends StatelessWidget {
  const RequestAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RequestAccessCubit>();
    final includes = [
      l10n.includeName,
      l10n.includePhone,
      l10n.includeOrganisation,
      l10n.includeEmail,
      l10n.includeJobTitle,
      l10n.includeReason,
    ];

    return BlocListener<RequestAccessCubit, RequestAccessResult>(
      listener: (context, result) {
        if (result != RequestAccessResult.noApp) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noMailApp(cubit.officeEmail))),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  GradientHeader(
                    title: l10n.requestAccessTitle,
                    subtitle: l10n.requestAccessSubtitle,
                    onBack: () => context.pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HowItWorksCard(
                          title: l10n.howItWorks,
                          steps: [
                            (
                              l10n.requestStepSendTitle,
                              cubit.hasPhone
                                  ? l10n.requestStepSendBody
                                  : l10n.requestStepSendBodyEmailOnly,
                            ),
                            (
                              l10n.requestStepCheckTitle,
                              l10n.requestStepCheckBody,
                            ),
                            (
                              l10n.requestStepLoginTitle,
                              l10n.requestStepLoginBody,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _IncludeCard(
                          title: l10n.pleaseInclude,
                          items: includes,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.xs,
                  AppSpacing.screen,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    AppButton(
                      label: l10n.emailTeamButton,
                      icon: LucideIcons.mail,
                      onPressed: () => cubit.email(
                        subject: l10n.accessRequestSubject,
                        body: '${includes.map((i) => '$i: ').join('\n')}\n',
                      ),
                    ),
                    if (cubit.hasPhone) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.callTeamButton,
                        icon: LucideIcons.phone,
                        variant: AppButtonVariant.outlined,
                        onPressed: cubit.call,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.backToLogin,
                      variant: AppButtonVariant.tonal,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncludeCard extends StatelessWidget {
  const _IncludeCard({required this.title, required this.items});

  /// Narrowest list width that still fits two columns of items.
  static const _twoColumnMinWidth = 260.0;

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.info,
                size: 20,
                color: AppColors.infoAccent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.infoAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two columns as in the Figma; one when the text is large or
              // the card is narrow, so no item is cut or wraps mid-word.
              final columns =
                  !isLargeText(context) &&
                      constraints.maxWidth >= _twoColumnMinWidth
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * AppSpacing.sm) /
                  columns;
              return Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: _IncludeItem(item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IncludeItem extends StatelessWidget {
  const _IncludeItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          const Icon(
            LucideIcons.check,
            size: 16,
            color: AppColors.infoAccent,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

/// The white "HOW IT WORKS" card: a pill title and numbered steps split by
/// dividers (Figma "Request for id").
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({required this.title, required this.steps});

  final String title;

  /// Each step's title and body, in order.
  final List<(String, String)> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: DecoratedBox(
              key: const Key('requestAccess.howItWorks'),
              decoration: const BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.pill),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.fieldLabel.copyWith(
                    color: AppColors.infoAccent,
                  ),
                ),
              ),
            ),
          ),
          for (final (i, (stepTitle, body)) in steps.indexed) ...[
            if (i > 0)
              const Divider(height: AppSpacing.lg, color: AppColors.border)
            else
              const SizedBox(height: AppSpacing.md),
            NumberedStepRow(
              key: Key('requestAccess.step${i + 1}'),
              number: i + 1,
              title: stepTitle,
              body: body,
            ),
          ],
        ],
      ),
    );
  }
}
