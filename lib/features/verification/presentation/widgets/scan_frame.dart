import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

/// The scan window: green corner brackets and a scan line moving up and
/// down (Figma "scan by barcode"). Decoration only, hidden from screen
/// readers. The line holds still in the middle when the phone's animations
/// are turned off ("Remove animations").
class ScanFrame extends StatefulWidget {
  const ScanFrame({required this.size, super.key});

  final double size;

  /// One pass from top to bottom.
  static const sweep = Duration(milliseconds: 2200);

  @override
  State<ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<ScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: ScanFrame.sweep,
    value: 0.5,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _line
        ..stop()
        ..value = 0.5;
    } else if (!_line.isAnimating) {
      unawaited(_line.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _line,
            builder: (context, _) => CustomPaint(
              painter: ScanFramePainter(line: _line.value),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a [ScanFrame]; [line] is the scan line's place, 0 (top) … 1.
class ScanFramePainter extends CustomPainter {
  ScanFramePainter({required this.line});

  final double line;

  static const radius = 18.0;
  static const _stroke = 4.0;
  static const _cornerLength = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final corner = Paint()
      ..color = AppColors.scanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    const inset = _stroke / 2;
    final r = Rect.fromLTWH(
      inset,
      inset,
      size.width - _stroke,
      size.height - _stroke,
    );
    final len = math.min(_cornerLength, r.width / 3);
    // Each corner: a straight stub, the rounded corner, a straight stub.
    for (final (origin, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + dy * len)
        ..lineTo(origin.dx, origin.dy + dy * radius)
        ..arcToPoint(
          Offset(origin.dx + dx * radius, origin.dy),
          radius: const Radius.circular(radius),
          clockwise: dx * dy > 0,
        )
        ..lineTo(origin.dx + dx * len, origin.dy);
      canvas.drawPath(path, corner);
    }

    // The scan line: brightest in the middle, fading to both ends, with a
    // soft glow.
    final y = r.top + radius + (r.height - 2 * radius) * line;
    final lineRect = Rect.fromLTWH(r.left + 16, y - 1, r.width - 32, 2);
    final clear = AppColors.scanAccent.withValues(alpha: 0);
    final shader = LinearGradient(
      colors: [clear, AppColors.scanAccent, clear],
    ).createShader(lineRect);
    canvas
      ..drawRect(
        lineRect.inflate(4),
        Paint()
          ..shader = shader
          ..color = AppColors.scanAccent.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawRect(lineRect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(ScanFramePainter old) => old.line != line;
}

/// Dims everything around the scan window with the scanner's navy, so the
/// camera image shows clearly only inside the frame.
class ScanOverlayPainter extends CustomPainter {
  ScanOverlayPainter({required this.window});

  /// The scan window, in this painter's coordinates.
  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(
          window,
          const Radius.circular(ScanFramePainter.radius),
        ),
      );
    canvas.drawPath(
      path,
      Paint()..color = AppColors.scannerBackground.withValues(alpha: 0.78),
    );
  }

  @override
  bool shouldRepaint(ScanOverlayPainter old) => old.window != window;
}
