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

/// My reports (final.md Section 13.5.4): the official's own reports, newest
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
      appBar: AppBar(title: Text(l10n.myReportsTitle)),
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
            bloc.add(const MyReportsStarted(keepItems: true));
            await bloc.stream.firstWhere((s) => !s.isLoading);
          },
          emptyTitle: l10n.myReportsEmpty,
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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
        ),
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
                    _Meta(icon: LucideIcons.fileCheck, text: report.checkRef!),
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
    );
  }
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
