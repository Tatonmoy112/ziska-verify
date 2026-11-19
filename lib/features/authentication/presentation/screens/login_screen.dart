import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/authentication/domain/services/email_check.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_logo.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Login (Figma "Login"). The router moves on by itself once the session
/// changes (final.md Section 9.4). The copyright and the app version sit at
/// the bottom of the page (final.md Section 13.10).
class LoginScreen extends StatefulWidget {
  const LoginScreen({this.versionInfo, super.key});

  /// The installed app's version for the footer; none, no version line.
  final Future<({String version, String build})>? versionInfo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Asked once: a rebuild never starts the footer's version again.
  late final Future<({String version, String build})>? _versionInfo =
      widget.versionInfo;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _emailValid => looksLikeEmail(_email.text);

  void _submit() {
    setState(() => _showErrors = true);
    if (!_emailValid || _password.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(
      LoginSubmitted(email: _email.text, password: _password.text),
    );
  }

  String _errorText(AppLocalizations l10n, SubmitState state) {
    final failure = state.failure!;
    return switch (failure.exception) {
      // One message for every failed login, on purpose (Section 6.2).
      UnauthenticatedException() => l10n.loginFailed,
      _ => failure.message(l10n),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LoginBloc, SubmitState>(
          builder: (context, state) {
            return AutofillGroup(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.xl,
                      AppSpacing.screen,
                      0,
                    ),
                    sliver: SliverList.list(
                      children: [
                        const Center(child: AppLogo()),
                        const SizedBox(height: AppSpacing.xs),
                        Center(
                          child: Text(
                            l10n.brandTagline,
                            style: AppTypography.caption.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(l10n.loginTitle, style: AppTypography.headline),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.loginSubtitle, style: AppTypography.subtitle),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          fieldKey: const Key('login.email'),
                          label: l10n.emailLabel,
                          hint: l10n.emailHint,
                          controller: _email,
                          prefixIcon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                            AutofillHints.username,
                          ],
                          errorText: _showErrors && !_emailValid
                              ? l10n.emailInvalid
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPasswordField(
                          fieldKey: const Key('login.password'),
                          label: l10n.passwordLabel,
                          showLabel: l10n.showPassword,
                          hideLabel: l10n.hidePassword,
                          controller: _password,
                          textInputAction: TextInputAction.done,
                          errorText: _showErrors && _password.text.isEmpty
                              ? l10n.fieldRequired
                              : null,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                        ),
                        if (state.status == SubmitStatus.failure) ...[
                          const SizedBox(height: AppSpacing.xs),
                          FailureBanner(
                            failure: state.failure!,
                            retryAt: state.retryAt,
                            message: _errorText(l10n, state),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        // Disabled while a 429 countdown runs (guide §1).
                        RetryCountdown(
                          until: state.retryAt,
                          builder: (context, seconds) => AppButton(
                            key: const Key('login.submit'),
                            label: l10n.loginButton,
                            loading: state.isSubmitting,
                            onPressed: seconds > 0 ? null : _submit,
                          ),
                        ),
                        Align(
                          child: TextButton(
                            onPressed: () =>
                                context.pushNamed(RouteNames.forgotPassword),
                            child: Text(
                              l10n.forgotPassword,
                              style: AppTypography.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _Divider(label: l10n.noAccountDivider),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: Text(
                            l10n.noAccountQuestion,
                            style: AppTypography.caption,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.requestAccessButton,
                          variant: AppButtonVariant.outlined,
                          onPressed: () =>
                              context.pushNamed(RouteNames.requestAccess),
                        ),
                      ],
                    ),
                  ),
                  // On a tall phone the footer rests at the bottom edge; on a
                  // short one, at a large font or with the keyboard open, it
                  // follows the form and scrolls with it.
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.xxl,
                        AppSpacing.screen,
                        AppSpacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _LoginFooter(versionInfo: _versionInfo),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // The label is as wide as its text, at most 60 % of the row (it wraps
    // at a large font instead of pushing the lines off screen); the two
    // lines share the rest equally.
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.fieldLabel.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}

/// The bottom of Login: who may use the app, then the copyright and the
/// installed version, read out as one item.
class _LoginFooter extends StatelessWidget {
  const _LoginFooter({this.versionInfo});

  final Future<({String version, String build})>? versionInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = AppTypography.caption.copyWith(color: AppColors.textMuted);
    return Column(
      key: const Key('login.footer'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.lock, size: 14, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: Text(l10n.authorizedOnly, style: muted)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: AppSpacing.md),
        FutureBuilder(
          future: versionInfo,
          builder: (context, snapshot) {
            final info = snapshot.data;
            final copyright = l10n.copyrightNotice('${clock.now().year}');
            final version = info == null
                ? null
                : l10n.appVersionShort(info.version, info.build);
            return Semantics(
              // The copyright ends with its own full stop.
              label: [copyright, ?version].join(' '),
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    copyright,
                    key: const Key('login.copyright'),
                    textAlign: TextAlign.center,
                    style: muted,
                  ),
                  if (version != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      version,
                      key: const Key('login.version'),
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
