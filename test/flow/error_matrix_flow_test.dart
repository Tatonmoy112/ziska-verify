import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import 'harness.dart';

/// The request matrix of docs/test-cases/10-errors-network.md: every
/// request the app sends, answered with every error code (TC-ERR-007,
/// -009, -010, -011, -013, -015, -016). Each request shows the general text
/// for a code unless the matrix gives it its own.
void main() {
  const loginTitle = 'Login to Track & Trace';
  const general = 'Something went wrong. Try again.';
  const busy = 'The service is busy. Try again shortly.';
  const notAvailable = 'Not available.';
  // The seconds go down while the screen settles.
  const waitText = 'Too many attempts. Try again in';
  const codeWrong =
      'The code is wrong or has expired. Check the latest email, or send the '
      'code again.';
  // The reset screen's own text (backend D64, guide §3.7).
  const resetCodeWrong =
      'The code is wrong or has expired. Ask for a new code.';
  const photoRefused = 'This photo was refused.';
  const photoRetry = 'Not sent. Tap to send again.';

  Future<void> scrollTo(WidgetTester tester, Finder f) =>
      tester.scrollUntilVisible(
        f,
        300,
        scrollable: find.byType(Scrollable).first,
      );

  Future<void> tile(FlowApp app, String key) async {
    await scrollTo(app.tester, find.byKey(Key(key)));
    await app.tap(find.byKey(Key(key)));
  }

  Future<void> fillReport(FlowApp app) async {
    await app.enter(const Key('report.note'), 'Seal is cut');
    final button = find.byKey(const Key('report.submit'));
    final list = find
        .ancestor(
          of: find.byKey(const Key('report.note')),
          matching: find.byType(Scrollable),
        )
        .last;
    final position = app.tester.state<ScrollableState>(list).position;
    position.jumpTo(position.maxScrollExtent);
    await app.tester.pumpAndSettle();
    await app.tap(button);
  }

  /// One row of the matrix.
  final rows =
      <
        ({
          String name,
          String route,
          bool loggedIn,
          bool gated,
          Future<void> Function(FlowApp app) trigger,
          Map<int, String> own,
        })
      >[
        (
          name: 'login',
          route: 'POST auth/login',
          loggedIn: false,
          gated: false,
          trigger: logInToCode,
          own: {401: 'Email or password is incorrect.'},
        ),
        (
          name: 'code',
          route: 'POST auth/verify-phone',
          loggedIn: false,
          gated: false,
          trigger: (app) async {
            await logInToCode(app);
            await app.enter(const Key('verify.code'), '123456');
            await app.tap(find.byKey(const Key('verify.submit')));
          },
          own: {401: codeWrong},
        ),
        (
          name: 'resend',
          route: 'POST auth/resend-code',
          loggedIn: false,
          gated: false,
          trigger: (app) async {
            await logInToCode(app);
            await app.tester.pump(const Duration(seconds: 61));
            await app.tester.pumpAndSettle();
            await app.tapText('Send the code again');
          },
          // A 429 restarts the resend wait (TC-AUTH-007).
          own: {
            401: 'No more codes can be sent. Log in again.',
            429: 'Send again in',
          },
        ),
        (
          name: 'forgot',
          route: 'POST auth/password/forgot',
          loggedIn: false,
          gated: false,
          trigger: (app) async {
            await app.tapText('Forgot password?');
            await app.enter(const Key('forgot.email'), 'official@example.com');
            await app.tap(find.byKey(const Key('forgot.submit')));
          },
          own: {},
        ),
        (
          name: 'reset',
          route: 'POST auth/password/reset',
          loggedIn: false,
          gated: false,
          trigger: (app) async {
            await app.tapText('Forgot password?');
            await app.enter(const Key('forgot.email'), 'official@example.com');
            await app.tap(find.byKey(const Key('forgot.submit')));
            await app.enter(const Key('reset.code'), '123456');
            await app.enter(const Key('reset.new'), 'abcd1234');
            await app.enter(const Key('reset.repeat'), 'abcd1234');
            await app.tap(find.byKey(const Key('reset.submit')));
          },
          own: {401: resetCodeWrong},
        ),
        (
          name: 'change password',
          route: 'POST me/password',
          loggedIn: true,
          gated: false,
          trigger: (app) async {
            await app.tap(tab('Profile'));
            await app.tapText('Change password');
            await app.enter(const Key('change.old'), 'old-pass-1');
            await app.enter(const Key('change.new'), 'abcd1234');
            await app.enter(const Key('change.repeat'), 'abcd1234');
            await app.tap(find.byKey(const Key('change.submit')));
          },
          own: {401: 'The current password is incorrect.'},
        ),
        (
          name: 'profile',
          route: 'GET me',
          loggedIn: true,
          gated: false,
          trigger: (_) async {},
          own: {},
        ),
        (
          name: 'formats',
          route: 'GET formats',
          loggedIn: true,
          gated: false,
          trigger: (_) async {},
          own: {},
        ),
        (
          name: 'lookup',
          route: 'POST lookups',
          loggedIn: true,
          gated: true,
          trigger: (app) async {
            await app.enter(const Key('verify.input'), '1000001');
            await app.tap(find.byKey(const Key('verify.submit')));
          },
          own: {},
        ),
        (
          name: 'serial stack',
          route: 'POST lookups/serials',
          loggedIn: true,
          gated: true,
          trigger: (app) async {
            await tile(app, 'verify.tool.serials');
            await app.enter(const Key('serials.input'), '1000001');

            await app.tap(find.byKey(const Key('serials.submit')));
          },
          own: {},
        ),
        (
          name: 'history',
          route: 'GET checks',
          loggedIn: true,
          gated: true,
          trigger: (app) => app.tap(tab('History')),
          own: {},
        ),
        (
          name: 'file report',
          route: 'POST incidents',
          loggedIn: true,
          gated: true,
          trigger: (app) async {
            await tile(app, 'verify.tool.report');
            await fillReport(app);
          },
          // Nothing linked: a 404 is the route itself ("Not available").
          own: {404: notAvailable},
        ),
        (
          name: 'photo',
          route: 'POST incidents/1042/photos',
          loggedIn: true,
          gated: true,
          trigger: (app) async {
            await tile(app, 'verify.tool.report');
            await app.tap(find.byKey(const Key('report.addPhoto')));
            await app.tapText('Choose from gallery');
            await fillReport(app);
          },
          own: {
            400: photoRefused,
            404: photoRefused,
            // The photo counts its Retry-After down (guide section 1).
            429: waitText,
            500: photoRetry,
            503: photoRetry,
          },
        ),
        (
          name: 'my reports',
          route: 'GET incidents',
          loggedIn: true,
          gated: true,
          trigger: (app) => tile(app, 'verify.tool.myReports'),
          own: {},
        ),
        (
          name: 'retail users',
          route: 'GET retail-users',
          loggedIn: true,
          gated: true,
          trigger: (app) async {
            await tile(app, 'verify.tool.report');
            await app.tap(find.byKey(const Key('report.retailUser')));
          },
          own: {},
        ),
        (
          name: 'logout',
          route: 'POST auth/logout',
          loggedIn: true,
          gated: false,
          trigger: (app) async {
            await app.tap(tab('Profile'));
            await app.tap(find.byKey(const Key('profile.logout')));
            await app.tap(
              find.descendant(
                of: find.byType(AlertDialog),
                matching: find.text('Log out'),
              ),
            );
          },
          own: {},
        ),
      ];

  // (status, code, case)
  const codes = [
    (400, 'validation_failed', '007'),
    (401, 'unauthenticated', '009'),
    (403, 'forbidden', '010'),
    (404, 'not_found', '011'),
    (429, 'rate_limited', '013'),
    (503, 'service_unavailable', '015'),
    (500, 'internal_error', '016'),
  ];

  for (final (status, code, id) in codes) {
    group('TC-ERR-$id $status $code', () {
      for (final row in rows) {
        // 403 is for a route behind a permission.
        if (status == 403 && !row.gated) continue;

        testWidgets(row.name, (tester) async {
          final app = await startApp(
            tester,
            profile: Roles.supervisor,
            loggedIn: row.loggedIn,
            overrides: {
              row.route: always(
                apiError(status, code, retryAfter: status == 429 ? 30 : null),
              ),
            },
          );
          final mesBefore = app.backend.sent('GET', 'me').length;
          await row.trigger(app);
          await tester.pump(const Duration(milliseconds: 500));

          final own = row.own[status];
          if (row.name == 'logout') {
            // Any answer: the official is logged out anyway (§6.5).
            await tester.pumpAndSettle();
            expect(find.text(loginTitle), findsOneWidget);
            return;
          }
          if (own != null) {
            expect(find.textContaining(own), findsWidgets, reason: own);
            return;
          }
          switch (status) {
            case 401:
              if (row.loggedIn) {
                await tester.pumpAndSettle();
                expect(find.text(loginTitle), findsOneWidget);
                expect(app.storage.values[SecureKeys.refreshToken], isNull);
              } else {
                expect(find.textContaining(general), findsWidgets);
              }
            case 403:
              // The profile is loaded again once; no loop (§7.2).
              await tester.pump(const Duration(seconds: 3));
              await tester.pumpAndSettle();
              expect(app.backend.sent('GET', 'me').length, mesBefore + 1);
            case 400 || 500:
              expect(find.textContaining(general), findsWidgets);
              expect(find.textContaining('req-1'), findsWidgets);
            case 404:
              expect(find.textContaining(notAvailable), findsWidgets);
            case 429:
              expect(find.textContaining(waitText), findsWidgets);
            case 503:
              expect(find.textContaining(busy), findsWidgets);
          }
        });
      }
    });
  }
}
