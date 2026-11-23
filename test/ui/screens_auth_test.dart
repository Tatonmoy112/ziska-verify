import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/splash_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/widgets/password_rules.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/app_logo.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/gradient_header.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';

import '../fakes/roles.dart';
import '../flow/harness.dart';
import 'ui_helpers.dart';

/// Section C, part 1 of docs/test-cases/15-ui.md: the auth screens in each
/// state, through the flow harness and the fake backend (TC-UI-075 … -086).
/// The splash layout is TC-UI-001 … -009 (`splash_screen_test`,
/// `app_logo_test`); its Figma look is TC-UI-169 and -170 here.
class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  setUpAll(loadUiFonts);
  hideFlavourRibbon();
  final l10n = lookupAppLocalizations(const Locale('en'));
  const email = 'official@example.com';

  Map<String, dynamic> forced(Map<String, dynamic> profile) => {
    ...profile,
    'must_change_password': true,
  };

  /// The [AppButton] that holds [key] (a key on the button's widget).
  AppButton button(WidgetTester tester, Key key) =>
      tester.widget<AppButton>(find.byKey(key));

  /// Full width inside the 24 px sides, 56 high.
  void expectMainButton(WidgetTester tester, Finder finder) {
    final rect = tester.getRect(finder);
    expect(rect.left, AppSpacing.screen);
    expect(rect.right, phone.width - AppSpacing.screen);
    expect(rect.height, 56);
  }

  /// Back arrow of a [GradientHeader] (or an app bar).
  final back = find.byIcon(LucideIcons.arrowLeft);

  group('Splash', () {
    late _MockProfileCubit cubit;

    setUp(() {
      cubit = _MockProfileCubit();
      when(() => cubit.load()).thenAnswer((_) async {});
    });

    Future<void> splash(WidgetTester tester, ProfileState state) async {
      when(() => cubit.state).thenReturn(state);
      await pumpUi(
        tester,
        BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: const SplashScreen(),
        ),
        scaffold: false,
        // The progress never settles.
        settle: false,
      );
    }

    /// The glow reaches the bottom edge and spans the full width.
    void expectGlowAtBottom(WidgetTester tester) {
      final glow = tester.getRect(find.byKey(const Key('splash.glow')));
      expect(glow.left, 0);
      expect(glow.right, phone.width);
      expect(glow.bottom, phone.height);
    }

    /// [key] lies inside the navy glow.
    void expectOnGlow(WidgetTester tester, Key key) {
      final glow = tester.getRect(find.byKey(const Key('splash.glow')));
      final rect = tester.getRect(find.byKey(key));
      expect(glow.contains(rect.topLeft), isTrue, reason: '$key');
      expect(glow.contains(rect.bottomRight), isTrue, reason: '$key');
    }

    uiTest('TC-UI-169 splash in the Landing look', (tester, shot) async {
      await splash(tester, const ProfileState(status: ProfileStatus.loading));
      expect(find.byType(PatternBackground), findsOneWidget);
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text(l10n.appTitle), findsOneWidget);
      expect(find.text(l10n.appSubtitle), findsOneWidget);
      expect(find.text(l10n.splashTagline), findsOneWidget);
      expectGlowAtBottom(tester);
      expectOnGlow(tester, const Key('splash.tagline'));
      expectOnGlow(tester, const Key('splash.progress'));
      // The brand is above the glow, on white.
      expect(
        tester.getRect(find.byKey(const Key('splash.subtitle'))).bottom,
        lessThan(tester.getRect(find.byKey(const Key('splash.glow'))).top),
      );
      expect(
        drawnStyle(tester, find.text(l10n.splashTagline)).color,
        AppColors.onPrimary,
      );
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byKey(const Key('splash.progress')),
            )
            .color,
        AppColors.onPrimary,
      );
      await shot('screen_splash');
    });

    uiTest('TC-UI-170 splash error on the glow', (tester, shot) async {
      await splash(
        tester,
        const ProfileState(
          status: ProfileStatus.failure,
          failure: Failure(
            InternalErrorException(statusCode: 500, requestId: 'req-42'),
          ),
        ),
      );
      expectGlowAtBottom(tester);
      expectOnGlow(tester, const Key('splash.error'));
      expectOnGlow(tester, const Key('splash.retry'));
      expect(
        drawnStyle(tester, find.byKey(const Key('splash.error'))).color,
        AppColors.onPrimary,
      );
      // The navy button would vanish into the glow: Retry is the white one.
      expect(
        button(tester, const Key('splash.retry')).variant,
        AppButtonVariant.tonal,
      );
      expect(find.text('Reference: req-42'), findsOneWidget);
      await tester.tap(find.byKey(const Key('splash.retry')));
      verify(() => cubit.load()).called(1);
      await shot('screen_splash_error');
    });
  });

  group('Login', () {
    uiTest('TC-UI-075 login', (tester, shot) async {
      await startApp(tester, loggedIn: false);
      await atOneX(tester);
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text(l10n.loginTitle), findsOneWidget);
      expect(find.text(l10n.loginSubtitle), findsOneWidget);
      expect(find.text(l10n.emailLabel.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.passwordLabel.toUpperCase()), findsOneWidget);
      for (final key in [
        const Key('login.email'),
        const Key('login.password'),
      ]) {
        final field = tester.getRect(find.byKey(key));
        expect(field.left, AppSpacing.screen, reason: '$key');
        expect(field.right, phone.width - AppSpacing.screen, reason: '$key');
      }
      final submit = find.byKey(const Key('login.submit'));
      expectMainButton(tester, submit);
      expect(button(tester, const Key('login.submit')).label, l10n.loginButton);
      expect(
        button(tester, const Key('login.submit')).variant,
        AppButtonVariant.primary,
      );
      expect(find.text(l10n.forgotPassword), findsOneWidget);
      // The divider: two equal lines, the row as wide as the content.
      final lines = find
          .descendant(
            of: find
                .ancestor(
                  of: find.text(l10n.noAccountDivider),
                  matching: find.byType(Row),
                )
                .first,
            matching: find.byType(Divider),
          )
          .evaluate()
          .map((e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      expect(lines, hasLength(2));
      expect(lines.first.left, AppSpacing.screen);
      expect(lines.last.right, phone.width - AppSpacing.screen);
      expect(lines.first.width, moreOrLessEquals(lines.last.width));
      final contact = find.ancestor(
        of: find.text(l10n.requestAccessButton),
        matching: find.byType(AppButton),
      );
      expect(
        tester.widget<AppButton>(contact).variant,
        AppButtonVariant.outlined,
      );
      await shot('screen_login');
    });

    uiTest('TC-UI-184 login: the copyright footer at the bottom', (
      tester,
      _,
    ) async {
      await startApp(tester, loggedIn: false);
      await atOneX(tester);
      final footer = find.byKey(const Key('login.footer'));
      expect(
        find.text('© 2026 Ziska Pharmaceuticals Ltd. All rights reserved.'),
        findsOneWidget,
      );
      // The installed version (the harness's: 0.1.0, build 1).
      expect(find.text('Version 0.1.0 (1)'), findsOneWidget);
      expect(
        find.descendant(of: footer, matching: find.text(l10n.authorizedOnly)),
        findsOneWidget,
      );
      // Under Sign up, resting at the bottom of a tall phone.
      final rect = tester.getRect(footer);
      final request = tester.getRect(
        find.ancestor(
          of: find.text(l10n.requestAccessButton),
          matching: find.byType(AppButton),
        ),
      );
      expect(rect.top, greaterThan(request.bottom));
      expect(phone.height - rect.bottom, lessThanOrEqualTo(AppSpacing.xl));
      // Copyright above the version, both centred.
      final copyright = tester.getRect(
        find.byKey(const Key('login.copyright')),
      );
      final version = tester.getRect(find.byKey(const Key('login.version')));
      expect(copyright.bottom, lessThanOrEqualTo(version.top));
      expect(
        copyright.center.dx,
        moreOrLessEquals(phone.width / 2, epsilon: 1),
      );
      expect(version.center.dx, moreOrLessEquals(phone.width / 2, epsilon: 1));
      // Read out as one item.
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(
        find.bySemanticsLabel(
          '© 2026 Ziska Pharmaceuticals Ltd. All rights reserved. '
          'Version 0.1.0 (1)',
        ),
        findsOneWidget,
      );
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });

    uiTest('TC-UI-076 login: field errors', (tester, shot) async {
      final app = await startApp(tester, loggedIn: false);
      await app.enter(const Key('login.email'), 'not-an-email');
      await app.tap(find.byKey(const Key('login.submit')));
      await atOneX(tester);
      expect(find.text(l10n.emailInvalid), findsOneWidget);
      expect(find.text(l10n.fieldRequired), findsOneWidget);
      // Each error sits under its own field.
      expect(
        tester.getRect(find.text(l10n.emailInvalid)).top,
        greaterThan(tester.getRect(find.byKey(const Key('login.email'))).top),
      );
      expect(
        tester.getRect(find.text(l10n.fieldRequired)).top,
        greaterThan(
          tester.getRect(find.byKey(const Key('login.password'))).top,
        ),
      );
      expect(
        drawnStyle(tester, find.text(l10n.emailInvalid)).color,
        AppColors.danger,
      );
      expect(app.backend.sent('POST', 'auth/login'), isEmpty);
      await shot('screen_login_errors');
    });

    uiTest('TC-UI-077 login: failed', (tester, shot) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(
            apiError(401, 'unauthenticated', requestId: 'req-login'),
          ),
        },
      );
      await logInToCode(app);
      await atOneX(tester);
      expect(find.text(l10n.loginFailed), findsOneWidget);
      expect(find.text('Reference: req-login'), findsOneWidget);
      expect(
        tester.getRect(find.byType(ErrorBanner)).bottom,
        lessThan(tester.getRect(find.byKey(const Key('login.submit'))).top),
      );
      await shot('screen_login_failed');
    });

    uiTest('TC-UI-078 login: rate limited', (tester, shot) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/login': always(
            apiError(429, 'rate_limited', retryAfter: 30, requestId: 'req-l'),
          ),
        },
      );
      await logInToCode(app);
      await atOneX(tester);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.textContaining('Too many attempts'), findsOneWidget);
      await shot('screen_login_limited');
    });
  });

  group('Check your email', () {
    uiTest('TC-UI-079 check your email', (tester, shot) async {
      final app = await startApp(tester, loggedIn: false);
      await logInToCode(app);
      await atOneX(tester);
      expect(find.text(l10n.verifyCodeTitle), findsOneWidget);
      expect(find.textContaining(email), findsOneWidget);
      expect(find.byKey(const Key('verify.code')), findsOneWidget);
      expect(app.enabled(const Key('verify.submit')), isFalse);
      expect(find.textContaining('Send again in'), findsOneWidget);
      expect(find.text(l10n.backToLogin), findsOneWidget);
      expectMainButton(tester, find.byKey(const Key('verify.submit')));
      await shot('screen_code');
    });

    uiTest('TC-UI-080 check your email: wrong code', (tester, shot) async {
      final app = await startApp(
        tester,
        loggedIn: false,
        overrides: {
          'POST auth/verify-phone': always(
            apiError(401, 'unauthenticated', requestId: 'req-code'),
          ),
        },
      );
      await logInToCode(app);
      await app.enter(const Key('verify.code'), '123456');
      await app.tap(find.byKey(const Key('verify.submit')));
      await atOneX(tester);
      expect(find.text(l10n.codeWrong), findsOneWidget);
      expect(find.text('Reference: req-code'), findsOneWidget);
      await shot('screen_code_wrong');
    });
  });

  group('Forgot and reset', () {
    uiTest('TC-UI-081 forgot password', (tester, shot) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText(l10n.forgotPassword);
      await atOneX(tester);
      expect(find.byType(GradientHeader), findsOneWidget);
      expect(back, findsOneWidget);
      expect(find.text(l10n.forgotTitle), findsOneWidget);
      expect(find.text(l10n.forgotSubtitle), findsOneWidget);
      expect(find.byKey(const Key('forgot.email')), findsOneWidget);
      expect(
        button(tester, const Key('forgot.submit')).label,
        l10n.sendCodeButton,
      );
      expectMainButton(tester, find.byKey(const Key('forgot.submit')));
      await shot('screen_forgot');
    });

    uiTest('TC-UI-082 reset password', (tester, shot) async {
      final app = await startApp(tester, loggedIn: false);
      await app.tapText(l10n.forgotPassword);
      await app.enter(const Key('forgot.email'), email);
      await app.tap(find.byKey(const Key('forgot.submit')));
      await atOneX(tester);
      expect(find.text(l10n.resetTitle), findsWidgets);
      for (final key in ['reset.code', 'reset.new', 'reset.repeat']) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
      expect(find.byType(PasswordRules), findsOneWidget);
      expect(
        button(tester, const Key('reset.submit')).label,
        l10n.resetButton,
      );
      await shot('screen_reset');
    });
  });

  group('Change password', () {
    uiTest('TC-UI-083 set a new password (forced)', (tester, shot) async {
      await startApp(tester, profile: forced(Roles.fieldInspector));
      await atOneX(tester);
      expect(find.text(l10n.changePasswordTitle), findsOneWidget);
      expect(find.text(l10n.changePasswordForcedSubtitle), findsOneWidget);
      expect(back, findsNothing);
      for (final key in ['change.old', 'change.new', 'change.repeat']) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
      expect(find.byType(PasswordRules), findsOneWidget);
      expect(
        button(tester, const Key('change.submit')).label,
        l10n.changePasswordButton,
      );
      expect(find.text(l10n.logout), findsOneWidget);
      await shot('screen_change_forced');
    });

    uiTest('TC-UI-084 change password (from Profile)', (tester, shot) async {
      final app = await startApp(tester);
      await app.tapText(l10n.tabProfile);
      await app.tapText(l10n.changePasswordRow);
      await atOneX(tester);
      expect(back, findsOneWidget);
      expect(find.text(l10n.changePasswordSubtitle), findsOneWidget);
      expect(find.text(l10n.changePasswordForcedSubtitle), findsNothing);
      await shot('screen_change_voluntary');
    });

    uiTest('TC-UI-085 change password: refused', (tester, shot) async {
      final app = await startApp(
        tester,
        profile: forced(Roles.fieldInspector),
        overrides: {
          'POST me/password': always(
            apiError(403, 'policy_denied', requestId: 'req-policy'),
          ),
        },
      );
      await app.enter(const Key('change.old'), 'secret-pass');
      await app.enter(const Key('change.new'), 'abcd1234');
      await app.enter(const Key('change.repeat'), 'abcd1234');
      await app.tap(find.byKey(const Key('change.submit')));
      await atOneX(tester);
      expect(find.text(l10n.passwordRuleBroken), findsOneWidget);
      expect(find.text('Reference: req-policy'), findsOneWidget);
      await shot('screen_change_refused');
    });
  });

  uiTest('TC-UI-086 request access', (tester, shot) async {
    final app = await startApp(tester, loggedIn: false);
    await app.tapText(l10n.requestAccessButton);
    await atOneX(tester);
    expect(find.byKey(const Key('access.name')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    expect(find.byType(PasswordRules), findsOneWidget);
    expect(find.byKey(const Key('access.email')), findsOneWidget);
    expect(find.byKey(const Key('access.code')), findsNothing);
    expect(tester.takeException(), isNull);
    await shot('screen_request_access');
  });
  uiTest('TC-UI-171 request access at font size 2x', (tester, shot) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final app = await startApp(tester, loggedIn: false);
    await app.tapText(l10n.requestAccessButton);
    await atOneX(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('access.sendCode')),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await shot('screen_request_access_2x');
  });
}
