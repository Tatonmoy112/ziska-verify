import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/check_usecases.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_tile.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_search_field.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';
import 'package:ziska_verify/shared/widgets/picker_sheet_frame.dart';

/// Picks one of the official's own checks for a report (SRS UC-08: the
/// official "optionally picks one of own checks"; app API guide §5 and
/// §6 `check_ref`). Returns the check's reference number, or `null`.
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
    return PickerSheetFrame(
      title: l10n.pickCheck,
      search: AppSearchField(
        fieldKey: const Key('checkPicker.search'),
        hint: l10n.historySearchHint,
        onChanged: (t) => bloc.add(HistorySearchTyped(t)),
      ),
      list: BlocBuilder<HistoryBloc, HistoryState>(
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
            final done = Completer<void>();
            bloc.add(HistoryRefreshed(done: done));
            await done.future;
          },
          // A search that is not a serial or a reference number is
          // not sent; the list says what to type (finding F-4).
          emptyTitle: state.searchRefused
              ? l10n.historySearchRefusedTitle
              : l10n.historyEmptyTitle,
          emptyBody: state.searchRefused
              ? l10n.historySearchRefusedBody
              : l10n.historyNoChecksYet,
        ),
      ),
    );
  }
}
