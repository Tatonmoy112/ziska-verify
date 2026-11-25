import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// Where a camera problem shows: inline in scanner mode's camera area, or
/// over the whole camera of the check tab.
enum CameraProblemLayout { inline, fullScreen }

/// Why the camera cannot read, with Open settings when the permission is
/// missing (production audit P-40: written once, for both cameras).
class CameraProblemView extends StatelessWidget {
  const CameraProblemView({
    required this.problem,
    required this.layout,
    required this.onOpenSettings,
    super.key,
  });

  final ScannerProblem problem;
  final CameraProblemLayout layout;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final full = layout == CameraProblemLayout.fullScreen;
    final text = switch (problem) {
      ScannerProblem.permissionDenied => l.scannerPermissionDenied,
      ScannerProblem.unsupported => l.scannerUnsupported,
      ScannerProblem.other => l.scannerFailed,
    };
    return ColoredBox(
      key: full ? const Key('scanner.problem') : null,
      color: full ? AppColors.scannerBackground : AppColors.textStrong,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.cameraOff,
                color: AppColors.onPrimary,
                size: full ? 40 : 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                key: full ? null : const Key('session.cameraProblem'),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.onPrimary),
              ),
              if (problem == ScannerProblem.permissionDenied) ...[
                SizedBox(height: full ? AppSpacing.md : AppSpacing.sm),
                AppButton(
                  key: full ? const Key('scanner.openSettings') : null,
                  label: l.openSettings,
                  variant: full
                      ? AppButtonVariant.primary
                      : AppButtonVariant.tonal,
                  onPressed: onOpenSettings,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
