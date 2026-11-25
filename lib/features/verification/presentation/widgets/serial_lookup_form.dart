import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/lookup_messages.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/serial_input_formatter.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/tools_section.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/button_pair.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

class SerialLookupForm extends StatelessWidget {
  const SerialLookupForm({
    required this.state,
    required this.way,
    required this.typed,
    required this.camera,
    required this.input,
    required this.inputFocus,
    required this.onChanged,
    required this.onVerify,
    required this.onClear,
    required this.onRetryFormats,
    required this.tools,
    super.key,
    this.header,
  });

  /// Scrolls with the page at a large font.
  final Widget? header;
  final LookupState state;
  final LookupWay way;

  /// The last lookup was a typed serial: its messages show here.
  final bool typed;
  final Widget camera;
  final TextEditingController input;
  final FocusNode inputFocus;
  final VoidCallback onChanged;
  final VoidCallback onVerify;
  final VoidCallback onClear;

  /// Asks for the formats again after they failed.
  final VoidCallback onRetryFormats;
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formats = state.formats;

    final failure = state.failure;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ?header,
        camera,
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (formats == null)
                _FormsUnavailable(
                  failure: state.formatsFailure,
                  retryAt: state.formatsRetryAt,
                  onRetry: onRetryFormats,
                )
              else
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.card,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          fieldKey: const Key('verify.input'),
                          label: l10n.typeSerialLabel,
                          hint: l10n.serialHint(formats.serialMaxDigits),
                          controller: input,
                          focusNode: inputFocus,
                          prefixIcon: LucideIcons.hash,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                            const SerialInputFormatter(),
                          ],
                          textInputAction: TextInputAction.search,
                          errorText:
                              typed && state.status == LookupStatus.refused
                              ? refusedMessage(l10n, state.refused!, formats)
                              : null,
                          onChanged: (_) => onChanged(),
                          onSubmitted: (_) => onVerify(),
                        ),
                        if (typed &&
                            state.status == LookupStatus.failed &&
                            failure != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          // A `429` counts down and goes away at 0.
                          FailureBanner(
                            failure: failure,
                            retryAt: state.retryAt,
                            message: lookupFailureMessage(l10n, failure),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        ButtonPair(
                          firstFlex: 3,
                          secondFlex: 2,
                          // Held while a 429 counts down (guide section 1).
                          first: RetryCountdown(
                            until: state.retryAt,
                            builder: (context, seconds) => AppButton(
                              key: const Key('verify.submit'),
                              label: l10n.verifyButtonLookup,
                              loading: typed && state.isBusy,
                              onPressed:
                                  input.text.isEmpty ||
                                      seconds > 0 ||
                                      state.isBusy
                                  ? null
                                  : onVerify,
                            ),
                          ),
                          second: AppButton(
                            label: l10n.clear,
                            variant: AppButtonVariant.outlined,
                            onPressed: state.isBusy ? null : onClear,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (tools.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                ToolsSection(tools: tools),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Without the formats only the serial form waits: the tools need no
/// formats, so they stay (final.md §13.7). A spinner while they load; what
/// went wrong and Try again when they failed.
class _FormsUnavailable extends StatelessWidget {
  const _FormsUnavailable({
    required this.failure,
    required this.retryAt,
    required this.onRetry,
  });

  final Failure? failure;
  final DateTime? retryAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatsFailure = failure;
    if (formatsFailure == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(key: Key('verify.formatsLoading')),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ErrorBanner(
          message:
              '${l10n.formatsFailed} '
              '${formatsFailure.message(l10n)}',
          requestId: formatsFailure.requestId,
        ),
        const SizedBox(height: AppSpacing.md),
        RetryCountdown(
          until: retryAt,
          builder: (context, wait) => AppButton(
            key: const Key('verify.formatsRetry'),
            label: wait > 0 ? l10n.errorRateLimited(wait) : l10n.retry,
            onPressed: wait > 0 ? null : onRetry,
          ),
        ),
      ],
    );
  }
}
