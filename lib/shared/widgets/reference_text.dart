import 'package:flutter/material.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// "Reference: {request_id}" under every error (final.md Section 14.1).
/// Renders nothing when there is no reference.
class ReferenceText extends StatelessWidget {
  const ReferenceText(this.requestId, {this.color, super.key});

  final String? requestId;

  /// The text colour; [AppColors.textMuted] when null. Set it on a dark
  /// surface (the Splash's navy glow).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final id = requestId;
    if (id == null || id.isEmpty) return const SizedBox.shrink();
    return SelectableText(
      AppLocalizations.of(context).reference(id),
      style: AppTypography.caption.copyWith(
        color: color ?? AppColors.textMuted,
      ),
    );
  }
}
