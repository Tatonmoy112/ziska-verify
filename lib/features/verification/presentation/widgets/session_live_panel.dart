import 'package:flutter/material.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Scanner mode's live part, under the camera (production audit P-37): what
/// was not checked, the session's counters, the failure and what to do,
/// the notices of the last answer, and that answer's card.
class SessionLivePanel extends StatelessWidget {
  const SessionLivePanel({
    required this.state,
    required this.canReadHistory,
    required this.onOpenLatest,
    required this.onScanAgain,
    super.key,
  });

  final ScanSessionState state;

  /// The official may read their history: a roll-over says where the
  /// first session's products are.
  final bool canReadHistory;
  final VoidCallback onOpenLatest;

  /// Scan again after a failure: the camera starts over.
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Each line is centred across the whole width, as it was among the
    // screen's own lines.
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.notChecked > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                0,
              ),
              child: Text(
                l.sessionNotChecked(state.notChecked),
                key: const Key('session.notChecked'),
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              0,
            ),
            // The backend's totals; zeros before the first scan
            // of a new session. A resumed one without its totals
            // says so until a scan answers (no false zeros).
            child: state.totals == null && state.resumed
                ? Padding(
                    key: const Key('session.resumed'),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      l.sessionResumedCounts,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  )
                : SessionCounters(
                    totals:
                        state.totals ??
                        SessionTotals(
                          id: state.id!,
                          scanned: 0,
                          valid: 0,
                          warning: 0,
                          notFound: 0,
                          unassigned: 0,
                        ),
                  ),
          ),
          if (state.busy) const LinearProgressIndicator(),
          if (state.failure != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: FailureBanner(
                failure: state.failure!,
                retryAt: state.retryAt,
                message:
                    state.failure!.exception.reason ==
                        VerificationReason.scanInput
                    ? l.notProductQr
                    // Nothing is queued: scan the product
                    // again (FR-SCN-15, guide section 4.6).
                    : state.failure!.exception is NetworkException
                    ? l.sessionNoConnection
                    : state.failure!.exception is ServiceUnavailableException
                    ? l.sessionBusy
                    : state.failure!.message(l),
              ),
            ),
          if (state.renewed)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                canReadHistory ? l.sessionRenewedHistory : l.sessionRenewed,
                key: const Key('session.renewed'),
                style: AppTypography.caption,
              ),
            ),
          if (state.restarted)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                l.sessionRestarted,
                key: const Key('session.restarted'),
                style: AppTypography.caption,
              ),
            ),
          if (state.repeat)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  l.sessionRepeat,
                  key: const Key('session.repeat'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
          if (state.latest != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                0,
              ),
              child: InkWell(
                key: const Key('session.latest'),
                onTap: onOpenLatest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VerificationResultCard(result: state.latest!),
                    if (state.latest!.item != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xs,
                        ),
                        child: Text(
                          [
                            state.latest!.item!.serial,
                            state.latest!.item!.product.name,
                          ].join(' · '),
                          key: const Key('session.latest.item'),
                          style: AppTypography.caption,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (state.failure != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: RetryCountdown(
                until: state.retryAt,
                builder: (_, seconds) => AppButton(
                  key: const Key('session.scanAgain'),
                  label: l.sessionScanAgain,
                  onPressed: seconds > 0 || state.busy ? null : onScanAgain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
