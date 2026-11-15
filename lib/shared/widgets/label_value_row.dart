import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A detail row: the label on the left in `caption`, the value on the right
/// in `bodyStrong`, ending at the edge (item details, Profile).
///
/// The label is as wide as its text, at most 40 % of the row; the value
/// gets the rest. A long value wraps; with [oneLine] it stays on one line
/// beside the label when it fits. Otherwise (a large font) the label goes
/// above the value, which wraps over the whole width: nothing is cut.
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    required this.label,
    required this.value,
    this.oneLine = false,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final bool oneLine;

  /// The value's colour, when it tells a state (a result).
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measured with the inherited font, as the label is drawn.
        final style = DefaultTextStyle.of(
          context,
        ).style.merge(AppTypography.caption);
        double width(String text, TextStyle s) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: s),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final w = painter.width;
          painter.dispose();
          return w;
        }

        final labelWidth = width(label, style);
        // A one-line value that does not fit beside the label is not cut:
        // the row stacks and the value wraps over the whole width.
        final valueFits =
            !oneLine ||
            width(value, style.merge(AppTypography.bodyStrong)) <=
                constraints.maxWidth - labelWidth - AppSpacing.md;
        if (labelWidth > constraints.maxWidth * 0.4 || !valueFits) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(
                  value,
                  style: AppTypography.bodyStrong.copyWith(color: valueColor),
                ),
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: oneLine
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
              child: Text(label, style: AppTypography.caption),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTypography.bodyStrong.copyWith(color: valueColor),
                maxLines: oneLine ? 1 : null,
                overflow: oneLine ? TextOverflow.ellipsis : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
