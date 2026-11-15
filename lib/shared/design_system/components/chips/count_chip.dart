import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A filter chip with a count ("Valid 80"), from the Figma History. The
/// chosen one is navy with white text (decision sheet Q21, option A); the
/// others are white with a light border. Read by a screen reader as one
/// selectable button: "Valid, 80".
class CountChip extends StatelessWidget {
  const CountChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    super.key,
  });

  final String label;

  /// Not shown while unknown (the counts are loading or failed).
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  static const minHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? AppColors.primary : AppColors.background;
    final text = selected ? AppColors.onPrimary : AppColors.textStrong;
    const shape = StadiumBorder();
    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: selected
            ? shape
            : const StadiumBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.link.copyWith(
                      color: text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.onPrimary.withValues(alpha: 0.2)
                            : AppColors.surfaceMuted,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.pill),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text(
                          '$count',
                          style: AppTypography.caption.copyWith(
                            color: selected
                                ? AppColors.onPrimary
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
