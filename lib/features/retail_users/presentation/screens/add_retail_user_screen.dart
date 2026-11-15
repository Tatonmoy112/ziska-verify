import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user_admin.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_admin_cubits.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';

/// Add a retail user (final.md Section 13.6.1).
class AddRetailUserScreen extends StatefulWidget {
  const AddRetailUserScreen({super.key});

  @override
  State<AddRetailUserScreen> createState() => _AddRetailUserScreenState();
}

class _AddRetailUserScreenState extends State<AddRetailUserScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  int? _roleId;
  bool _sendEmail = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    // The typed first password is never kept (Section 13.6.1).
    _password.dispose();
    super.dispose();
  }

  bool get _ready =>
      _name.text.trim().isNotEmpty &&
      RetailUserRules.isEmailValid(_email.text) &&
      _roleId != null &&
      RetailUserRules.isFirstPasswordValid(_password.text);

  void _submit() {
    FocusScope.of(context).unfocus();
    unawaited(
      context.read<AddRetailUserCubit>().submit(
        name: _name.text,
        email: _email.text,
        roleId: _roleId!,
        password: _password.text,
        sendEmail: _sendEmail,
      ),
    );
  }

  void _addAnother() {
    _name.clear();
    _email.clear();
    _password.clear();
    setState(() => _sendEmail = true);
    context.read<AddRetailUserCubit>().addAnother();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(title: Text(l10n.addRetailUserTitle)),
      body: BlocBuilder<AddRetailUserCubit, AddRetailUserState>(
        builder: (context, state) => switch (state.status) {
          AddStatus.loadingRoles => const Center(
            child: CircularProgressIndicator(),
          ),
          AddStatus.rolesFailed => Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              children: [
                ErrorBanner(
                  message: state.failure!.message(l10n),
                  requestId: state.failure!.requestId,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.retry,
                  onPressed: () =>
                      context.read<AddRetailUserCubit>().loadRoles(),
                ),
              ],
            ),
          ),
          AddStatus.done => _Done(
            added: state.added!,
            password: state.passwordToShow,
            onAddAnother: _addAnother,
          ),
          _ when state.roles.isEmpty => AppEmptyState(
            icon: LucideIcons.userX,
            title: l10n.addRetailUserTitle,
            body: l10n.addRetailUserNoRoles,
          ),
          _ => _form(context, l10n, state),
        },
      ),
    );
  }

  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    AddRetailUserState state,
  ) {
    final failure = state.failure;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        AppTextField(
          fieldKey: const Key('addRetail.name'),
          label: l10n.addRetailUserName,
          hint: l10n.addRetailUserNameHint,
          controller: _name,
          maxLength: RetailUserRules.nameMaxLength,
          prefixIcon: LucideIcons.store,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          fieldKey: const Key('addRetail.email'),
          label: l10n.addRetailUserEmail,
          hint: l10n.addRetailUserEmailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: LucideIcons.mail,
          errorText:
              _email.text.isNotEmpty &&
                  !RetailUserRules.isEmailValid(_email.text)
              ? l10n.emailInvalid
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.addRetailUserRole.toUpperCase(),
          style: AppTypography.fieldLabel,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<int>(
          key: const Key('addRetail.role'),
          initialValue: _roleId,
          // The field width, so a long role name or a large font fits.
          isExpanded: true,
          // Also the name a screen reader reads for the field.
          hint: Text(l10n.addRetailUserRole),
          items: [
            for (final role in state.roles)
              DropdownMenuItem(
                value: role.id,
                child: Text(role.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _roleId = v),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPasswordField(
          fieldKey: const Key('addRetail.password'),
          label: l10n.addRetailUserPassword,
          hint: l10n.addRetailUserPasswordHint,
          showLabel: l10n.showPassword,
          hideLabel: l10n.hidePassword,
          controller: _password,
          autofillHints: const [],
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          key: const Key('addRetail.sendEmail'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.addRetailUserSendEmail),
          subtitle: _sendEmail
              ? null
              : Text(
                  l10n.addRetailUserSendEmailOff,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
          value: _sendEmail,
          onChanged: (v) => setState(() => _sendEmail = v),
        ),
        if (state.status == AddStatus.failed && failure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FailureBanner(
            failure: failure,
            retryAt: state.retryAt,
            message: switch (failure.exception) {
              ConflictException() => l10n.addRetailUserEmailInUse,
              NotFoundException() => l10n.addRetailUserRoleGone,
              _ => failure.message(l10n),
            },
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('addRetail.submit'),
          label: l10n.addRetailUserSubmit,
          loading: state.status == AddStatus.submitting,
          onPressed: _ready ? _submit : null,
        ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({
    required this.added,
    required this.password,
    required this.onAddAnother,
  });

  final AddedRetailUser added;
  final String? password;
  final VoidCallback onAddAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (message, color) = switch (added.emailOutcome) {
      EmailOutcome.sent => (
        l10n.addRetailUserEmailed(added.email),
        AppColors.success,
      ),
      EmailOutcome.failed => (l10n.addRetailUserMailFailed, AppColors.warning),
      EmailOutcome.notRequested => (
        l10n.addRetailUserGiveYourself,
        AppColors.primary,
      ),
    };
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Icon(LucideIcons.circleCheck, size: 48, color: color),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.addRetailUserDoneTitle(added.name),
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, style: AppTypography.body, textAlign: TextAlign.center),
        if (password != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addRetailUserPasswordOnce,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        password!,
                        key: const Key('addRetail.passwordOnce'),
                        style: AppTypography.headline,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.copyPassword,
                      icon: const Icon(LucideIcons.copy),
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: password!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.addRetailUserFirstLogin,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: l10n.reportDone, onPressed: () => context.pop()),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.addAnother,
          variant: AppButtonVariant.outlined,
          onPressed: onAddAnother,
        ),
      ],
    );
  }
}
