import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/reference_text.dart';

/// An inline error under a form, with its reference.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({required this.message, this.requestId, super.key});

  final String message;
  final String? requestId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.dangerBackground,
          borderRadius: AppRadius.input,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.circleAlert, color: AppColors.danger),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppTypography.body.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  ReferenceText(requestId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
