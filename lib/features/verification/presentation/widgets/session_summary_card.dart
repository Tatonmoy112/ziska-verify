import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/session_summary_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// One session at the top of its checks (`GET lookups/sessions/{id}`, app
/// API guide §4.5, SRS FR-SCN-16): the kind, the status, the first and last
/// scan, and the backend's totals. A failure says so with Try again, which
/// counts a `429`'s wait down (production audit P-39); the checks below it
/// still show. Its [SessionSummaryCubit] comes from the route.
class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('session.summary'),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: BlocBuilder<SessionSummaryCubit, SessionSummaryState>(
          builder: (context, state) {
            final session = state.session;
            final failure = state.failure;
            if (state.status == SessionSummaryStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (session != null) return _Summary(session: session);
            if (failure == null) return const SizedBox.shrink();
            final l = AppLocalizations.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErrorBanner(
                  message: failure.message(l),
                  requestId: failure.requestId,
                ),
                RetryCountdown(
                  until: state.retryAt,
                  builder: (_, wait) => TextButton(
                    key: const Key('session.summary.retry'),
                    onPressed: wait > 0
                        ? null
                        : () => unawaited(
                            context.read<SessionSummaryCubit>().load(),
                          ),
                    child: Text(wait > 0 ? l.errorRateLimited(wait) : l.retry),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.session});

  final ScanSessionSummary session;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (icon, kind) = switch (session.kind) {
      SessionKind.serial => (LucideIcons.listOrdered, l.serialStackTitle),
      SessionKind.qr => (LucideIcons.layers, l.scannerModeTitle),
      SessionKind.unknown => (LucideIcons.layers, l.sessionsTitle),
    };
    final status = switch (session.status) {
      ScanStatus.open => l.sessionsOpen,
      ScanStatus.ended => l.sessionsEnded,
      ScanStatus.unknown => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(kind, style: AppTypography.bodyStrong)),
            if (status != null) Text(status, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${l.sessionsStarted}: '
          '${DisplayTime.dateTime(session.startedAt, locale)}',
          style: AppTypography.caption,
        ),
        Text(
          '${l.sessionsLastScan}: '
          '${DisplayTime.dateTime(session.lastScanAt, locale)}',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.sm),
        SessionCounters(totals: session.totals),
      ],
    );
  }
}
