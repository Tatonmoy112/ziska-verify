import 'package:flutter/widgets.dart';

/// The phone's font size is 1.5 × or more: side-by-side layouts stack, so a
/// label is never cut or broken mid-word (docs/test-cases/15-ui.md
/// TC-UI-142).
bool isLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(10) >= 15;
