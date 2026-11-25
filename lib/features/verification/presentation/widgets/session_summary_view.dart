import 'package:flutter/material.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_scan_row.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// After Finish: every scan of the session together, with the totals.
class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    required this.state,
    required this.onOpen,
    required this.onMore,
    super.key,
  });

  final ScanSessionState state;
  final ValueChanged<ScanAnswer> onOpen;

  /// The next page of a resumed session's scans (UI audit 2026-11-22, 5.3).
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totals = state.totals;
    final count = totals?.scanned ?? state.rows.length;
    return ListView(
      key: const Key('session.summary'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l.sessionSummaryTitle,
                  style: AppTypography.heading,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l.sessionSummaryCount(count),
                key: const Key('session.summary.count'),
                style: AppTypography.body,
              ),
              if (totals != null) ...[
                const SizedBox(height: AppSpacing.md),
                SessionCounters(totals: totals),
              ],
              if (state.notChecked > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.sessionNotChecked(state.notChecked),
                  key: const Key('session.summary.notChecked'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
        for (final row in state.rows)
          SessionScanRow(
            key: ValueKey('summary.${row.ref}'),
            row: row,
            onTap: switch (state.answers[row.ref]) {
              final answer? => () => onOpen(answer),
              null => null,
            },
          ),
        // A resumed session's scans come a page at a time: say how many
        // show, and load the rest (final.md §13.2: every product).
        if (state.nextCursor != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                Text(
                  l.sessionSummaryShowing(state.rows.length, count),
                  key: const Key('session.summary.showing'),
                  style: AppTypography.body,
                ),
                RetryCountdown(
                  until: state.rowsRetryAt,
                  builder: (_, wait) => TextButton(
                    key: const Key('session.summary.more'),
                    onPressed: state.loadingMore || wait > 0 ? null : onMore,
                    child: Text(
                      wait > 0 ? l.errorRateLimited(wait) : l.sessionsMore,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
