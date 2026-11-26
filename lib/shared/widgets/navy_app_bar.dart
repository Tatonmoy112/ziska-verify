import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

/// The app bar of the History tab and of the screens opened above the tabs
/// (Result, Scanner mode, Serial stack, Report incident, My reports,
/// Session checks):
/// the navy gradient of the Check and Profile headers, white title and
/// icons, light status bar (final.md §14.1, decision N1). One row, so
/// the content keeps the room; the sign-in screens keep the tall
/// `GradientHeader` with its subtitle.
class NavyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavyAppBar({required this.title, this.actions, super.key});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).appBarTheme.titleTextStyle;
    return AppBar(
      title: Text(title),
      actions: actions,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: titleStyle?.copyWith(color: AppColors.onPrimary),
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.headerGradient),
      ),
    );
  }
}
