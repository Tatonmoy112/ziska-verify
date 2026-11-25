import 'package:flutter/material.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_scan_row.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// A scanner session's rows (production audit P-37): what could not be
/// read again, then each scan, newest first, and more.
class SessionRowsSliver extends StatelessWidget {
  const SessionRowsSliver({
    required this.state,
    required this.onOpen,
    required this.onRetryRows,
    required this.onMore,
    super.key,
  });

  final ScanSessionState state;

  /// Opens a row answered in this run.
  final void Function(ScanAnswer answer) onOpen;
  final VoidCallback onRetryRows;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SliverMainAxisGroup(
      slivers: [
        if (state.rowsFailed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.sessionRowsFailed,
                      style: AppTypography.caption,
                    ),
                  ),
                  RetryCountdown(
                    until: state.rowsRetryAt,
                    builder: (_, wait) => TextButton(
                      key: const Key('session.rowsRetry'),
                      onPressed: state.loadingMore || wait > 0
                          ? null
                          : onRetryRows,
                      child: Text(
                        wait > 0 ? l.errorRateLimited(wait) : l.retry,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverList.builder(
          itemCount: state.rows.length + (state.nextCursor == null ? 0 : 1),
          itemBuilder: (_, i) {
            if (i == state.rows.length) {
              return RetryCountdown(
                until: state.rowsRetryAt,
                builder: (_, wait) => TextButton(
                  onPressed: state.loadingMore || wait > 0 ? null : onMore,
                  child: Text(
                    wait > 0 ? l.errorRateLimited(wait) : l.sessionsMore,
                  ),
                ),
              );
            }
            final row = state.rows[i];
            final answer = state.answers[row.ref];
            return SessionScanRow(
              key: ValueKey(row.ref),
              row: row,
              onTap: answer == null ? null : () => onOpen(answer),
            );
          },
        ),
      ],
    );
  }
}
