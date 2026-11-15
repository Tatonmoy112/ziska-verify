import 'package:flutter/painting.dart';

/// Colour tokens taken from the Figma exports (`figma/`). The only place
/// colours are defined (final.md Section 14).
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1E3A8A);
  static const primaryDark = Color(0xFF0F1E5A);
  static const onPrimary = Color(0xFFFFFFFF);

  /// White at 10 %: decoration on navy (the Verify header's honeycomb, the
  /// Scan card's QR corner).
  static const onPrimaryFaint = Color(0x1AFFFFFF);

  // Text
  static const textStrong = Color(0xFF0F1D4A);
  static const textBody = Color(0xFF5B6B85);
  static const textLabel = Color(0xFF475569);

  /// Darkened from the Figma's #94A3B8 (2.56:1 on white) to meet the WCAG
  /// 4.5:1 minimum for small text on every surface, [surfaceMuted] too
  /// (test plan TC-NFR-004, docs/test-cases/15-ui.md UI-020).
  static const textMuted = Color(0xFF5F6E84);

  // Surfaces
  static const background = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF4F6FB);
  static const border = Color(0xFFE2E8F0);

  // Information panel (Request access "Please include")
  static const infoBackground = Color(0xFFE0F2FE);
  static const infoBorder = Color(0xFFBAE6FD);

  /// Darkened from #0EA5E9 (2.42:1 on [infoBackground]): the panel title
  /// is small text (UI-020).
  static const infoAccent = Color(0xFF0369A1);

  // States. Each is also small text (check badges, reasons, password
  // rules, the error banner), so each meets 4.5:1 on white, on
  // [surfaceMuted], and on its own background (UI-020). Darkened from the
  // Figma's #16A34A, #D97706, and #DC2626 (3.30, 3.19, and 4.41:1).
  static const success = Color(0xFF15803D);
  static const successBackground = Color(0xFFF0FDF4);
  static const warning = Color(0xFFB45309);
  static const warningBackground = Color(0xFFFFFBEB);
  static const danger = Color(0xFFC81E1E);
  static const dangerBackground = Color(0xFFFEF2F2);

  /// Success text on the dark header (the Profile role badge).
  static const successOnDark = Color(0xFFBBF7D0);

  /// Behind the camera and over a photo; see-through with an alpha.
  static const scrim = Color(0xFF000000);

  /// The QR scanner's dark navy, around the scan window (Figma "scan by
  /// barcode").
  static const scannerBackground = Color(0xFF0B1226);

  /// The scan frame's corners, scan line, and "looking" dot: decoration on
  /// [scannerBackground], never text.
  static const scanAccent = Color(0xFF4ADE80);

  /// The header gradient (Request access, Home).
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
