import 'package:flutter/widgets.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';

/// Two buttons side by side, or one above the other at a large font so no
/// label is cut (TC-UI-142; production audit P-40: written once).
class ButtonPair extends StatelessWidget {
  const ButtonPair({
    required this.first,
    required this.second,
    this.firstFlex = 1,
    this.secondFlex = 1,
    this.stackedGap = AppSpacing.sm,
    this.secondFirstWhenStacked = false,
    super.key,
  });

  /// The left one, side by side.
  final Widget first;
  final Widget second;
  final int firstFlex;
  final int secondFlex;
  final double stackedGap;

  /// Stacked, [second] goes on top (the main action first).
  final bool secondFirstWhenStacked;

  @override
  Widget build(BuildContext context) {
    if (isLargeText(context)) {
      final top = secondFirstWhenStacked ? second : first;
      final bottom = secondFirstWhenStacked ? first : second;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          SizedBox(height: stackedGap),
          bottom,
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: firstFlex, child: first),
        const SizedBox(width: AppSpacing.sm),
        Expanded(flex: secondFlex, child: second),
      ],
    );
  }
}
