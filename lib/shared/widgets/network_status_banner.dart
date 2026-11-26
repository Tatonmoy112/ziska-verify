import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// Puts the offline banner above every screen, login screens included
/// (final.md §14.2).
///
/// - It follows [ConnectivityService] only; a request that fails still says
///   so itself, and nothing is sent again when the link is back.
/// - It never covers the screen: it takes its own height, and the screen
///   below loses the status-bar padding the banner now holds.
/// - Shown after a second offline, gone at once online, so a flapping
///   link does not flicker.
/// - The tree is the same online and offline, so the screens below keep
///   their state.
class NetworkStatusShell extends StatefulWidget {
  const NetworkStatusShell({
    required this.connectivity,
    required this.child,
    super.key,
  });

  final ConnectivityService connectivity;
  final Widget child;

  @override
  State<NetworkStatusShell> createState() => _NetworkStatusShellState();
}

class _NetworkStatusShellState extends State<NetworkStatusShell> {
  static const _settle = Duration(seconds: 1);

  StreamSubscription<bool>? _changes;
  Timer? _settling;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _changes = widget.connectivity.online.listen(_onChange);
    unawaited(widget.connectivity.isOnline().then(_onChange));
  }

  void _onChange(bool online) {
    _settling?.cancel();
    if (online) {
      if (mounted && _offline) setState(() => _offline = false);
      return;
    }
    _settling = Timer(_settle, () {
      if (mounted && !_offline) setState(() => _offline = true);
    });
  }

  @override
  void dispose() {
    _settling?.cancel();
    unawaited(_changes?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OfflineBanner(visible: _offline),
        Expanded(
          // Its own semantics container: a page route blocks the semantics
          // of what was painted before it, and that must not include the
          // banner (TalkBack reads it, TC-ERR-044).
          child: Semantics(
            container: true,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: _offline,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final text = AppLocalizations.of(context).offlineBanner;
    return Material(
      key: const Key('network.offline'),
      color: AppColors.warningBackground,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          label: text,
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.wifiOff,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
