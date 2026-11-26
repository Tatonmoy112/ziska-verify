import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// Shows the check loader over the whole app (above the bottom bar)
/// when a lookup is still running after [delay], and takes it away when
/// the lookup ends (final.md §13.1, decision 48). A faster answer
/// never shows it; nothing is delayed to show it.
class VerifyingLoader {
  VerifyingLoader({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;
  OverlayEntry? _entry;

  /// A lookup started.
  void start(BuildContext context) {
    stop();
    final overlay = Overlay.of(context, rootOverlay: true);
    _timer = Timer(delay, () {
      _entry = OverlayEntry(builder: (_) => const VerifyingView());
      overlay.insert(_entry!);
    });
  }

  /// The lookup ended (a result, a failure, a refusal), or the screen left.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _entry
      ?..remove()
      ..dispose();
    _entry = null;
  }
}

/// The check loader (final.md §13.1): a shield in a
/// progress ring, "Checking the item…", and three steps. **Code format** is
/// ticked: the input was checked on the phone against `GET formats` before
/// it was sent. **Item record** and **Check count** wait for the answer.
class VerifyingView extends StatelessWidget {
  const VerifyingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Covers the screen and hides what is under it from TalkBack.
    return BlockSemantics(
      child: Material(
        color: AppColors.surfaceMuted,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: SizedBox.square(
                      dimension: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.square(
                            dimension: 96,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.primary,
                              // A faint ring under the moving arc, so the
                              // ring always shows.
                              backgroundColor: AppColors.border,
                            ),
                          ),
                          // A filled shield, as in the Figma loader.
                          FilledShield(
                            key: Key('verifying.shield'),
                            size: 44,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.verifyingTitle,
                      style: AppTypography.headline,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.verifyingBody,
                    style: AppTypography.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Step(label: l10n.stepCodeFormat, done: true),
                  _Step(label: l10n.stepItemRecord, done: false),
                  _Step(label: l10n.stepCheckCount, done: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        label: '$label, ${done ? l10n.stepDone : l10n.stepWaiting}',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.input,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Done: a filled green circle with a white tick; waiting: a
                // navy dot in a pale circle (the Figma loader).
                SizedBox.square(
                  key: Key(
                    done ? 'verifying.step.done' : 'verifying.step.waiting',
                  ),
                  dimension: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: done ? AppColors.success : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(
                            LucideIcons.check,
                            size: 14,
                            color: AppColors.onPrimary,
                          )
                        : Center(
                            child: SizedBox.square(
                              dimension: AppSpacing.xs,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.55,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: done
                        ? AppTypography.bodyStrong
                        : AppTypography.body.copyWith(
                            color: AppColors.textMuted,
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

/// A navy shield filled solid with a white tick (the Figma loader). Lucide
/// draws outlines only, so the shield's outline is painted filled and
/// Lucide's tick goes on top (icons stay Lucide's, TC-UI-025).
class FilledShield extends StatelessWidget {
  const FilledShield({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ShieldPainter(),
        child: Padding(
          // The tick sits a little above the middle, in the shield's body.
          padding: EdgeInsets.only(bottom: size * 0.08),
          child: Icon(
            LucideIcons.check,
            size: size * 0.5,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Lucide's shield outline on its 24 × 24 grid, closed and filled.
    final scale = size.width / 24;
    final path = Path()
      ..moveTo(12, 2)
      ..cubicTo(14.4, 3.9, 17, 5, 20, 5)
      ..lineTo(20, 13)
      ..cubicTo(20, 18, 16.5, 20.5, 12, 22)
      ..cubicTo(7.5, 20.5, 4, 18, 4, 13)
      ..lineTo(4, 5)
      ..cubicTo(7, 5, 9.6, 3.9, 12, 2)
      ..close();
    canvas
      ..scale(scale)
      ..drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => false;
}
