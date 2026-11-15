import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/lookup_messages.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_frame.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';

/// The QR scanner (final.md Section 13.1.2). Only the value after `/q/` is
/// sent; the link is never opened. The camera pauses while a lookup runs
/// and while the result is shown.
///
/// The look follows the Figma "scan by barcode": the camera dimmed in navy
/// around a green-cornered scan window, the hint above it, the status
/// below it, and a bottom bar with "Enter manually" and the torch. "Enter
/// manually" pops with `true`; the Verify tab then focuses its field.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    required this.scanner,
    required this.onOpenSettings,
    super.key,
  });

  final ScannerService scanner;
  final Future<bool> Function() onOpenSettings;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerSession _session = widget.scanner.createSession();
  String? _lastRaw;

  /// The camera's problem once it has failed: the frame and the hint are
  /// hidden, so they never cover the message.
  ScannerProblem? _problem;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);
  final _loader = VerifyingLoader();

  @override
  void dispose() {
    _loader.stop();
    unawaited(_session.dispose());
    super.dispose();
  }

  /// The verification loader follows the lookup (Section 13.1.2).
  void _onStatus(LookupState state) {
    switch (state.status) {
      case LookupStatus.inProgress:
        _loader.start(context);
      case LookupStatus.completed:
        unawaited(_showResult(state));
      case _:
        _loader.stop();
    }
  }

  void _onCode(String raw) {
    final bloc = context.read<LookupBloc>();
    if (bloc.state.isBusy || bloc.state.formats == null) return;
    // The same code held in front of the camera is read once.
    final now = clock.now();
    if (raw == _lastRaw && now.difference(_lastAt).inSeconds < 3) return;
    _lastRaw = raw;
    _lastAt = now;
    bloc.add(LookupRequested(LookupWay.qr, raw));
  }

  Future<void> _showResult(LookupState state) async {
    final bloc = context.read<LookupBloc>()..add(const LookupCleared());
    await _session.stop();
    if (!mounted) {
      _loader.stop();
      return;
    }
    final opening = context.pushNamed(
      RouteNames.lookupResult,
      extra: ResultView(
        result: state.result!,
        input: state.checked!,
        origin: ResultOrigin.scanner,
        formats: state.formats,
      ),
    );
    // The result takes the loader's place.
    _loader.stop();
    await opening;
    if (!mounted) return;
    _lastRaw = null;
    if (!bloc.isClosed) await _session.start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scannerBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        leadingWidth: AppSpacing.md + _GlassIconButton.size + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Center(
            child: _GlassIconButton(
              icon: LucideIcons.arrowLeft,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => context.pop(),
            ),
          ),
        ),
        titleTextStyle: Theme.of(
          context,
        ).appBarTheme.titleTextStyle?.copyWith(color: AppColors.onPrimary),
        title: Text(l10n.scanQrTitle),
      ),
      body: BlocConsumer<LookupBloc, LookupState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) => _onStatus(state),
        builder: (context, state) {
          final message = switch (state.status) {
            LookupStatus.refused when state.formats != null => refusedMessage(
              l10n,
              state.refused!,
              state.formats!,
            ),
            LookupStatus.failed => lookupFailureMessage(l10n, state.failure!),
            _ => null,
          };
          final busy = state.isBusy || state.formats == null;
          final insets = MediaQuery.paddingOf(context);
          return LayoutBuilder(
            builder: (context, constraints) {
              final frame = _frameRect(constraints.biggest, insets);
              return Stack(
                fit: StackFit.expand,
                children: [
                  _session.preview(
                    onCode: _onCode,
                    errorBuilder: (context, problem) {
                      if (_problem != problem) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _problem = problem);
                        });
                      }
                      return _ScannerError(
                        problem: problem,
                        onOpenSettings: widget.onOpenSettings,
                      );
                    },
                  ),
                  if (_problem == null) ...[
                    IgnorePointer(
                      child: CustomPaint(
                        painter: ScanOverlayPainter(window: frame),
                      ),
                    ),
                    PatternBackground(
                      color: AppColors.onPrimary.withValues(alpha: 0.05),
                      kind: PatternKind.grid,
                      spacing: AppSpacing.xxl,
                    ),
                    Positioned(
                      left: AppSpacing.screen,
                      right: AppSpacing.screen,
                      bottom: constraints.maxHeight - frame.top + AppSpacing.lg,
                      child: Text(
                        l10n.scanFrameHint.toUpperCase(),
                        key: const Key('scanner.hint'),
                        textAlign: TextAlign.center,
                        style: AppTypography.fieldLabel.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.85),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: frame,
                      child: ScanFrame(
                        key: const Key('scanner.frame'),
                        size: frame.width,
                      ),
                    ),
                  ],
                  if (_problem == null || message != null)
                    Positioned(
                      left: AppSpacing.screen,
                      right: AppSpacing.screen,
                      top: _problem == null
                          ? frame.bottom + AppSpacing.xl
                          : insets.top + kToolbarHeight + AppSpacing.md,
                      child: Center(
                        child: _Status(
                          busy: busy,
                          message: message,
                          requestId: state.status == LookupStatus.failed
                              ? state.failure?.requestId
                              : null,
                        ),
                      ),
                    ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: insets.bottom + AppSpacing.md,
                    child: _BottomBar(
                      onEnterManually: () => context.pop(true),
                      // No camera, no torch.
                      onTorch: _problem == null
                          ? () => unawaited(_session.toggleTorch())
                          : null,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Where the scan window sits: centred across, in the middle of the
  /// space between the app bar and the bottom bar, with room above for the
  /// hint and below for the status. At most 280 square; smaller on a
  /// narrow or short screen (landscape).
  static Rect _frameRect(Size screen, EdgeInsets insets) {
    final top = insets.top + kToolbarHeight;
    final bottom = insets.bottom + AppSpacing.md + _BottomBar.height;
    final free = screen.height - top - bottom;
    final side = math
        .min(
          math.min(screen.width - 2 * AppSpacing.xxxl, _maxFrame),
          free - _roomAroundFrame,
        )
        .clamp(_minFrame, _maxFrame);
    return Rect.fromLTWH(
      (screen.width - side) / 2,
      top + (free - side) / 2,
      side,
      side,
    );
  }

  static const _maxFrame = 280.0;
  static const _minFrame = 140.0;

  /// The hint above the frame and the status below it.
  static const _roomAroundFrame = 160.0;
}

/// The status under the frame: "Looking for a QR code · hold steady" with
/// a green dot, or a spinner while the lookup runs. A refused code or a
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

/// The bar at the bottom: "Enter manually" (back to the Verify tab with the
/// field focused) and the torch (Figma "scan by barcode").
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onEnterManually, required this.onTorch});

  final VoidCallback onEnterManually;

  /// Null when there is no camera: the torch is then not shown.
  final VoidCallback? onTorch;

  static const double height = _GlassIconButton.size + 2 * AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.06),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: AppColors.onPrimary.withValues(alpha: 0.1),
                borderRadius: AppRadius.button,
                child: InkWell(
                  key: const Key('scanner.enterManually'),
                  borderRadius: AppRadius.button,
                  onTap: onEnterManually,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: _GlassIconButton.size,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.textAlignStart,
                            size: 18,
                            color: AppColors.onPrimary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              l10n.enterManually,
                              textAlign: TextAlign.center,
                              style: AppTypography.button.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (onTorch != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _GlassIconButton(
                icon: LucideIcons.zap,
                tooltip: l10n.torch,
                onPressed: onTorch!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A square see-through button on the scanner's navy (back, torch).
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  static const size = 52.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary.withValues(alpha: 0.12),
      borderRadius: AppRadius.button,
      child: SizedBox.square(
        dimension: size,
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon),
          color: AppColors.onPrimary,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.problem, required this.onOpenSettings});

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
      color: AppColors.scannerBackground,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.cameraOff,
              color: AppColors.onPrimary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.onPrimary),
            ),
            if (problem == ScannerProblem.permissionDenied) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.openSettings,
                onPressed: () => unawaited(onOpenSettings()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
