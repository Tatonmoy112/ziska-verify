import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/chips/count_chip.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_search_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';
import 'package:ziska_verify/shared/widgets/label_value_row.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';

/// The History tab (final.md §13.4). A serial search shows the
/// item's tracking log (§13.4).
///
/// With [sessions], a **Checks | Sessions** switch sits under the title and
/// **Sessions** shows that view (the official's own sessions, Section
/// 13.4). Without it (one session's checks), only the checks list shows,
/// under [title].
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    this.sessions,
    this.title,
    this.top,
    this.onSessionsShown,
    super.key,
  });

  /// Called when the tab comes back with the Sessions view open, so the
  /// list is fresh (final.md §13.4).
  final void Function(BuildContext context)? onSessionsShown;

  final Widget? sessions;

  /// Shown above the checks (one session's summary, SRS FR-SCN-16).
  final Widget? top;

  /// The app bar's title; the History tab's name when `null`.
  final String? title;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _HistoryView { checks, sessions }

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryView _view = _HistoryView.checks;

  late final TextEditingController _search = TextEditingController(
    text: context.read<HistoryBloc>().state.query.search,
  );

  bool? _shown;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.valuesOf(context).enabled;
    if (shown && _shown == false) {
      context.read<HistoryBloc>().add(const HistoryRefreshed());
      if (_view == _HistoryView.sessions) widget.onSessionsShown?.call(context);
    }
    _shown = shown;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(CheckQuery query) async {
    final picked = await showModalBottomSheet<CheckQuery>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(query: query),
    );
    if (picked != null && mounted) {
      context.read<HistoryBloc>().add(HistoryQueryChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sessions = widget.sessions;
    final body = sessions != null && _view == _HistoryView.sessions
        ? sessions
        : _checks(l10n);
    final top = widget.top;
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: NavyAppBar(title: widget.title ?? l10n.tabHistory),
      body: sessions == null
          ? top == null
                ? body
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.md,
                          AppSpacing.screen,
                          0,
                        ),
                        child: top,
                      ),
                      Expanded(child: body),
                    ],
                  )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // In the body, not the app bar, so it grows with the font
                // size (TC-NFR-014).
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    0,
                  ),
                  child: SegmentedButton<_HistoryView>(
                    key: const Key('history.view'),
                    segments: [
                      ButtonSegment(
                        value: _HistoryView.checks,
                        label: Text(
                          l10n.historyChecksView,
                          key: const Key('history.view.checks'),
                        ),
                      ),
                      ButtonSegment(
                        value: _HistoryView.sessions,
                        label: Text(
                          l10n.sessionsTitle,
                          key: const Key('history.view.sessions'),
                        ),
                      ),
                    ],
                    selected: {_view},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _view = s.single),
                  ),
                ),
                Expanded(child: body),
              ],
            ),
    );
  }

  Widget _checks(AppLocalizations l10n) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final bloc = context.read<HistoryBloc>();
        final tracking = _trackedSerial(state.query);
        // A tracking log numbers the checks, newest first.
        final places = Map<CheckRecord, int>.identity();
        if (tracking != null) {
          for (final (i, c) in state.list.items.indexed) {
            places[c] = i + 1;
          }
        }
        return AppPaginatedList<CheckRecord>(
          state: state.list,
          placeholderItem: _placeholder,
          itemBuilder: (context, check) => CheckTile(
            check: check,
            number: places[check],
          ),
          onNextPage: () => bloc.add(const HistoryNextPageRequested()),
          onRetry: () => bloc.add(const HistoryRetried()),
          onRefresh: () async {
            // A 429 wait: nothing is asked for, so nothing to wait for.
            if (bloc.state.list.isWaiting) return;
            final done = Completer<void>();
            bloc.add(HistoryRefreshed(done: done));
            await done.future;
          },
          // No check at all yet, or none for these filters (§14.2); or a
          // search that is not a serial or a reference number, not sent (F-4).
          emptyTitle: state.searchRefused
              ? l10n.historySearchRefusedTitle
              : l10n.historyEmptyTitle,
          emptyBody: state.searchRefused
              ? l10n.historySearchRefusedBody
              : state.query.hasFilters ||
                    (state.query.search?.trim().isNotEmpty ?? false)
              ? l10n.historyEmptyBody
              : l10n.historyNoChecksYet,
          header: _Header(
            search: _search,
            state: state,
            tracking: tracking,
            onSearch: (text) => bloc.add(HistorySearchTyped(text)),
            onResult: (result) => bloc.add(HistoryResultPicked(result)),
            onClearSearch: () {
              _search.clear();
              bloc.add(const HistorySearchTyped(''));
            },
            onFilters: () => unawaited(_openFilters(state.query)),
            onClearFilters: () => bloc.add(
              // The chips' result stays: only the sheet's filters go.
              HistoryQueryChanged(
                CheckQuery(
                  search: state.query.search,
                  result: state.query.result,
                  sessionId: state.query.sessionId,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The serial a digits-only search tracks (§13.4); `null` for no
/// search or a reference number.
String? _trackedSerial(CheckQuery query) {
  final searched = query.search?.trim();
  if (searched == null || !RegExp(r'^\d+$').hasMatch(searched)) return null;
  return searched;
}

final _placeholder = CheckRecord(
  ref: 'MA-2026-000000',
  at: DateTime.utc(2026),
  way: CheckWay.qr,
  result: CheckResult.valid,
  reasons: const [],
  official: 'Official name',
  serial: '1000000',
  product: 'Product name',
  batch: 'B-0000',
);

class _Header extends StatelessWidget {
  const _Header({
    required this.search,
    required this.state,
    required this.tracking,
    required this.onSearch,
    required this.onResult,
    required this.onClearSearch,
    required this.onFilters,
    required this.onClearFilters,
  });

  final TextEditingController search;
  final HistoryState state;

  /// The serial whose tracking log is shown, if any.
  final String? tracking;
  final ValueChanged<String> onSearch;
  final ValueChanged<CheckResult?> onResult;
  final VoidCallback onClearSearch;
  final VoidCallback onFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = state.query;
    final counts = state.chipTotals;
    final filtered = query.way != null || query.from != null;
    final chips = [
      (null, l10n.historyAll, counts?.total),
      (CheckResult.valid, l10n.bulkValid, counts?.valid),
      (CheckResult.warning, l10n.bulkWarning, counts?.warning),
      (CheckResult.notFound, l10n.bulkNotFound, counts?.notFound),
      (CheckResult.unassigned, l10n.bulkUnassigned, counts?.unassigned),
    ];
    final first = state.list.items.firstOrNull;
    final tracking = this.tracking;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    fieldKey: const Key('history.search'),
                    controller: search,
                    hint: l10n.historySearchHint,
                    onChanged: onSearch,
                    onClear: onClearSearch,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.filledTonal(
                  key: const Key('history.filters'),
                  tooltip: l10n.historyFilters,
                  onPressed: onFilters,
                  icon: Badge(
                    isLabelVisible: filtered,
                    child: const Icon(LucideIcons.slidersHorizontal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // The result chips scroll sideways, edge to edge (Figma).
          SingleChildScrollView(
            key: const Key('history.chips'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                for (final (i, (value, label, count)) in chips.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  CountChip(
                    key: Key('history.chip.${value?.wire ?? 'all'}'),
                    label: label,
                    count: count,
                    selected: query.result == value,
                    onTap: () => onResult(value),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (filtered)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: Text(l10n.historyReset),
                    ),
                  )
                else
                  const SizedBox(height: AppSpacing.sm),
                if (tracking != null) ...[
                  if (first != null && first.serial == tracking) ...[
                    _ItemCard(
                      check: first,
                      count: counts?.total,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Semantics(
                    header: true,
                    label: l10n.historyTracking(tracking),
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.historyTrackingLog.toUpperCase(),
                              key: const Key('history.trackingLog'),
                              style: AppTypography.sectionTitle,
                            ),
                          ),
                          if (counts != null)
                            Text(
                              l10n
                                  .historyCheckCount(counts.total)
                                  .toUpperCase(),
                              style: AppTypography.fieldLabel,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The item above its tracking log (the Figma "batch details by id"): the
/// fields a check carries, and how many checks it has.
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.check, required this.count});

  final CheckRecord check;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = this.count;
    return DecoratedBox(
      key: const Key('history.itemCard'),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.historyItemTitle.toUpperCase(),
                    style: AppTypography.sectionTitle,
                  ),
                ),
                if (count != null)
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.pill),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Text(
                        l10n.historyCheckCount(count),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (check.product case final product?)
              LabelValueRow(label: l10n.productLabel, value: product),
            if (check.batch case final batch?)
              LabelValueRow(label: l10n.batchLabel, value: batch),
            if (check.serial case final serial?)
              LabelValueRow(label: l10n.waySerial, value: serial),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.query});

  final CheckQuery query;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late CheckQuery _query = widget.query;

  Future<void> _pickDates() async {
    final now = DisplayTime.inZone(clock.now());
    final today = DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: _query.from != null && _query.to != null
          ? DateTimeRange(start: _query.from!, end: _query.to!)
          : null,
    );
    if (range != null) {
      setState(
        () => _query = _query.copyWith(from: range.start, to: range.end),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ways = [
      (null, l10n.historyAny),
      (CheckWay.qr, l10n.wayQr),
      (CheckWay.serial, l10n.waySerial),
      (CheckWay.hiddenCode, l10n.wayHiddenCode),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.screen,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.historyFilters, style: AppTypography.headline),
            // The result is picked with the chips on the screen.
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.historyWay.toUpperCase(),
              style: AppTypography.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.xs),
            // The same chip as the result chips on the screen (one style).
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (value, label) in ways)
                  CountChip(
                    key: Key('history.way.${value?.name ?? 'any'}'),
                    label: label,
                    selected: _query.way == value,
                    onTap: () =>
                        setState(() => _query = _query.copyWith(way: value)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.historyDates.toUpperCase(),
              style: AppTypography.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              variant: AppButtonVariant.outlined,
              onPressed: () => unawaited(_pickDates()),
              icon: LucideIcons.calendar,
              label: _query.from == null
                  ? l10n.historyPickDates
                  : '${DisplayTime.date(_query.from!, locale)} – '
                        '${DisplayTime.date(_query.to!, locale)}',
            ),
            if (_query.from != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(
                    () => _query = _query.copyWith(from: null, to: null),
                  ),
                  child: Text(l10n.historyReset),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.historyApply,
              onPressed: () => Navigator.of(context).pop(_query),
            ),
          ],
        ),
      ),
    );
  }
}
