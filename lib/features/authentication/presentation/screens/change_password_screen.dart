import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/password_cubits.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';
import 'package:ziska_verify/features/authentication/presentation/widgets/password_rules.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';

/// `me/password` (final.md Section 6.6). When [forced], it is the only
/// screen allowed: back is blocked and Logout is the only way out.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({required this.forced, super.key});

  final bool forced;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const _policy = PasswordPolicy();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  PasswordCheck get _check => _policy.check(_new.text);
  bool get _matches => _new.text == _repeat.text;
  bool get _ready => _old.text.isNotEmpty && _check.isValid && _matches;

  String _errorText(AppLocalizations l10n, SubmitState state) =>
      switch (state.failure!.exception) {
        UnauthenticatedException() => l10n.currentPasswordWrong,
        PolicyDeniedException() => l10n.passwordRuleBroken,
        _ => state.failure!.message(l10n),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !widget.forced,
      child: Scaffold(
        body: BlocConsumer<ChangePasswordCubit, SubmitState>(
          listener: (context, state) {
            if (state.status != SubmitStatus.success) return;
            if (widget.forced) {
              // Continues to Home; the guard shows Splash until the profile
              // has loaded (final.md Section 9.4).
              context.goNamed(RouteNames.home);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.passwordChanged)),
              );
              unawaited(Navigator.of(context).maybePop());
            }
          },
          builder: (context, state) => ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                title: l10n.changePasswordTitle,
                subtitle: widget.forced
                    ? l10n.changePasswordForcedSubtitle
                    : l10n.changePasswordSubtitle,
                onBack: widget.forced
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPasswordField(
                      fieldKey: const Key('change.old'),
                      label: l10n.currentPasswordLabel,
                      showLabel: l10n.showPassword,
                      hideLabel: l10n.hidePassword,
                      controller: _old,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                    AppPasswordField(
                      fieldKey: const Key('change.new'),
                      label: l10n.newPasswordLabel,
                      showLabel: l10n.showPassword,
                      hideLabel: l10n.hidePassword,
                      controller: _new,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => setState(() {}),
                    ),
                    PasswordRules(check: _check),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      fieldKey: const Key('change.repeat'),
                      label: l10n.confirmPasswordLabel,
                      showLabel: l10n.showPassword,
                      hideLabel: l10n.hidePassword,
                      controller: _repeat,
                      autofillHints: const [AutofillHints.newPassword],
                      errorText: _repeat.text.isNotEmpty && !_matches
                          ? l10n.passwordsDoNotMatch
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (state.status == SubmitStatus.failure) ...[
                      FailureBanner(
                        failure: state.failure!,
                        retryAt: state.retryAt,
                        message: _errorText(l10n, state),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppButton(
                      key: const Key('change.submit'),
                      label: l10n.changePasswordButton,
                      loading: state.isSubmitting,
                      onPressed: _ready
                          ? () => context.read<ChangePasswordCubit>().submit(
                              oldPassword: _old.text,
                              newPassword: _new.text,
                            )
                          : null,
                    ),
                    if (widget.forced) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.logout,
                        variant: AppButtonVariant.tonal,
                        onPressed: () =>
                            context.read<ChangePasswordCubit>().logout(),
                      ),
                    ],
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
