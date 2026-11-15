@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';

import 'ui_helpers.dart';

/// Step 2 of the UI plan: one sample golden to check that letters and
/// icons draw with real fonts.
void main() {
  setUpAll(loadUiFonts);

  testWidgets('sample: a button, an icon, and an error banner', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const Padding(
        padding: EdgeInsets.all(AppSpacing.screen),
        child: Column(
          children: [
            AppButton(label: 'Login securely', onPressed: _noop),
            SizedBox(height: AppSpacing.md),
            Icon(LucideIcons.shieldCheck, size: 32),
            SizedBox(height: AppSpacing.md),
            ErrorBanner(
              message: 'Email or password is incorrect.',
              requestId: 'req-1',
            ),
          ],
        ),
      ),
      size: const Size(390, 320),
    );
    await expectGolden(tester, 'sample');
  });
}

void _noop() {}
