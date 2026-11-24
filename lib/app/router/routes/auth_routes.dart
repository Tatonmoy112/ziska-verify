import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/password_cubits.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/request_access_cubit.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/verify_code_bloc.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/change_password_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/login_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/request_access_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/splash_screen.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/verify_code_screen.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// The start, login, password and access-request pages (final.md §6, §9).
List<RouteBase> authRoutes(RouteDeps d) {
  final locator = d.locator;
  final session = d.session;
  return [
    GoRoute(
      name: RouteNames.splash,
      path: RoutePaths.splash,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      name: RouteNames.login,
      path: RoutePaths.login,
      builder: (_, _) => BlocProvider(
        create: (_) => LoginBloc(locator<Login>()),
        child: LoginScreen(
          versionInfo: locator<AppInfoService>().versionInfo(),
        ),
      ),
      routes: [
        GoRoute(
          name: RouteNames.verifyCode,
          path: 'verify-code',
          builder: (_, _) {
            final state = session.current;
            final email = state is SessionAwaitingCode ? state.email : '';
            return BlocProvider(
              create: (_) => VerifyCodeBloc(
                verifyCode: locator<VerifyCode>(),
                resendCode: locator<ResendCode>(),
                cancelCode: locator<CancelCode>(),
              ),
              child: VerifyCodeScreen(email: email),
            );
          },
        ),
      ],
    ),
    GoRoute(
      name: RouteNames.forgotPassword,
      path: RoutePaths.forgotPassword,
      builder: (_, state) => BlocProvider(
        create: (_) => ForgotPasswordCubit(locator<RequestPasswordReset>()),
        child: ForgotPasswordScreen(
          initialEmail: state.extra is String ? state.extra! as String : null,
        ),
      ),
      routes: [
        GoRoute(
          name: RouteNames.resetPassword,
          path: 'reset',
          // A missing `extra` (the system restored the app) goes back to
          // the parent route (final.md §9).
          redirect: (_, state) =>
              state.extra is String ? null : RoutePaths.forgotPassword,
          builder: (_, state) => BlocProvider(
            create: (_) => ResetPasswordCubit(locator<ResetPassword>()),
            child: ResetPasswordScreen(email: state.extra! as String),
          ),
        ),
      ],
    ),
    GoRoute(
      name: RouteNames.requestAccess,
      path: RoutePaths.requestAccess,
      builder: (context, _) {
        final config = locator<AppConfig>();
        return BlocProvider(
          create: (_) {
            final cubit = RequestAccessCubit(
              roles: locator<GetRequestableRoles>(),
              sendCode: locator<SendAccessCode>(),
              submit: locator<SubmitAccessRequest>(),
            );
            unawaited(cubit.load());
            return cubit;
          },
          child: RequestAccessScreen(
            onContactOffice:
                config.officeEmail.isEmpty && config.officePhone.isEmpty
                ? null
                : () async {
                    final launcher = locator<LauncherService>();
                    final email = config.officeEmail;
                    final ok = email.isNotEmpty
                        ? await launcher.email(
                            to: email,
                            subject: '',
                            body: '',
                          )
                        : await launcher.call(config.officePhone);
                    if (!ok && context.mounted) {
                      final l = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            email.isNotEmpty
                                ? l.noMailApp(email)
                                : l.noPhoneApp(config.officePhone),
                          ),
                        ),
                      );
                    }
                  },
          ),
        );
      },
    ),
    GoRoute(
      name: RouteNames.changePassword,
      path: RoutePaths.changePassword,
      builder: (_, _) {
        return BlocProvider(
          create: (_) => ChangePasswordCubit(
            locator<ChangePassword>(),
            locator<Logout>(),
          ),
          child: ChangePasswordScreen(
            forced: session.current is SessionPasswordChangeRequired,
          ),
        );
      },
    ),
  ];
}
