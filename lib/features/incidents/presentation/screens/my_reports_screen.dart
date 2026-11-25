import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';

/// My reports (final.md §13.5): the official's own reports, newest
/// first, with their photo counts. Photos cannot be downloaded.
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  static final _placeholder = Report(
    id: 0,
    at: DateTime.utc(2026),
    note: 'A report note that takes two lines in the list.',
    photos: 2,
    checkRef: 'MA-2026-000000',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MyReportsBloc>();
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: NavyAppBar(title: l10n.myReportsTitle),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('reports.new'),
        onPressed: () async {
          await context.pushNamed(RouteNames.reportIncident);
          // A new report appears at the top.
          bloc.add(const MyReportsStarted(keepItems: true));
        },
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.newReport),
      ),
      body: BlocBuilder<MyReportsBloc, PaginatedState<Report>>(
        builder: (context, state) => AppPaginatedList<Report>(
          state: state,
          placeholderItem: _placeholder,
          itemBuilder: (context, report) => _ReportTile(report: report),
          onNextPage: () => bloc.add(const MyReportsNextPageRequested()),
          onRetry: () => bloc.add(const MyReportsRetried()),
          onRefresh: () async {
            if (bloc.state.isWaiting) return;
            final done = Completer<void>();
            bloc.add(MyReportsStarted(keepItems: true, done: done));
            await done.future;
          },
          emptyTitle: l10n.myReportsEmpty,
          emptyBody: l10n.myReportsEmptyBody,
          header: const SizedBox(height: AppSpacing.md),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.xs,
      ),
      // A report opens in full: the list cuts the note at two lines.
      child: Material(
        color: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          // No key on the skeleton's repeated placeholder (id 0).
          key: report.id == 0 ? null : Key('reports.row.${report.id}'),
          borderRadius: AppRadius.card,
          onTap: () => unawaited(_showReport(context, report)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${report.id}', style: AppTypography.bodyStrong),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        DisplayTime.dateTime(report.at, locale),
                        style: AppTypography.caption,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  report.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    _Meta(
                      icon: LucideIcons.image,
                      text: l10n.myReportsPhotos(report.photos),
                    ),
                    if (report.checkRef != null)
                      _Meta(
                        icon: LucideIcons.fileCheck,
                        text: report.checkRef!,
                      ),
                    if (report.retailUserName != null)
                      _Meta(
                        icon: LucideIcons.store,
                        text: report.retailUserName!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One report in full: the whole note, its time, photos, check, and retail
/// user (SRS UC-09). Photos are not downloadable in the app (FR-INC-06).
Future<void> _showReport(BuildContext context, Report report) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => SingleChildScrollView(
      key: const Key('reports.detail'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.screen,
      ),
      // Across the screen whatever the note's length: a column alone takes
      // its widest line's width, so a short note made a narrow sheet (F-6).
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('#${report.id}', style: AppTypography.headline),
            Text(
              DisplayTime.dateTime(report.at, locale),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            SelectableText(report.note, style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _Meta(
                  icon: LucideIcons.image,
                  text: l10n.myReportsPhotos(report.photos),
                ),
                if (report.checkRef != null)
                  _Meta(icon: LucideIcons.fileCheck, text: report.checkRef!),
                if (report.retailUserName != null)
                  _Meta(icon: LucideIcons.store, text: report.retailUserName!),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.textMuted),
      const SizedBox(width: AppSpacing.xxs),
      Flexible(
        child: Text(
          text,
          style: AppTypography.caption,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
