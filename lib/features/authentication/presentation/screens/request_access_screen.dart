import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/services/email_check.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/request_access_cubit.dart';
import 'package:ziska_verify/features/authentication/presentation/widgets/password_rules.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_otp_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Sign up: the access request of the app API guide §3.9 under the name
/// users see, no login needed (app API guide §3.9, final.md Section
/// 13.9): the name, the role, the password and the email first; then the
/// emailed code; then the request.
class RequestAccessScreen extends StatefulWidget {
  const RequestAccessScreen({required this.onContactOffice, super.key});
  final VoidCallback? onContactOffice;
  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  int? _role;
  int _codeVersion = 0;

  /// Which request runs, so only its button spins.
  bool _submitting = false;
  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _code]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _name.text.trim().length <= AccessRequest.nameMaxLength &&
      looksLikeEmail(_email.text) &&
      const PasswordPolicy().check(_password.text).isValid &&
      _role != null;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<RequestAccessCubit>();
    final header = GradientHeader(
      title: l.requestAccessTitle,
      subtitle: l.requestAccessSubtitle,
      onBack: () => context.pop(),
    );
    return Scaffold(
      body: BlocConsumer<RequestAccessCubit, RequestAccessState>(
        listener: (_, state) {
          if (_codeVersion != state.codeVersion) {
            _code.clear();
            _codeVersion = state.codeVersion;
          }
          if (state.stage == AccessStage.pending) {
            _password.clear();
            _code.clear();
          }
          if (_role != null && !state.roles.any((r) => r.id == _role)) {
            setState(() => _role = null);
          }
        },
        listenWhen: (a, b) =>
            a.stage != b.stage ||
            a.roles != b.roles ||
            a.codeVersion != b.codeVersion,
        builder: (_, state) {
          if (state.stage == AccessStage.loading) {
            return Column(
              children: [
                header,
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }
          if (state.stage == AccessStage.pending) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        LucideIcons.mailCheck,
                        size: 48,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.accessPending,
                        key: const Key('access.pending'),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyStrong,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: l.backToLogin,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          final failure = state.failure;
          final message = switch (failure?.exception) {
            UnauthenticatedException() => l.accessWrongCode,
            // The chosen password breaks the rule (guide section 3.9).
            PolicyDeniedException() => l.passwordRuleBroken,
            ConflictException() => l.accessTryLater,
            // "Role not found." on sending (guide §3.9); any other 404 is
            // the app not being available (guide §1).
            NotFoundException(:final message)
                when state.rolesLoaded &&
                    (message?.toLowerCase().contains('role') ?? false) =>
              l.accessRoleUnavailable,
            _ => failure?.message(l) ?? '',
          };
          return RetryCountdown(
            until: state.retryAt,
            builder: (_, seconds) => ListView(
              padding: EdgeInsets.zero,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (failure != null) ...[
                        FailureBanner(
                          failure: failure,
                          message: message,
                          retryAt: state.retryAt,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (!state.rolesLoaded) ...[
                        // The load failed (the banner above says why): only
                        // Try again, never "Ask the office" (audit H4).
                        AppButton(
                          key: const Key('access.retryRoles'),
                          variant: AppButtonVariant.tonal,
                          label: l.retry,
                          onPressed: seconds > 0
                              ? null
                              : () => unawaited(cubit.load()),
                        ),
                      ] else if (state.roles.isEmpty) ...[
                        Text(l.accessNoRoles, style: AppTypography.body),
                        const SizedBox(height: AppSpacing.lg),
                        if (widget.onContactOffice != null) ...[
                          AppButton(
                            label: l.accessContactOffice,
                            onPressed: widget.onContactOffice,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        AppButton(
                          variant: AppButtonVariant.tonal,
                          label: l.retry,
                          onPressed: seconds > 0
                              ? null
                              : () => unawaited(cubit.load()),
                        ),
                      ] else ...[
                        AppTextField(
                          label: l.accessName,
                          fieldKey: const Key('access.name'),
                          controller: _name,
                          enabled: !state.busy,
                          // Code points, an emoji as one (DEC-429).
                          inputFormatters: const [
                            CodePointLimit(AccessRequest.nameMaxLength),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l.accessRole.toUpperCase(),
                          style: AppTypography.fieldLabel,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<int>(
                          isDense: false,
                          key: ValueKey((
                            _role,
                            state.roles.map((r) => r.id).join(','),
                          )),
                          initialValue: state.roles.any((r) => r.id == _role)
                              ? _role
                              : null,
                          isExpanded: true,
                          hint: Text(l.accessRoleHint),
                          items: [
                            for (final role in state.roles)
                              DropdownMenuItem(
                                value: role.id,
                                child: Text(role.name),
                              ),
                          ],
                          onChanged: state.busy
                              ? null
                              : (role) => setState(() => _role = role),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPasswordField(
                          label: l.accessPassword,
                          showLabel: l.accessShowPassword,
                          hideLabel: l.accessHidePassword,
                          fieldKey: const Key('access.password'),
                          controller: _password,
                          enabled: !state.busy,
                          autofillHints: const [AutofillHints.newPassword],
                          onChanged: (_) => setState(() {}),
                        ),
                        PasswordRules(
                          check: const PasswordPolicy().check(_password.text),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: l.accessEmail,
                          fieldKey: const Key('access.email'),
                          controller: _email,
                          enabled: !state.busy,
                          hint: l.emailHint,
                          prefixIcon: LucideIcons.mail,
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            cubit.emailEdited();
                            _code.clear();
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Each request waits out its own 429 (guide 1:
                        // codes and requests are counted apart).
                        RetryCountdown(
                          until: state.codeRetryAt,
                          builder: (_, wait) => AppButton(
                            label: state.stage == AccessStage.code
                                ? l.accessResend
                                : l.accessSendCode,
                            key: const Key('access.sendCode'),
                            loading: state.busy && !_submitting,
                            onPressed: !_valid || state.busy || wait > 0
                                ? null
                                : () {
                                    _submitting = false;
                                    unawaited(cubit.sendCode(_email.text));
                                  },
                          ),
                        ),
                        if (state.stage == AccessStage.code) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(l.accessCodeSent, style: AppTypography.body),
                          const SizedBox(height: AppSpacing.sm),
                          AppOtpField(
                            key: ValueKey(state.codeVersion),
                            label: l.accessCode,
                            fieldKey: const Key('access.code'),
                            controller: _code,
                            enabled: !state.busy,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          RetryCountdown(
                            until: state.submitRetryAt,
                            builder: (_, wait) => AppButton(
                              label: l.accessSubmit,
                              key: const Key('access.submit'),
                              loading: state.busy && _submitting,
                              onPressed:
                                  !_valid ||
                                      _code.text.length != 6 ||
                                      state.busy ||
                                      wait > 0
                                  ? null
                                  : () {
                                      _submitting = true;
                                      unawaited(
                                        cubit.submit(
                                          AccessRequest(
                                            email: _email.text.trim(),
                                            code: _code.text,
                                            name: _name.text,
                                            roleId: _role!,
                                            password: _password.text,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
