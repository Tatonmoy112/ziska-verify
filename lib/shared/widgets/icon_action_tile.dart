import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A row with an icon in a soft square, a title, an optional subtitle and,
/// when it can be tapped, a chevron: the check tab's tools and Profile's
/// rows (production audit P-40: written once).
class IconActionTile extends StatelessWidget {
  const IconActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.contentPadding,
    this.shape,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// `null`: shown, not tapped (no chevron).
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  /// The ink's shape, for a tile on a card.
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return ListTile(
      onTap: onTap,
      shape: shape,
      contentPadding: contentPadding,
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title, style: AppTypography.bodyStrong),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: AppTypography.caption),
      trailing: onTap == null
          ? null
          : const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}
