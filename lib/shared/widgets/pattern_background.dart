import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// What a [PatternBackground] draws.
enum PatternKind {
  /// Small dots on a square grid (the Splash, from the Figma Landing).
  dots,

  /// Thin lines on a square grid (the QR scanner).
  grid,

  /// Hexagon outlines in a honeycomb (the Check tab's header).
  hexagons,
}

/// Which way a [PatternBackground] fades out.
enum PatternFade {
  /// Even all over.
  none,

  /// Full at the top, gone at the bottom.
  down,

  /// Full at the end (right in left-to-right), gone at the start.
  towardStart,
}

/// A decorative pattern filling its box. It is decoration only: hidden
/// from screen readers and ignoring taps.
class PatternBackground extends StatelessWidget {
  const PatternBackground({
    required this.color,
    this.kind = PatternKind.dots,
    this.spacing = 22,
    this.fade = PatternFade.none,
    super.key,
  });

  final Color color;
  final PatternKind kind;

  /// Distance between dots or lines; a hexagon's width.
  final double spacing;

  final PatternFade fade;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: PatternPainter(
            color: color,
            kind: kind,
            spacing: spacing,
            fade: fade,
            rtl: Directionality.maybeOf(context) == TextDirection.rtl,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Paints a [PatternBackground].
class PatternPainter extends CustomPainter {
  PatternPainter({
    required this.color,
    required this.kind,
    required this.spacing,
    required this.fade,
    this.rtl = false,
  }) : assert(spacing > 0, 'spacing must be positive');

  final Color color;
  final PatternKind kind;
  final double spacing;
  final PatternFade fade;
  final bool rtl;

  static const _dotRadius = 1.2;
  static const _lineWidth = 1.0;

  /// The colour at [at], faded as [fade] says.
  Color _colorAt(Offset at, Size size) {
    final share = switch (fade) {
      PatternFade.none => 1.0,
      PatternFade.down => 1 - at.dy / size.height,
      PatternFade.towardStart =>
        rtl ? 1 - at.dx / size.width : at.dx / size.width,
    };
    return color.withValues(alpha: color.a * share.clamp(0, 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (kind) {
      case PatternKind.dots:
        final paint = Paint()..style = PaintingStyle.fill;
        for (var y = spacing / 2; y < size.height; y += spacing) {
          for (var x = spacing / 2; x < size.width; x += spacing) {
            final at = Offset(x, y);
            paint.color = _colorAt(at, size);
            canvas.drawCircle(at, _dotRadius, paint);
          }
        }
      case PatternKind.grid:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth;
        for (var x = 0.0; x <= size.width; x += spacing) {
          paint.color = _colorAt(Offset(x, size.height / 2), size);
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 0.0; y <= size.height; y += spacing) {
          paint.color = _colorAt(Offset(size.width / 2, y), size);
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case PatternKind.hexagons:
        _paintHexagons(canvas, size);
    }
  }

  /// Pointy-top hexagons [spacing] wide, rows offset by half a hexagon.
  void _paintHexagons(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineWidth;
    final radius = spacing / math.sqrt(3);
    final rowStep = radius * 1.5;
    var row = 0;
    for (var cy = 0.0; cy <= size.height + radius; cy += rowStep, row++) {
      final shift = row.isOdd ? spacing / 2 : 0.0;
      for (var cx = shift; cx <= size.width + spacing; cx += spacing) {
        final centre = Offset(cx, cy);
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final angle = math.pi / 6 + i * math.pi / 3;
          final point =
              centre + Offset(math.cos(angle), math.sin(angle)) * radius;
          i == 0
              ? path.moveTo(point.dx, point.dy)
              : path.lineTo(point.dx, point.dy);
        }
        path.close();
        paint.color = _colorAt(centre, size);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PatternPainter old) =>
      old.color != color ||
      old.kind != kind ||
      old.spacing != spacing ||
      old.fade != fade ||
      old.rtl != rtl;
}
