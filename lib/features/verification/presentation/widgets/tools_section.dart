import 'package:flutter/material.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/icon_action_tile.dart';

class ToolsSection extends StatelessWidget {
  const ToolsSection({required this.tools, super.key});

  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.toolsTitle, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.xs),
        ...tools,
      ],
    );
  }
}

class ToolTile extends StatelessWidget {
  const ToolTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        child: IconActionTile(
          icon: icon,
          title: title,
          onTap: onTap,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
      ),
    );
  }
}
