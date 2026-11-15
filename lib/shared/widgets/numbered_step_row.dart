import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// One numbered step: the number in a small grey square, then a title and
/// a line under it (Request access "How it works", from the Figma). Read
/// by a screen reader as one item: "Step 1. Title. Body".
class NumberedStepRow extends StatelessWidget {
  const NumberedStepRow({
    required this.number,
    required this.title,
    required this.body,
    super.key,
  });

  final int number;
  final String title;
  final String body;

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // At least 28 square; grows with the font size, like the title.
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _badgeSize,
              minHeight: _badgeSize,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                // Sized to the number, centred in the 28 square.
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    '$number',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyStrong),
                const SizedBox(height: AppSpacing.xxs),
                Text(body, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
