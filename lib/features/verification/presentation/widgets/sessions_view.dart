import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/chips/count_chip.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';

/// The official's own sessions, scanner sessions and serial stacks alike,
/// newest first (app API guide §4.5, SRS FR-SCN-16). Shown in the History
/// tab's **Sessions** view; a row opens that session's checks.
class SessionsView extends StatelessWidget {
  const SessionsView({required this.onOpenChecks, super.key});

  final void Function(String id) onOpenChecks;

  /// Shown while the first page loads, as a skeleton.
  static final _placeholder = ScanSessionSummary(
    totals: const SessionTotals(
      id: '',
      scanned: 0,
      valid: 0,
      warning: 0,
      notFound: 0,
      unassigned: 0,
    ),
    kind: SessionKind.qr,
    status: ScanStatus.ended,
    startedAt: DateTime.utc(2026),
    lastScanAt: DateTime.utc(2026),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<SessionsCubit>();
    // The shared list: skeleton, empty and error states, the next page as
    // the end comes into view (final.md §10, §14.2).
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, state) => KeyedSubtree(
        key: const Key('sessions.list'),
        child: AppPaginatedList<ScanSessionSummary>(
          state: state.list,
          placeholderItem: _placeholder,
          itemBuilder: (context, session) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: _SessionCard(
              session: session,
              onTap: () => onOpenChecks(session.totals.id),
            ),
          ),
          onNextPage: () => unawaited(cubit.more()),
          onRetry: () => unawaited(cubit.load(state.query)),
          onRefresh: () async {
            // A 429 wait: nothing is asked for, so nothing to wait for.
            if (!cubit.state.list.isWaiting) await cubit.load();
          },
          emptyTitle: l.sessionsEmpty,
          header: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: _Filters(state: state),
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final SessionsState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<SessionsCubit>();
    final query = state.query;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (status, label) in [
              (null, l.sessionsAll),
              (ScanStatus.open, l.sessionsOpen),
              (ScanStatus.ended, l.sessionsEnded),
            ])
              CountChip(
                key: Key('sessions.status.${status?.name ?? 'all'}'),
                label: label,
                selected: query.status == status,
                onTap: () => unawaited(
                  cubit.load(
                    SessionQuery(
                      status: status,
                      from: query.from,
                      to: query.to,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                query.from == null
                    ? l.sessionsLastSevenDays
                    : '${DisplayTime.date(query.from!, locale)} – '
                          '${DisplayTime.date(query.to!, locale)}',
                key: const Key('sessions.range'),
                style: AppTypography.caption,
              ),
            ),
            if (query.from != null)
              TextButton(
                key: const Key('sessions.clearDates'),
                onPressed: () => unawaited(
                  cubit.load(SessionQuery(status: query.status)),
                ),
                child: Text(l.clear),
              ),
            TextButton.icon(
              key: const Key('sessions.dates'),
              icon: const Icon(LucideIcons.calendar, size: 18),
              label: Text(l.sessionsDates),
              onPressed: () async {
                final now = DisplayTime.inZone(clock.now());
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(now.year, now.month, now.day),
                  initialDateRange: query.from == null
                      ? null
                      : DateTimeRange(start: query.from!, end: query.to!),
                );
                if (range != null) {
                  await cubit.load(
                    SessionQuery(
                      status: query.status,
                      from: range.start,
                      to: range.end,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final ScanSessionSummary session;
  final VoidCallback onTap;

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
    return Material(
      color: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        key: Key('sessions.row.${session.totals.id}'),
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(kind, style: AppTypography.bodyStrong)),
                  if (status != null) _StatusPill(status),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${l.sessionsStarted}: '
                '${DisplayTime.dateTime(session.startedAt, locale)}',
                style: AppTypography.caption,
              ),
              // A stack starts and ends with its one request: one time.
              if (session.kind != SessionKind.serial)
                Text(
                  '${l.sessionsLastScan}: '
                  '${DisplayTime.dateTime(session.lastScanAt, locale)}',
                  style: AppTypography.caption,
                ),
              const SizedBox(height: AppSpacing.sm),
              SessionCounters(totals: session.totals),
            ],
          ),
        ),
      ),
    );
  }
}

/// Open or ended, as a small pill (like the History result badge).
class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
