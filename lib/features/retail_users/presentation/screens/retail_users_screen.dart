import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_admin_cubits.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_search_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Retail users (final.md Section 13.6): the client's retail users, adding
/// one, and emailing a new first password. Needs `retail_user:add`.
class RetailUsersScreen extends StatelessWidget {
  const RetailUsersScreen({super.key});

  static const _placeholder = RetailUser(
    id: '',
    name: 'Retail user name',
    maskedEmail: 'ab***@example.com',
  );

  Future<void> _confirmEmail(BuildContext context, RetailUser user) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.retailUserEmailPassword),
        content: Text(l10n.retailUserEmailPasswordConfirm(user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.retailUserEmailPasswordSend),
          ),
        ],
      ),
    );
    if ((ok ?? false) && context.mounted) {
      await context.read<EmailPasswordCubit>().send(
        id: user.id,
        name: user.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = context.read<RetailUserPickerBloc>();
    return BlocListener<EmailPasswordCubit, EmailPasswordState>(
      listenWhen: (a, b) => a.count != b.count,
      listener: (context, state) {
        final name = state.lastName ?? '';
        final text = switch (state.lastFailure?.exception) {
          null => l10n.retailUserPasswordEmailed(name),
          ConflictException() => l10n.retailUserOwnPassword(name),
          NotFoundException() => l10n.retailUserNotFound,
          _ => state.lastFailure!.message(l10n),
        };
        final wait = state.retryAt;
        // Every error carries its reference (final.md Section 14.1).
        final requestId = state.lastFailure?.requestId;
        final reference = requestId == null
            ? ''
            : '\n${l10n.reference(requestId)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // A `429` counts down while it shows (final.md Section 15.4).
            content: wait == null
                ? Text('$text$reference')
                : RetryCountdown(
                    until: wait,
                    builder: (context, seconds) =>
                        Text('${l10n.errorRateLimited(seconds)}$reference'),
                  ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        appBar: AppBar(title: Text(l10n.retailUsersTitle)),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('retailUsers.add'),
          onPressed: () async {
            await context.pushNamed(RouteNames.addRetailUser);
            list.add(const PickerRetried());
          },
          icon: const Icon(LucideIcons.userPlus),
          label: Text(l10n.retailUsersAdd),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.md,
              ),
              child: AppSearchField(
                fieldKey: const Key('retailUsers.search'),
                hint: l10n.retailUsersSearchHint,
                maxLength: SearchRetailUsers.maxSearchLength,
                onChanged: (t) => list.add(PickerSearchTyped(t)),
              ),
            ),
            Expanded(
              child: BlocBuilder<RetailUserPickerBloc, RetailUserPickerState>(
                builder: (context, state) => AppPaginatedList<RetailUser>(
                  state: state.list,
                  placeholderItem: _placeholder,
                  itemBuilder: (context, user) => _RetailUserTile(
                    user: user,
                    onEmailPassword: () =>
                        unawaited(_confirmEmail(context, user)),
                  ),
                  onNextPage: () => list.add(const PickerNextPageRequested()),
                  onRetry: () => list.add(const PickerRetried()),
                  onRefresh: () async => list.add(const PickerRetried()),
                  emptyTitle: l10n.retailUsersEmpty,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetailUserTile extends StatelessWidget {
  const _RetailUserTile({required this.user, required this.onEmailPassword});

  final RetailUser user;
  final VoidCallback onEmailPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = context.select<EmailPasswordCubit, bool>(
      (c) => c.state.busyId == user.id,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.xs,
      ),
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.surfaceMuted,
            child: Icon(LucideIcons.store, color: AppColors.primary),
          ),
          title: Text(user.name, style: AppTypography.bodyStrong),
          subtitle: Text(user.maskedEmail, style: AppTypography.caption),
          trailing: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PopupMenuButton<void>(
                  icon: const Icon(LucideIcons.ellipsisVertical),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: onEmailPassword,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mailPlus, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(child: Text(l10n.retailUserEmailPassword)),
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
