import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  testWidgets('smoke: a logged-in official lands on the Verify tab', (
    tester,
  ) async {
    await startApp(tester);
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Asha Rao'), findsOneWidget);
  });

  testWidgets('smoke: logged out starts on Login', (tester) async {
    await startApp(tester, loggedIn: false);
    expect(find.text('Login to Track & Trace'), findsOneWidget);
  });
}
