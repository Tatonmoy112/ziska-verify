import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

/// A screen whose top is navy and that has no app bar (Profile, the Check
/// tab, the screens with a `GradientHeader`): the status bar's clock and
/// icons are light; and once the page scrolls, a navy strip sits behind
/// them, so the content never runs under the clock (finding F-7).
///
/// Screens with an app bar need nothing: `NavyAppBar` sets light icons,
/// and every other app bar dark ones (the theme).
class NavyStatusBar extends StatefulWidget {
  const NavyStatusBar({required this.child, this.scrim = true, super.key});

  final Widget child;

  /// Whether the navy strip shows once the page scrolls. Off when the navy
  /// header stays fixed at the top and only the content below it scrolls.
  final bool scrim;

  @override
  State<NavyStatusBar> createState() => _NavyStatusBarState();
}

class _NavyStatusBarState extends State<NavyStatusBar> {
  bool _scrolled = false;

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      final scrolled = n.metrics.pixels > 0;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  key: const Key('statusBar.scrim'),
                  opacity: widget.scrim && _scrolled ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const ColoredBox(color: AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
