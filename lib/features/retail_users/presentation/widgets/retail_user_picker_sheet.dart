import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_search_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/app_paginated_list.dart';

/// Opens the retail user picker (final.md §13.6) and returns the
/// chosen one, or `null`.
Future<({String id, String name})?> showRetailUserPicker(
  BuildContext context, {
  required SearchRetailUsers search,
}) => showModalBottomSheet<({String id, String name})>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => BlocProvider(
    create: (_) => RetailUserPickerBloc(search)..add(const PickerStarted()),
    child: const _PickerSheet(),
  ),
);

class _PickerSheet extends StatelessWidget {
  const _PickerSheet();

  static const _placeholder = RetailUser(
    id: '',
    name: 'Retail user name',
    maskedEmail: 'ab***@example.com',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<RetailUserPickerBloc>();
    // The sheet stays above the keyboard while searching.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(l10n.pickRetailUser, style: AppTypography.headline),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppSearchField(
                fieldKey: const Key('picker.search'),
                hint: l10n.pickRetailUserHint,
                maxLength: SearchRetailUsers.maxSearchLength,
                onChanged: (t) => bloc.add(PickerSearchTyped(t)),
              ),
            ),
            Expanded(
              child: BlocBuilder<RetailUserPickerBloc, RetailUserPickerState>(
                builder: (context, state) => AppPaginatedList<RetailUser>(
                  state: state.list,
                  placeholderItem: _placeholder,
                  itemBuilder: (context, user) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surfaceMuted,
                      child: Icon(LucideIcons.store, color: AppColors.primary),
                    ),
                    title: Text(user.name, style: AppTypography.bodyStrong),
                    subtitle: Text(
                      user.maskedEmail,
                      style: AppTypography.caption,
                    ),
                    onTap: () => Navigator.of(
                      context,
                    ).pop((id: user.id, name: user.name)),
                  ),
                  onNextPage: () => bloc.add(const PickerNextPageRequested()),
                  onRetry: () => bloc.add(const PickerRetried()),
                  onRefresh: () async {
                    if (!bloc.state.list.isWaiting) {
                      bloc.add(const PickerRetried());
                    }
                  },
                  emptyTitle: l10n.pickRetailUserEmpty,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
