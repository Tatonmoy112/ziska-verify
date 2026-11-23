import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// TC-AUTH-118: asking for an account is a request the office answers, not
/// an account made at once (guide §3.9 "Request access"; SRS FR-REQ-01).
/// The texts follow the guide: "Send request", and "Your request was sent.
/// You will get an email when it is answered."
void main() {
  testWidgets('TC-AUTH-118 Request access: the screen, the button and the '
      'answer say it is a request', (tester) async {
    final app = await startApp(tester, loggedIn: false);
    expect(find.text('Sign up'), findsNothing);
    await app.tapText('Request access');

    expect(find.text('Request access'), findsOneWidget);
    expect(
      find.text(
        'Ask for an account. Your office checks the request and emails you '
        'its answer.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Create your account'), findsNothing);

    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    expect(
      find.descendant(
        of: find.byKey(const Key('access.submit')),
        matching: find.text('Send request'),
      ),
      findsOneWidget,
    );
    await app.tap(find.byKey(const Key('access.submit')));
    expect(
      find.text(
        'Your request was sent. You will get an email when it is answered.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('signing up'), findsNothing);
  });
}
