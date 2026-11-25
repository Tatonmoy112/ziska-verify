import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/camera_problem_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_frame.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The camera of scanner mode: dark, with the overlay, the frame, and its
/// hint, as the single scanner (SRS 7.1 "Scanner mode: the camera …").
/// A camera problem says what to do, styled like the rest of the app.
class ScanCameraArea extends StatelessWidget {
  const ScanCameraArea({
    required this.height,
    required this.preview,
    required this.onOpenSettings,
    super.key,
    this.frameColor,
    this.checking,
    this.live,
  });

  final double height;

  /// The colour of the last result, around the frame.
  final Color? frameColor;

  /// "Checking…" while a scan is being checked or reads wait.
  final String? checking;

  /// The last result, across the bottom of the camera.
  final Widget? live;
  final Widget Function(
    Widget Function(BuildContext, ScannerProblem) onError,
  )
  preview;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      key: const Key('session.camera'),
      height: height,
      child: ColoredBox(
        color: AppColors.textStrong,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Room at the bottom for the live result, so it never covers
            // the frame (and the frame does not move when it appears).
            const strip = 72.0;
            final room = constraints.maxHeight - strip;
            final side = (room * 0.7).clamp(120.0, 260.0);
            final frame = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                room / 2 + AppSpacing.md,
              ),
              width: side,
              height: side,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                preview(
                  (context, problem) => CameraProblemView(
                    problem: problem,
                    layout: CameraProblemLayout.inline,
                    onOpenSettings: onOpenSettings,
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: ScanOverlayPainter(window: frame),
                  ),
                ),
                Positioned(
                  left: AppSpacing.screen,
                  right: AppSpacing.screen,
                  bottom: constraints.maxHeight - frame.top + AppSpacing.sm,
                  child: Text(
                    l.scanFrameHint.toUpperCase(),
                    key: const Key('session.hint'),
                    textAlign: TextAlign.center,
                    style: AppTypography.fieldLabel.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: frame,
                  child: ScanFrame(key: const Key('session.frame'), size: side),
                ),
                if (frameColor != null)
                  Positioned.fromRect(
                    rect: frame.inflate(4),
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        key: const Key('session.frameResult'),
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: frameColor!, width: 3),
                        ),
                      ),
                    ),
                  ),
                if (checking != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Checking(text: checking!),
                  ),
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: live ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The last answer, over the camera: its colour, title, serial and product.
/// Read aloud by screen readers as it changes.
class ScanLiveResult extends StatelessWidget {
  const ScanLiveResult({
    required this.result,
    required this.repeat,
    required this.onTap,
    super.key,
  });

  final LookupResult result;
  final bool repeat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = outcomeStyle(result.outcome, l);
    final item = result.item;
    final detail = [
      if (item != null) ...[item.serial, item.product.name],
    ].join(' · ');
    final title = repeat ? '${style.title} · ${l.sessionRepeat}' : style.title;
    return Semantics(
      liveRegion: true,
      label: [title, if (detail.isNotEmpty) detail].join('. '),
      excludeSemantics: true,
      button: true,
      child: Material(
        key: const Key('session.live'),
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: style.color, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(style.icon, color: style.color, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong.copyWith(
                          color: style.color,
                        ),
                      ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textStrong,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small "Checking…" over the camera while answers are on their way.
class _Checking extends StatelessWidget {
  const _Checking({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const Key('session.checking'),
    decoration: BoxDecoration(
      color: AppColors.textStrong.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.caption.copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    ),
  );
}
