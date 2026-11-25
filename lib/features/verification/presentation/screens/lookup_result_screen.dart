import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/picture/picture_image_service.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/item_details_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/product_picture_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/result_entry_cards.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';

/// The lookup result (final.md §13.1, decisions 46, 47, 49),
/// shown unaltered from the backend. A genuine result: the top card, the
/// item's details, and its picture. A result without an item (`not_found`,
/// `unassigned`, unknown): the top card, what was entered, hints for
/// `not_found`, and Try again, Contact support, and Back to Check.
class LookupResultScreen extends StatelessWidget {
  const LookupResultScreen({
    required this.view,
    required this.pictures,
    required this.launcher,
    required this.onReport,
    super.key,
  });

  /// The result, what was looked up, and where it started.
  final ResultView view;
  final PictureImageService pictures;
  final LauncherService launcher;

  /// Opens New report, a page of the reports feature, for the check
  /// `checkRef`; wired by the router (final.md §9).
  final Future<void> Function(String checkRef) onReport;

  @override
  Widget build(BuildContext context) {
    final fromList = view.origin == ResultOrigin.manyItems;
    final l10n = AppLocalizations.of(context);
    final result = view.result;
    final item = result.item;
    final canReport = context.select<ProfileCubit, bool>(
      (c) => c.state.profile?.canReport ?? false,
    );
    final profile = context.select<ProfileCubit, Profile?>(
      (c) => c.state.profile,
    );
    final hasSupport =
        profile?.supportEmail != null || profile?.supportPhone != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: NavyAppBar(title: l10n.resultTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            VerificationResultCard(result: result),
            const SizedBox(height: AppSpacing.lg),
            if (item != null) ...[
              // Every field, and the check count of every found item.
              ItemDetailsCard(item: item, count: result.count),
              const SizedBox(height: AppSpacing.lg),
              ProductPictureCard(
                pictureUrl: item.product.pictureUrl,
                productName: item.product.name,
                pictures: pictures,
              ),
            ] else ...[
              EnteredCard(view: view),
              // Typing hints only when nothing matched; an item not in a
              // batch exists, and an unknown answer is not about typing.
              if (result.outcome == LookupOutcome.notFound) ...[
                const SizedBox(height: AppSpacing.lg),
                HintsCard(way: view.input.way, formats: view.formats),
              ],
            ],
            const SizedBox(height: AppSpacing.xl),
            if (canReport) ...[
              AppButton(
                key: const Key('result.report'),
                label: l10n.reportFromResult,
                icon: LucideIcons.flag,
                variant: AppButtonVariant.outlined,
                // The report carries this check's reference (§13.5).
                onPressed: () => onReport(result.ref),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (item != null)
              AppButton(
                label: fromList ? l10n.backToList : l10n.verifyAnother,
                onPressed: () => context.pop(),
              )
            else ...[
              // Back to where the lookup started: the Check form, the
              // scanner, or the scanner-mode or stack list.
              AppButton(
                key: const Key('result.tryAgain'),
                label: fromList ? l10n.backToList : l10n.tryAgainLookup,
                icon: fromList ? LucideIcons.list : LucideIcons.rotateCcw,
                onPressed: () => context.pop(),
              ),
              if (hasSupport) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  key: const Key('result.contactSupport'),
                  label: l10n.contactSupport,
                  icon: LucideIcons.headset,
                  variant: AppButtonVariant.outlined,
                  onPressed: () =>
                      unawaited(_contactSupport(context, profile!)),
                ),
              ],
              // From scanner mode or a stack, Home would end the session or
              // drop the stack's results: back to the list only.
              if (!fromList) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  key: const Key('result.backToVerify'),
                  label: l10n.backToVerify,
                  variant: AppButtonVariant.tonal,
                  onPressed: () => context.goNamed(RouteNames.home),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Emails the client's support with the reference and what was entered (a
  /// hidden code stays masked), or calls when only a phone is set.
  Future<void> _contactSupport(BuildContext context, Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final email = profile.supportEmail;
    if (email == null) {
      await launcher.call(profile.supportPhone!);
      return;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final messenger = ScaffoldMessenger.of(context);
    final sent = await launcher.email(
      to: email,
      subject: l10n.supportEmailSubject(view.result.ref),
      body: l10n.supportEmailBody(
        view.result.ref,
        wayName(view.input.way, l10n),
        view.input.shown,
        DisplayTime.dateTime(view.input.at, locale),
      ),
    );
    if (!sent) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noMailApp(email))));
    }
  }
}
