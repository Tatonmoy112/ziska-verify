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
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// `me/password` (final.md Section 6.6). When [forced], it is the only
/// screen allowed and back is blocked. Without [canSkip], Logout is the only
/// way out; with it (the backend's `password_change_skippable`), the
/// official may also choose **Not now** (`me/password/later`), which needs
/// a [PostponePasswordCubit] above this screen.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    required this.forced,
    this.canSkip = false,
    super.key,
  });

  final bool forced;
  final bool canSkip;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const _policy = PasswordPolicy();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  /// The backend refused **Not now** (`403 forbidden`): it is hidden and
  /// its message stays shown.
  SubmitState? _laterRefusal;
  bool get _laterRefused => _laterRefusal != null;

  bool get _choice => widget.forced && widget.canSkip && !_laterRefused;

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

  String _laterErrorText(AppLocalizations l10n, SubmitState state) =>
      switch (state.failure!.exception) {
        ForbiddenException() => l10n.passwordLaterRefused,
        _ => state.failure!.message(l10n),
      };

  String _errorText(AppLocalizations l10n, SubmitState state) =>
      switch (state.failure!.exception) {
        UnauthenticatedException() => l10n.currentPasswordWrong,
        PolicyDeniedException() => l10n.passwordRuleBroken,
        _ => state.failure!.message(l10n),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screen = BlocConsumer<ChangePasswordCubit, SubmitState>(
      listener: (context, state) {
        if (state.status != SubmitStatus.success) return;
        if (widget.forced) {
          // Continues to Home; the guard shows Splash until the profile has
          // loaded (final.md Section 9.4).
          context.goNamed(RouteNames.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.passwordChanged)),
          );
          // `true`: Profile reloads, so its reminder goes.
          unawaited(Navigator.of(context).maybePop(true));
        }
      },
      builder: (context, state) => _choice
          ? BlocConsumer<PostponePasswordCubit, SubmitState>(
              listener: (context, later) {
                switch (later.status) {
                  case SubmitStatus.success:
                    // Not now: on to Home, as after a change.
                    context.goNamed(RouteNames.home);
                  case SubmitStatus.failure
                      when later.failure!.exception is ForbiddenException:
                    setState(() => _laterRefusal = later);
                  case _:
                    break;
                }
              },
              builder: (context, later) => _form(context, l10n, state, later),
            )
          : _form(context, l10n, state, null),
    );
    return PopScope(
      canPop: !widget.forced,
      child: Scaffold(body: screen),
    );
  }

  /// The form. [later] is the **Not now** request's state in the choice
  /// mode; `null` otherwise.
  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    SubmitState state,
    SubmitState? later,
  ) {
    final busy = state.isSubmitting || (later?.isSubmitting ?? false);
    // The last failure of either request; a refused Not now shows its own
    // message.
    final failed = later?.status == SubmitStatus.failure
        ? later
        : state.status == SubmitStatus.failure
        ? state
        : _laterRefusal;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GradientHeader(
          title: widget.forced
              ? l10n.changePasswordTitle
              : l10n.changePasswordRow,
          subtitle: _choice
              ? l10n.changePasswordChoiceSubtitle
              : widget.forced
              ? l10n.changePasswordForcedSubtitle
              : l10n.changePasswordSubtitle,
          onBack: widget.forced ? null : () => Navigator.of(context).maybePop(),
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
              const SizedBox(height: AppSpacing.md),
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
              if (failed != null) ...[
                const SizedBox(height: AppSpacing.md),
                FailureBanner(
                  failure: failed.failure!,
                  retryAt: failed.retryAt,
                  message:
                      identical(failed, later) ||
                          identical(failed, _laterRefusal)
                      ? _laterErrorText(l10n, failed)
                      : _errorText(l10n, failed),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              RetryCountdown(
                until: state.retryAt,
                builder: (context, seconds) => AppButton(
                  key: const Key('change.submit'),
                  label: l10n.changePasswordButton,
                  loading: state.isSubmitting,
                  onPressed: _ready && !busy && seconds == 0
                      ? () => context.read<ChangePasswordCubit>().submit(
                          oldPassword: _old.text,
                          newPassword: _new.text,
                        )
                      : null,
                ),
              ),
              if (later != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  key: const Key('change.later'),
                  label: l10n.changePasswordLater,
                  variant: AppButtonVariant.tonal,
                  loading: later.isSubmitting,
                  onPressed: busy
                      ? null
                      : () => context.read<PostponePasswordCubit>().submit(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton(
                    key: const Key('change.logout'),
                    onPressed: busy
                        ? null
                        : () => context.read<ChangePasswordCubit>().logout(),
                    child: Text(l10n.logout),
                  ),
                ),
              ] else if (widget.forced) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  key: const Key('change.logout'),
                  label: l10n.logout,
                  variant: AppButtonVariant.tonal,
                  onPressed: busy
                      ? null
                      : () => context.read<ChangePasswordCubit>().logout(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
