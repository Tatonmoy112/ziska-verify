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
import 'package:ziska_verify/shared/design_system/components/inputs/app_otp_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/navy_status_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// `auth/password/reset`: ends every login and forgets every trusted phone;
/// the official logs in again (final.md §6).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({required this.email, super.key});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const _policy = PasswordPolicy();
  final _code = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  PasswordCheck get _check => _policy.check(_new.text);
  bool get _matches => _new.text == _repeat.text;
  bool get _ready =>
      _code.text.length == AppOtpField.length && _check.isValid && _matches;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavyStatusBar(
      child: Scaffold(
        body: BlocConsumer<ResetPasswordCubit, SubmitState>(
          listener: (context, state) {
            if (state.status != SubmitStatus.success) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.resetDone)));
            context.goNamed(RouteNames.login);
          },
          builder: (context, state) => ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                title: l10n.resetTitle,
                subtitle: l10n.resetSubtitle(widget.email),
                onBack: () => context.goNamed(RouteNames.login),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppOtpField(
                      fieldKey: const Key('reset.code'),
                      label: l10n.codeLabel,
                      controller: _code,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      fieldKey: const Key('reset.new'),
                      label: l10n.newPasswordLabel,
                      showLabel: l10n.showPassword,
                      hideLabel: l10n.hidePassword,
                      controller: _new,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => setState(() {}),
                    ),
                    PasswordRules(check: _check),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      fieldKey: const Key('reset.repeat'),
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
                      const SizedBox(height: AppSpacing.md),
                      FailureBanner(
                        failure: state.failure!,
                        retryAt: state.retryAt,
                        message: switch (state.failure!.exception) {
                          // Also after 10 wrong codes in an hour (backend
                          // D64): the answer is the same, so is the text.
                          UnauthenticatedException() => l10n.resetCodeWrong,
                          PolicyDeniedException() => l10n.passwordRuleBroken,
                          _ => state.failure!.message(l10n),
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    RetryCountdown(
                      until: state.retryAt,
                      builder: (context, seconds) => AppButton(
                        key: const Key('reset.submit'),
                        label: l10n.resetButton,
                        loading: state.isSubmitting,
                        onPressed: _ready && seconds == 0
                            ? () => context.read<ResetPasswordCubit>().submit(
                                email: widget.email,
                                code: _code.text,
                                newPassword: _new.text,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Step 1 again, with the email kept (guide §3.7, D64).
                    Center(
                      child: TextButton(
                        key: const Key('reset.newCode'),
                        onPressed: state.isSubmitting
                            ? null
                            : () => context.pushReplacementNamed(
                                RouteNames.forgotPassword,
                                extra: widget.email,
                              ),
                        child: Text(l10n.resetNewCode),
                      ),
                    ),
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
