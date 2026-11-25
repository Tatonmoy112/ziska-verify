import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// One scan in the list: its result's icon and colour, serial and product.
/// Opens the full result when this run answered it.
class SessionScanRow extends StatelessWidget {
  const SessionScanRow({required this.row, this.onTap, super.key});

  final RecoveredScan row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = outcomeStyle(row.outcome, AppLocalizations.of(context));
    return ListTile(
      onTap: onTap,
      leading: Icon(style.icon, color: style.color),
      title: Text(row.serial ?? row.ref, style: AppTypography.bodyStrong),
      subtitle: Text(
        [style.title, ?row.product].join(' · '),
        style: AppTypography.caption.copyWith(color: style.color),
      ),
      trailing: onTap == null
          ? null
          : const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}
