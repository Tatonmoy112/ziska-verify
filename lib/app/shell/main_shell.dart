import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// One bottom-navigation tab (final.md Section 9.3.1).
class ShellTab {
  const ShellTab({
    required this.branch,
    required this.icon,
    required this.label,
    this.isAllowed,
  });

  /// The `StatefulShellRoute` branch index.
  final int branch;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;

  /// `null` means always shown.
  final bool Function(Set<String> permissions)? isAllowed;
}

bool _canSeeHistory(Set<String> p) =>
    p.contains('history:own') || p.contains('history:all');

/// The three tabs, in order (final.md Section 9.3.1).
final List<ShellTab> shellTabs = [
  ShellTab(branch: 0, icon: LucideIcons.shieldCheck, label: (l) => l.tabVerify),
  ShellTab(
    branch: 1,
    icon: LucideIcons.clock,
    label: (l) => l.tabHistory,
    isAllowed: _canSeeHistory,
  ),
  ShellTab(branch: 2, icon: LucideIcons.user, label: (l) => l.tabProfile),
];

/// The permission each tab path needs, for the router guard.
final Map<String, bool Function(Set<String>)> tabPermissionByPath = {
  '/history': _canSeeHistory,
  '/home/scan': _canLookup,
  '/home/result': _canLookup,
  '/home/bulk-lookup': (p) => p.contains('item:bulk_lookup'),
  '/home/reports': _canReport,
  '/home/reports/new': _canReport,
  '/home/retail-users': _canAddRetail,
  '/home/retail-users/new': _canAddRetail,
};

bool _canAddRetail(Set<String> p) => p.contains('retail_user:add');

bool _canReport(Set<String> p) => p.contains('incident:report');

bool _canLookup(Set<String> p) => p.contains('item:lookup');

/// The bottom navigation bar around the four tabs. Tabs the role cannot use
/// are not shown (final.md Section 9.3.1).
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permissions = context.select<ProfileCubit, Set<String>>(
      (c) => c.state.permissions,
    );
    final visible = [
      for (final tab in shellTabs)
        if (tab.isAllowed?.call(permissions) ?? true) tab,
    ];
    final selected = visible.indexWhere(
      (t) => t.branch == navigationShell.currentIndex,
    );

    return PopScope(
      // Back on another tab's first screen returns to Verify.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.background,
            indicatorColor: Colors.transparent,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => AppTypography.caption.copyWith(
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selected < 0 ? 0 : selected,
            onDestinationSelected: (i) {
              final branch = visible[i].branch;
              // Tapping the current tab returns it to its first screen.
              navigationShell.goBranch(
                branch,
                initialLocation: branch == navigationShell.currentIndex,
              );
            },
            destinations: [
              for (final tab in visible)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label(l10n),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
