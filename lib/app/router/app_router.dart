import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/router/app_navigation_observer.dart';
import 'package:ziska_verify/app/router/route_guard.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/router_refresh.dart';
import 'package:ziska_verify/app/shell/main_shell.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
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
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/screens/history_screen.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/my_reports_screen.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/report_incident_screen.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/profile/presentation/screens/profile_screen.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_admin_cubits.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';
import 'package:ziska_verify/features/retail_users/presentation/screens/add_retail_user_screen.dart';
import 'package:ziska_verify/features/retail_users/presentation/screens/retail_users_screen.dart';
import 'package:ziska_verify/features/retail_users/presentation/widgets/retail_user_picker_sheet.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/bulk_lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/bulk_lookup_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/scanner_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verify_screen.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';

/// Builds the app's single `GoRouter` (final.md Section 9). The only place
/// that imports feature screens.
GoRouter buildRouter({
  required GetIt locator,
  required ProfileCubit profileCubit,
  RouteGuard? guard,
}) {
  final session = locator<SessionService>();
  final routeGuard = guard ?? RouteGuard(permissionByPath: tabPermissionByPath);
  final refresh = RouterRefresh([session.states, profileCubit.stream]);

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    observers: [AppNavigationObserver(locator<LoggerService>())],
    redirect: (context, state) => routeGuard.redirect(
      session: session.current,
      profileLoaded: profileCubit.state.status == ProfileStatus.loaded,
      permissions: profileCubit.state.permissions,
      location: state.matchedLocation,
    ),
    errorBuilder: (context, state) => const _NotAvailableScreen(),
    routes: [
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
          child: const LoginScreen(),
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
        builder: (_, _) => BlocProvider(
          create: (_) => ForgotPasswordCubit(locator<RequestPasswordReset>()),
          child: const ForgotPasswordScreen(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.resetPassword,
            path: 'reset',
            // A missing `extra` (the system restored the app) goes back to
            // the parent route (final.md Section 9.5).
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
        builder: (_, _) {
          final config = locator<AppConfig>();
          return BlocProvider(
            create: (_) => RequestAccessCubit(
              launcher: locator<LauncherService>(),
              officeEmail: config.officeEmail,
              officePhone: config.officePhone,
            ),
            child: const RequestAccessScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteNames.changePassword,
        path: RoutePaths.changePassword,
        builder: (_, _) => BlocProvider(
          create: (_) => ChangePasswordCubit(
            locator<ChangePassword>(),
            locator<Logout>(),
          ),
          child: ChangePasswordScreen(
            forced: session.current is SessionPasswordChangeRequired,
          ),
        ),
      ),
      // Lookup flows open above the bottom bar (final.md Section 9.2).
      GoRoute(
        name: RouteNames.scan,
        path: RoutePaths.scan,
        builder: (_, _) => BlocProvider(
          create: (_) => _lookupBloc(locator),
          child: ScannerScreen(
            scanner: locator<ScannerService>(),
            onOpenSettings: locator<PermissionService>().openSettings,
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.lookupResult,
        path: RoutePaths.lookupResult,
        // Without its result (the system restored the app) it goes back to
        // the Verify tab (final.md Section 9.5).
        redirect: (_, state) =>
            state.extra is ResultView ? null : RoutePaths.home,
        builder: (_, state) => LookupResultScreen(
          view: state.extra! as ResultView,
          pictures: locator<PictureImages>(),
          launcher: locator<LauncherService>(),
        ),
      ),
      GoRoute(
        name: RouteNames.bulkLookup,
        path: RoutePaths.bulkLookup,
        builder: (_, _) => BlocProvider(
          create: (_) => BulkLookupBloc(
            getFormats: locator<GetFormats>(),
            bulkLookup: locator<BulkLookup>(),
          )..add(const BulkFormatsRequested()),
          child: BulkLookupScreen(scanner: locator<ScannerService>()),
        ),
      ),
      GoRoute(
        name: RouteNames.myReports,
        path: RoutePaths.myReports,
        builder: (_, _) => BlocProvider(
          create: (_) =>
              MyReportsBloc(locator<GetMyReports>())
                ..add(const MyReportsStarted()),
          child: const MyReportsScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.reportIncident,
        path: RoutePaths.reportIncident,
        builder: (_, state) => BlocProvider(
          create: (_) => ReportIncidentBloc(
            fileReport: locator<FileReport>(),
            addPhoto: locator<AddReportPhoto>(),
            photos: locator<PhotoService>(),
            checkRef: state.uri.queryParameters['check_ref'],
          ),
          child: ReportIncidentScreen(
            pickRetailUser: (context) => showRetailUserPicker(
              context,
              search: locator<SearchRetailUsers>(),
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.retailUsers,
        path: RoutePaths.retailUsers,
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  RetailUserPickerBloc(locator<SearchRetailUsers>())
                    ..add(const PickerStarted()),
            ),
            BlocProvider(
              create: (_) =>
                  EmailPasswordCubit(locator<EmailNewFirstPassword>()),
            ),
          ],
          child: const RetailUsersScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.addRetailUser,
        path: RoutePaths.addRetailUser,
        builder: (_, _) => BlocProvider(
          create: (_) {
            final cubit = AddRetailUserCubit(
              getRoles: locator<GetRetailRoles>(),
              addRetailUser: locator<AddRetailUser>(),
            );
            unawaited(cubit.loadRoles());
            return cubit;
          },
          child: const AddRetailUserScreen(),
        ),
      ),
      // The three tabs of the bottom navigation (final.md Section 9.3.1).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.home,
                path: RoutePaths.home,
                builder: (context, _) => BlocProvider(
                  create: (_) => _lookupBloc(locator),
                  child: VerifyScreen(
                    onOpenProfile: () => context.goNamed(RouteNames.profile),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.history,
                path: RoutePaths.history,
                builder: (_, state) {
                  final search = state.uri.queryParameters['search'];
                  final query = CheckQuery(search: search);
                  return BlocProvider(
                    create: (_) =>
                        HistoryBloc(locator<GetChecks>(), initialQuery: query)
                          ..add(HistoryQueryChanged(query)),
                    child: const HistoryScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.profile,
                path: RoutePaths.profile,
                builder: (context, _) {
                  final screen = ProfileScreen(
                    versionInfo: locator<AppInfoService>().versionInfo(),
                    onChangePassword: () =>
                        context.pushNamed(RouteNames.changePassword),
                    onContactSupport: (profile) {
                      final launcher = locator<LauncherService>();
                      final email = profile.supportEmail;
                      unawaited(
                        email != null
                            ? launcher.email(to: email, subject: '', body: '')
                            : launcher.call(profile.supportPhone ?? ''),
                      );
                    },
                    onLogout: locator<Logout>().call,
                  );
                  // The check counts come from History: only for a profile
                  // that can read it (final.md Section 13.8).
                  final permissions = context
                      .read<ProfileCubit>()
                      .state
                      .permissions;
                  if (!permissions.contains('history:own') &&
                      !permissions.contains('history:all')) {
                    return screen;
                  }
                  return BlocProvider(
                    create: (_) => CheckTotalsCubit(locator<GetChecks>()),
                    child: screen,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // go_router runs the redirect on the base location only, so a pushed
  // screen whose permission was just lost (a `403 forbidden` reload,
  // final.md Sections 7.2, 9.4) is checked here: the official goes Home.
  profileCubit.stream.listen((profile) {
    if (profile.status != ProfileStatus.loaded) return;
    final denied =
        _matchedLocations(
          router.routerDelegate.currentConfiguration.matches,
        ).any(
          (location) =>
              routeGuard.redirect(
                session: session.current,
                profileLoaded: true,
                permissions: profile.permissions,
                location: location,
              ) !=
              null,
        );
    if (denied) router.go(RoutePaths.home);
  });
  return router;
}

LookupBloc _lookupBloc(GetIt locator) => LookupBloc(
  getFormats: locator<GetFormats>(),
  lookupItem: locator<LookupItem>(),
)..add(const FormatsRequested());

class _NotAvailableScreen extends StatelessWidget {
  const _NotAvailableScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorNotAvailable),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.retry,
                // The guard sends the official where the session allows.
                onPressed: () => context.goNamed(RouteNames.splash),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every location in the match tree, pushed screens included.
Iterable<String> _matchedLocations(List<RouteMatchBase> matches) sync* {
  for (final match in matches) {
    switch (match) {
      case ImperativeRouteMatch(:final matches):
        yield* _matchedLocations(matches.matches);
      case ShellRouteMatch(:final matches):
        yield* _matchedLocations(matches);
      default:
        yield match.matchedLocation;
    }
  }
}
