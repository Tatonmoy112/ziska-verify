import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_search_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';

/// Picks one of the official's own checks for a report (SRS UC-08: the
/// official "optionally picks one of own checks"; app API guide §5 and
/// §6.1 `check_ref`). Returns the check's reference number, or `null`.
Future<String?> showCheckPicker(
  BuildContext context, {
  required GetChecks getChecks,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => BlocProvider(
    create: (_) =>
        HistoryBloc(getChecks)..add(const HistoryQueryChanged(CheckQuery())),
    child: const _CheckPickerSheet(),
  ),
);

class _CheckPickerSheet extends StatelessWidget {
  const _CheckPickerSheet();

  static final _placeholder = CheckRecord(
    ref: 'MA-2026-000000',
    at: DateTime.utc(2026),
    way: CheckWay.qr,
    result: CheckResult.valid,
    reasons: const [],
    official: '',
    serial: '1000000',
    product: 'Product name',
    batch: 'B-0000',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<HistoryBloc>();
    // The sheet stays above the keyboard while searching.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(l10n.pickCheck, style: AppTypography.headline),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppSearchField(
                fieldKey: const Key('checkPicker.search'),
                hint: l10n.historySearchHint,
                onChanged: (t) => bloc.add(HistorySearchTyped(t)),
              ),
            ),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) => AppPaginatedList<CheckRecord>(
                  state: state.list,
                  placeholderItem: _placeholder,
                  itemBuilder: (context, check) => InkWell(
                    onTap: () => Navigator.of(context).pop(check.ref),
                    child: CheckTile(check: check),
                  ),
                  onNextPage: () => bloc.add(const HistoryNextPageRequested()),
                  onRetry: () => bloc.add(const HistoryRetried()),
                  onRefresh: () async {
                    // A 429 wait: nothing is asked for, so nothing to wait for.
                    if (bloc.state.list.isWaiting) return;
                    bloc.add(const HistoryRefreshed());
                    await bloc.stream.firstWhere((s) => !s.list.isLoading);
                  },
                  emptyTitle: l10n.historyEmptyTitle,
                  emptyBody: l10n.historyNoChecksYet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
