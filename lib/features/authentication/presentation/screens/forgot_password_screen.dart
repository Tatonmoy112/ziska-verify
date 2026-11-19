import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/authentication/domain/services/email_check.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/password_cubits.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// `auth/password/forgot`. The answer is always the same, whether or not the
/// email has an account (final.md Section 6.6).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({this.initialEmail, super.key});

  /// The email of a reset that asks for a new code (guide §3.7).
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _valid => looksLikeEmail(_email.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: BlocConsumer<ForgotPasswordCubit, SubmitState>(
        listener: (context, state) {
          if (state.status != SubmitStatus.success) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.forgotSent)));
          context.pushReplacementNamed(
            RouteNames.resetPassword,
            extra: _email.text.trim(),
          );
        },
        builder: (context, state) => ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: l10n.forgotTitle,
              subtitle: l10n.forgotSubtitle,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    fieldKey: const Key('forgot.email'),
                    label: l10n.emailLabel,
                    hint: l10n.emailHint,
                    controller: _email,
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.send,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (_valid) {
                        unawaited(
                          context.read<ForgotPasswordCubit>().submit(
                            _email.text,
                          ),
                        );
                      }
                    },
                  ),
                  if (state.status == SubmitStatus.failure) ...[
                    const SizedBox(height: AppSpacing.sm),
                    FailureBanner(
                      failure: state.failure!,
                      retryAt: state.retryAt,
                      message: state.failure!.message(l10n),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  RetryCountdown(
                    until: state.retryAt,
                    builder: (context, seconds) => AppButton(
                      key: const Key('forgot.submit'),
                      label: l10n.sendCodeButton,
                      loading: state.isSubmitting,
                      onPressed: _valid && seconds == 0
                          ? () => context.read<ForgotPasswordCubit>().submit(
                              _email.text,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
