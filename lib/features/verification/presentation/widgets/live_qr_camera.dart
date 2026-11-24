import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_frame.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// The camera at the top of the Check tab (final.md §13.1, §13.7):
/// a read QR is the trigger, sent at once with no button.
///
/// It only draws; the tab starts and stops [session] and sends the codes.
/// The camera dimmed in navy around a green-cornered window, the title and
/// hint above it, the status below it, and the torch.
class LiveQrCamera extends StatefulWidget {
  const LiveQrCamera({
    required this.session,
    required this.height,
    required this.onCode,
    required this.onOpenSettings,
    required this.busy,
    required this.onScanAgain,
    this.message,
    this.requestId,
    this.retryAt,
    this.failed = false,
    super.key,
  });

  final ScannerSession session;
  final double height;
  final void Function(String raw) onCode;
  final Future<bool> Function() onOpenSettings;

  /// A scan is being checked, or the formats are still loading.
  final bool busy;

  /// What went wrong with the last scan (refused, failed), or why scanning
  /// cannot start yet; `null` while all is well.
  final String? message;
  final String? requestId;

  /// After a `429`: the seconds count down on the status and Scan again.
  final DateTime? retryAt;

  /// The last scan failed: the camera waits for [onScanAgain], so nothing
  /// is sent again and again by itself (guide section 4.6).
  final bool failed;
  final VoidCallback onScanAgain;

  @override
  State<LiveQrCamera> createState() => _LiveQrCameraState();
}

class _LiveQrCameraState extends State<LiveQrCamera> {
  /// Once the camera has failed, the frame and the hint are hidden, so they
  /// never cover the message.
  ScannerProblem? _problem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final scaler = MediaQuery.textScalerOf(context);
    final titleStyle = AppTypography.bodyStrong.copyWith(
      color: AppColors.onPrimary,
    );
    final hintStyle = AppTypography.fieldLabel.copyWith(
      color: AppColors.onPrimary.withValues(alpha: 0.85),
      letterSpacing: 1,
    );
    final hint = l10n.scanFrameHint.toUpperCase();

