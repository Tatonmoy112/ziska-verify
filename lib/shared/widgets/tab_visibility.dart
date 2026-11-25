import 'package:flutter/widgets.dart';

/// Tells a tab's state when it comes into view and goes out of it: the
/// shell and the navigator turn a tab's tickers off when it is hidden or
/// covered (production audit P-40: written once, for History, Profile and
/// the check tab).
mixin TabVisibility<T extends StatefulWidget> on State<T> {
  bool? _tabShown;

  /// The tab came into view; [firstTime] when it never was before.
  void onTabShown({required bool firstTime}) {}

  /// The tab went out of view, or is out of view from the start.
  void onTabHidden() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.valuesOf(context).enabled;
    final before = _tabShown;
    _tabShown = shown;
    if (shown == before) return;
    shown ? onTabShown(firstTime: before == null) : onTabHidden();
  }
}
