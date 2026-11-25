import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A picker in a bottom sheet: its title, its search, and its list, kept
/// above the keyboard while searching (production audit P-40: the check
/// and retail user pickers' frame, written once).
class PickerSheetFrame extends StatelessWidget {
  const PickerSheetFrame({
    required this.title,
    required this.search,
    required this.list,
    super.key,
  });

  final String title;
  final Widget search;

  /// Fills the room under the search.
  final Widget list;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('picker.frame'),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(title, style: AppTypography.headline),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: search,
            ),
            Expanded(child: list),
          ],
        ),
      ),
    );
  }
}