    // Measured at the phone's text size, so nothing overlaps or is cut at
    // a large font: the title row, the hint, then the frame, then the
    // status (and Scan again after a failure).
    double measure(String text, TextStyle style, double maxWidth, int lines) =>
        (TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: lines,
        )..layout(maxWidth: math.max(0, maxWidth))).height;
    final textWidth = width - 2 * AppSpacing.screen;
    final titleHeight = measure(
      l10n.verifyItemTitle,
      titleStyle,
      textWidth - _torchSize,
      1,
    );
    final rowHeight = math.max(titleHeight, _torchSize);
    final hintTop = AppSpacing.xs + rowHeight + AppSpacing.xs;
    final hintHeight = measure(hint, hintStyle, textWidth, 2);
    final frameTop = hintTop + hintHeight + AppSpacing.sm;
    final statusHeight =
        measure(
          l10n.scanLooking,
          AppTypography.link,
          width - 4 * AppSpacing.md - 2 * AppSpacing.xs,
          2,
        ) +
        2 * AppSpacing.xs;
    final below =
        AppSpacing.sm +
        statusHeight +
        AppSpacing.sm +
        (widget.failed ? _buttonHeight + AppSpacing.sm : 0);
    final side = math
        .min(
          math.min(width - 2 * AppSpacing.xxxl, _maxFrame),
          widget.height - frameTop - below,
        )
        .clamp(_minFrame, _maxFrame);
    final height = math.max(widget.height, frameTop + side + below);
    final frame = Rect.fromLTWH((width - side) / 2, frameTop, side, side);

    return SizedBox(
      key: const Key('verify.camera'),
      height: height,
      child: ColoredBox(
        color: AppColors.scannerBackground,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.session.preview(
              onCode: widget.onCode,
              errorBuilder: (context, problem) {
                if (_problem != problem) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _problem = problem);
                  });
                }
                return _CameraProblem(
                  problem: problem,
                  onOpenSettings: widget.onOpenSettings,
                );
              },
            ),
            if (_problem == null) ...[
              IgnorePointer(
                child: CustomPaint(painter: ScanOverlayPainter(window: frame)),
              ),
              PatternBackground(
                color: AppColors.onPrimary.withValues(alpha: 0.05),
                kind: PatternKind.grid,
                spacing: AppSpacing.xxl,
              ),
              Positioned(
                left: AppSpacing.screen,
                right: AppSpacing.screen + _torchSize,
                top: AppSpacing.xs + (rowHeight - titleHeight) / 2,
                child: Text(
                  l10n.verifyItemTitle,
                  key: const Key('verify.cameraTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              Positioned(
                left: AppSpacing.screen,
                right: AppSpacing.screen,
                top: hintTop,
                child: Text(
                  hint,
                  key: const Key('scanner.hint'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: hintStyle,
                ),
              ),
              Positioned.fromRect(
                rect: frame,
                child: ScanFrame(key: const Key('scanner.frame'), size: side),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: _GlassIconButton(
                  key: const Key('scanner.torch'),
                  icon: LucideIcons.zap,
                  tooltip: l10n.torch,
                  onPressed: () => unawaited(widget.session.toggleTorch()),
                ),
              ),
            ],
            if (_problem == null || widget.message != null)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                // Under the frame; an error (taller) grows up from above
                // Scan again instead of off the bottom.
                top: _problem != null
                    ? AppSpacing.md
                    : widget.message == null
                    ? frame.bottom + AppSpacing.sm
                    : null,
                bottom: _problem == null && widget.message != null
                    ? AppSpacing.md +
                          (widget.failed ? _buttonHeight + AppSpacing.sm : 0)
                    : null,
                // A 429 counts down from its Retry-After (guide §1).
                child: RetryCountdown(
                  until: widget.retryAt,
                  builder: (context, seconds) => Center(
                    child: _Status(
                      busy: widget.busy,
                      message: seconds > 0
                          ? l10n.errorRateLimited(seconds)
                          : widget.message,
                      requestId: widget.requestId,
                    ),
                  ),
                ),
              ),
            // Scan again: after a failed scan only.
            if (widget.failed && _problem == null)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: RetryCountdown(
                  until: widget.retryAt,
                  builder: (context, seconds) => AppButton(
                    key: const Key('scanner.scanAgain'),
                    label: l10n.sessionScanAgain,
                    onPressed: seconds > 0 ? null : widget.onScanAgain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _maxFrame = 240.0;
  static const _minFrame = 120.0;
  static const _torchSize = 48.0;

  /// An [AppButton]'s height (Scan again).
  static const _buttonHeight = 52.0;
}

/// The status under the frame: "Looking for a QR code · hold steady" with
/// a green dot, or a spinner while a scan is checked. A refused code or a
/// failed lookup shows the error banner instead, as on every screen.
class _Status extends StatelessWidget {
  const _Status({required this.busy, this.message, this.requestId});

  final bool busy;
  final String? message;
  final String? requestId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (message != null && !busy) {
      return ErrorBanner(message: message!, requestId: requestId);
    }
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        key: const Key('scanner.status'),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.pill),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.scanAccent,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(dimension: AppSpacing.xs),
                ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  busy ? l10n.verifying : l10n.scanLooking,
                  textAlign: TextAlign.center,
                  style: AppTypography.link.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A square see-through button on the camera's navy (the torch).
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary.withValues(alpha: 0.12),
      borderRadius: AppRadius.button,
      child: SizedBox.square(
        dimension: _LiveQrCameraState._torchSize,
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, size: 20),
          color: AppColors.onPrimary,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.problem, required this.onOpenSettings});

  final ScannerProblem problem;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (problem) {
      ScannerProblem.permissionDenied => l10n.scannerPermissionDenied,
      ScannerProblem.unsupported => l10n.scannerUnsupported,
      ScannerProblem.other => l10n.scannerFailed,
    };
    return ColoredBox(
      key: const Key('scanner.problem'),
      color: AppColors.scannerBackground,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.cameraOff,
                color: AppColors.onPrimary,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.onPrimary),
              ),
              if (problem == ScannerProblem.permissionDenied) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  key: const Key('scanner.openSettings'),
                  label: l10n.openSettings,
                  onPressed: () => unawaited(onOpenSettings()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
