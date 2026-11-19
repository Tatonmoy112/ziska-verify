import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/features/authentication/presentation/widgets/password_rules.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// TC-AUTH-117: the rule against control characters is explained when it
/// is broken (app API guide §3.6, SRS FR-ACC-13), never shown otherwise.
void main() {
  Future<void> rules(WidgetTester tester, String password) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PasswordRules(check: const PasswordPolicy().check(password)),
      ),
    ),
  );

  testWidgets('TC-AUTH-117 a pasted tab shows the fourth rule', (
    tester,
  ) async {
    await rules(tester, 'abcd${String.fromCharCode(9)}1234');
    expect(find.text('no tabs or line breaks'), findsOneWidget);
  });

  testWidgets('TC-AUTH-117 a normal password shows the three rules only', (
    tester,
  ) async {
    await rules(tester, 'abcd1234');
    expect(find.text('no tabs or line breaks'), findsNothing);
    expect(find.text('8 characters or more'), findsOneWidget);
  });
}
