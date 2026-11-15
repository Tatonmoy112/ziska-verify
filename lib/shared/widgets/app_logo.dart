import 'package:flutter/material.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';

/// The Ziska Pharma mark as drawn in the Figma. Replaced by the client's
/// logo file when it is supplied.
class AppLogo extends StatelessWidget {
  const AppLogo({this.width = 120, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    final scale = width / 120;
    // A brand mark keeps its proportions: the system font size must not
    // make "ZISKA" wrap or grow the logo (it is drawn at [width]).
    return Semantics(
      label: 'Ziska Pharma',
      child: MediaQuery.withNoTextScaling(
        child: _buildMark(scale),
      ),
    );
  }

  Widget _buildMark(double scale) {
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2 * scale),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2 * scale),
                child: Text(
                  'ZISKA',
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1 * scale,
                    height: 1.1,
                  ),
                ),
              ),
              ColoredBox(
                color: AppColors.primary,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'PHARMA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                      letterSpacing: 4 * scale,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
