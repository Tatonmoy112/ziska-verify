import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';

/// One session at the top of its checks (`GET lookups/sessions/{id}`, app
/// API guide §4.5, SRS FR-SCN-16): the kind, the status, the first and last
/// scan, and the backend's totals. A failure says so with Try again; the
/// checks below it still show.
class SessionSummaryCard extends StatefulWidget {
  const SessionSummaryCard({required this.load, super.key});

  final Future<Result<ScanSessionSummary>> Function() load;

  @override
  State<SessionSummaryCard> createState() => _SessionSummaryCardState();
}

class _SessionSummaryCardState extends State<SessionSummaryCard> {
  late Future<Result<ScanSessionSummary>> _session = widget.load();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DecoratedBox(
      key: const Key('session.summary'),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FutureBuilder(
          future: _session,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            switch (result) {
              case Err(:final failure):
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBanner(
                      message: failure.message(l),
                      requestId: failure.requestId,
                    ),
                    TextButton(
                      key: const Key('session.summary.retry'),
                      onPressed: () => setState(() => _session = widget.load()),
                      child: Text(l.retry),
                    ),
                  ],
                );
              case Success(value: final session):
                final (icon, kind) = switch (session.kind) {
                  SessionKind.serial => (
                    LucideIcons.listOrdered,
                    l.serialStackTitle,
                  ),
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
                        Expanded(
                          child: Text(kind, style: AppTypography.bodyStrong),
                        ),
                        if (status != null)
                          Text(status, style: AppTypography.caption),
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
          },
        ),
      ),
    );
  }
}
