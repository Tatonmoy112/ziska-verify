import 'package:flutter/painting.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

/// Type scale from the Figma. The bundled font with Bangla support is added
/// when the client supplies it (final.md Section 2.2); until then the
/// platform font is used.
abstract final class AppTypography {
  /// The app's name on the Splash (Figma Landing Page).
  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textStrong,
  );

  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textStrong,
  );

  static const headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textStrong,
  );

  /// A name at the top of a card or header (Profile).
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textStrong,
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textBody,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textStrong,
  );

  static const bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textStrong,
  );

  static const caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textBody,
  );

  /// A card's upper-case title ("PRODUCT DETAILS", "PRODUCT IMAGE").
  static const sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textStrong,
  );

  /// Upper-case field labels ("USER ID", "PASSWORD").
  static const fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textLabel,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}
