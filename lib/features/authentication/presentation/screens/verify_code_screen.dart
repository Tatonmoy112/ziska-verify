import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/verify_code_bloc.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_otp_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/navy_status_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// The emailed code for a new phone (final.md §6).
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({required this.email, super.key});

  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.length == AppOtpField.length;

  void _submit() {
    if (!_complete) return;
    FocusScope.of(context).unfocus();
    context.read<VerifyCodeBloc>().add(CodeSubmitted(_code.text));
  }

  void _backToLogin() =>
      context.read<VerifyCodeBloc>().add(const BackToLoginRequested());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin();
      },
      child: NavyStatusBar(
        child: Scaffold(
          body: BlocConsumer<VerifyCodeBloc, VerifyCodeState>(
            listenWhen: (a, b) =>
                a.resentCount != b.resentCount ||
                (!a.resendLimitReached && b.resendLimitReached),
            listener: (context, state) {
              final messenger = ScaffoldMessenger.of(context);
              if (state.resendLimitReached) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.resendLimitReached)),
                );
                _backToLogin();
                return;
              }
              messenger.showSnackBar(SnackBar(content: Text(l10n.codeResent)));
            },
            builder: (context, state) {
              final submit = state.submit;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  GradientHeader(
                    title: l10n.verifyCodeTitle,
                    subtitle: l10n.verifyCodeSubtitle(widget.email),
                    onBack: _backToLogin,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppOtpField(
                          fieldKey: const Key('verify.code'),
                          label: l10n.codeLabel,
                          controller: _code,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                        ),
                        if (submit.status == SubmitStatus.failure) ...[
                          const SizedBox(height: AppSpacing.sm),
                          FailureBanner(
                            failure: submit.failure!,
                            retryAt: submit.retryAt,
                            message:
                                submit.failure!.exception
                                    is UnauthenticatedException
                                ? l10n.codeWrong
                                : submit.failure!.message(l10n),
                          ),
                        ],
                        if (state.resendFailure != null &&
                            state.resendFailure!.exception
                                is! RateLimitedException &&
                            !state.resendLimitReached) ...[
                          const SizedBox(height: AppSpacing.sm),
                          ErrorBanner(
                            message: state.resendFailure!.message(l10n),
                            requestId: state.resendFailure!.requestId,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        RetryCountdown(
                          until: submit.retryAt,
                          builder: (context, seconds) => AppButton(
                            key: const Key('verify.submit'),
                            label: l10n.verifyButton,
                            loading: submit.isSubmitting,
                            onPressed: _complete && seconds == 0
                                ? _submit
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        RetryCountdown(
                          until: state.resendAvailableAt,
                          builder: (context, seconds) => TextButton(
                            onPressed: seconds > 0 || state.resending
                                ? null
                                : () => context.read<VerifyCodeBloc>().add(
                                    const ResendRequested(),
                                  ),
                            child: Text(
                              seconds > 0
                                  ? l10n.resendIn(seconds)
                                  : l10n.resendCode,
                              style: seconds > 0
                                  ? AppTypography.caption
                                  : AppTypography.link,
                            ),
                          ),
                        ),
                        AppButton(
                          label: l10n.backToLogin,
                          variant: AppButtonVariant.tonal,
                          onPressed: _backToLogin,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
