import 'package:flutter/material.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';

/// Finish while scanning; Scan more and Done on the summary.
class SessionBottomBar extends StatelessWidget {
  const SessionBottomBar({
    required this.state,
    required this.onFinish,
    required this.onScanMore,
    required this.onDone,
    super.key,
  });

  final ScanSessionState state;
  final VoidCallback onFinish;
  final VoidCallback onScanMore;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (state.phase) {
      case SessionPhase.starting ||
          SessionPhase.startFailed ||
          SessionPhase.closed:
        return const SizedBox.shrink();
      case SessionPhase.scanning || SessionPhase.finishing || SessionPhase.done:
        break;
    }
    final Widget child;
    if (state.done) {
      final scanMore = AppButton(
        key: const Key('session.scanMore'),
        variant: AppButtonVariant.outlined,
        label: l.sessionScanMore,
        onPressed: onScanMore,
      );
      final done = AppButton(
        key: const Key('session.done'),
        label: l.sessionDone,
        onPressed: onDone,
      );
      // Side by side; stacked at a large font, so no label is cut.
      child = isLargeText(context)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                done,
                const SizedBox(height: AppSpacing.xs),
                scanMore,
              ],
            )
          : Row(
              children: [
                Expanded(child: scanMore),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: done),
              ],
            );
    } else {
      child = AppButton(
        key: const Key('session.finish'),
        label: state.finishing ? l.sessionFinishing : l.sessionFinish,
        loading: state.finishing,
        // Once a scan has been answered: an empty summary says nothing.
        onPressed: state.finishing || state.rows.isEmpty ? null : onFinish,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.sm,
          ),
          child: child,
        ),
      ),
    );
  }
}
