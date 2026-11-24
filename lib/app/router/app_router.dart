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
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
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
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/screens/history_screen.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_picker_sheet.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_totals_card.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/my_reports_screen.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/report_incident_screen.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/profile/presentation/screens/profile_screen.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/widgets/retail_user_picker_sheet.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/serial_stack_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/scan_session_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/serial_stack_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verify_screen.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_summary_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/sessions_view.dart';
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
  // The guard reads the session, whether the profile is loaded, and its
  // permissions: the router runs it again only when one of them changes. A
  // profile refresh that changes nothing else (the password reminder going,
  // say) must not rebuild the pages: right after a pop it would bring the
  // popped page back.
  final refresh = RouterRefresh([
    session.states,
    profileCubit.stream.map(_guardInput).distinct(),
  ]);

  Future<void> openManyResult(
    BuildContext context,
    LookupResult result,
    CheckedInput input,
    InputFormats? formats,
  ) async {
    await context.pushNamed<void>(
      RouteNames.lookupResult,
      extra: ResultView(
        result: result,
        input: input,
        origin: ResultOrigin.manyItems,
        formats: formats,
      ),
    );
  }

  Future<Result<RecoveredScans>> recovered(String id, String? cursor) async {
    final result = await locator<GetChecks>()(
      CheckQuery(sessionId: id),
      PageRequest(limit: 100, cursor: cursor),
    );
    return switch (result) {
      Success(:final value) => Success(
        CursorPage(
          items: [
            for (final c in value.page.items)
              RecoveredScan(
                ref: c.ref,
                outcome: switch (c.result) {
                  CheckResult.valid => LookupOutcome.valid,
                  CheckResult.warning => LookupOutcome.warning,
                  CheckResult.notFound => LookupOutcome.notFound,
                  CheckResult.unassigned => LookupOutcome.unassigned,
                  CheckResult.unknown => LookupOutcome.unknown,
                },
                serial: c.serial,
                product: c.product,
              ),
          ],
          nextCursor: value.page.nextCursor,
        ),
      ),
      Err(:final failure) => Err(failure),
    };
  }

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
      // Lookup flows open above the bottom bar (final.md Section 9.2).
      GoRoute(
        name: RouteNames.lookupResult,
        path: RoutePaths.lookupResult,
        // Without its result (the system restored the app) it goes back to
        // the Check tab (final.md Section 9.5).
        redirect: (_, state) {
          final view = state.extra;
          return view is ResultView &&
                  _allowsResult(view, profileCubit.state.permissions)
              ? null
              : RoutePaths.home;
        },
        builder: (_, state) {
          final view = state.extra;
          if (view is! ResultView ||
              !_allowsResult(view, profileCubit.state.permissions)) {
            // A pushed result whose permission was just lost: go_router
            // does not redirect a pushed page, and its `extra` is not in
            // the match list the profile listener reads, so the page
            // itself leaves for Verify instead of staying blank.
            return const _GoHome();
          }
          return LookupResultScreen(
            view: view,
            pictures: locator<PictureImages>(),
            launcher: locator<LauncherService>(),
          );
        },
      ),
      GoRoute(
        name: RouteNames.scannerMode,
        path: RoutePaths.scannerMode,
        builder: (context, _) => BlocProvider(
          create: (_) {
            final cubit = ScanSessionCubit(
              getFormats: locator(),
              getSession: locator(),
              scan: locator(),
              endSession: locator(),
              store: ActiveScanStore(
                locator<SecureStorageService>(),
                client: locator<AppConfig>().clientSlug,
                official: profileCubit.state.profile!.id,
              ),
              authStates: session.states,
              loadChecks:
                  profileCubit.state.permissions.contains(Permission.ownHistory)
                  ? recovered
                  : null,
            );
            unawaited(cubit.start());
            return cubit;
          },
          child: ScanSessionScreen(
            scanner: locator<ScannerService>(),
            onOpenSettings: locator<PermissionService>().openSettings,
            onOpenResult: (result, input, formats) =>
                openManyResult(context, result, input, formats),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.serialStack,
        path: RoutePaths.serialStack,
        builder: (context, _) => BlocProvider(
          create: (_) {
            final cubit = SerialStackCubit(
              getFormats: locator(),
              checkSerials: locator(),
            );
            unawaited(cubit.load());
            return cubit;
          },
          child: SerialStackScreen(
            onOpenResult: (result, input, formats) =>
                openManyResult(context, result, input, formats),
            onOpenSession:
                profileCubit.state.permissions.contains(Permission.ownHistory)
                ? (id) => context.pushNamed(
                    RouteNames.sessionChecks,
                    pathParameters: {'id': id},
                  )
                : null,
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.sessionChecks,
        path: RoutePaths.sessionChecks,
        builder: (context, state) {
          final query = CheckQuery(sessionId: state.pathParameters['id']);
          return BlocProvider(
            key: ValueKey(query),
            create: (_) =>
                HistoryBloc(locator<GetChecks>(), initialQuery: query)
                  ..add(HistoryQueryChanged(query)),
            child: HistoryScreen(
              title: AppLocalizations.of(context).sessionChecksTitle,
              top: SessionSummaryCard(
                key: ValueKey(query.sessionId),
                load: () => locator<GetSession>()(query.sessionId!),
              ),
            ),
          );
        },
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
            // The picker reads the official's own history.
            pickCheck:
                profileCubit.state.permissions.contains(Permission.ownHistory)
                ? (context) =>
                      showCheckPicker(context, getChecks: locator<GetChecks>())
                : null,
          ),
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
                  // The tab opens on the camera (final.md Section 13.7).
                  child: VerifyScreen(
                    onOpenProfile: () => context.goNamed(RouteNames.profile),
                    scanner: locator<ScannerService>(),
                    onOpenSettings: locator<PermissionService>().openSettings,
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
                builder: (context, state) {
                  final search = state.uri.queryParameters['search'];
                  final query = CheckQuery(search: search);
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => HistoryBloc(
                          locator<GetChecks>(),
                          initialQuery: query,
                        )..add(HistoryQueryChanged(query)),
                      ),
                      // Loaded when the Sessions view first shows.
                      BlocProvider(
                        create: (_) {
                          final cubit = SessionsCubit(locator());
                          unawaited(cubit.load());
                          return cubit;
                        },
                      ),
                    ],
                    child: HistoryScreen(
                      onSessionsShown: (context) =>
                          unawaited(context.read<SessionsCubit>().load()),
                      sessions: SessionsView(
                        onOpenChecks: (id) => context.pushNamed(
                          RouteNames.sessionChecks,
                          pathParameters: {'id': id},
                        ),
                      ),
                    ),
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
                  ProfileScreen screen({
                    ({Widget card, Future<void> Function() refresh})? totals,
                  }) => ProfileScreen(
                    totals: totals,
                    versionInfo: locator<AppInfoService>().versionInfo(),
                    onChooseLanguage: (code) =>
                        locator<LocaleCubit>().choose(Locale(code)),
                    onChangePassword: () async {
                      final profiles = context.read<ProfileCubit>();
                      final changed = await context.pushNamed<bool>(
                        RouteNames.changePassword,
                      );
                      // After a change the profile is asked for again, so
                      // the Profile reminder goes (final.md Section 13.7).
                      if (changed ?? false) unawaited(profiles.refresh());
                    },
                    onContactSupport: ({email, phone}) {
                      final launcher = locator<LauncherService>();
                      return email != null
                          ? launcher.email(to: email, subject: '', body: '')
                          : launcher.call(phone!);
                    },
                    onLogout: locator<Logout>().call,
                  );
                  // The check counts come from History: only for a profile
                  // that can read it (final.md Section 13.7).
                  final permissions = context
                      .read<ProfileCubit>()
                      .state
                      .permissions;
                  if (!permissions.contains(Permission.ownHistory)) {
                    return screen();
                  }
                  return BlocProvider(
                    create: (_) => CheckTotalsCubit(locator<GetChecks>()),
                    child: Builder(
                      builder: (context) => screen(
                        totals: (
                          card: const CheckTotalsCard(),
                          refresh: context.read<CheckTotalsCubit>().load,
                        ),
                      ),
                    ),
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
    final configuration = router.routerDelegate.currentConfiguration;
    final views = [
      if (configuration.extra is ResultView) configuration.extra! as ResultView,
      ..._matchedResults(configuration.matches),
    ];
    if (denied ||
        views.any((view) => !_allowsResult(view, profile.permissions))) {
      router.go(RoutePaths.home);
    }
  });
  return router;
}

LookupBloc _lookupBloc(GetIt locator) => LookupBloc(
  getFormats: locator<GetFormats>(),
  lookupItem: locator<LookupItem>(),
)..add(const FormatsRequested());

/// Draws nothing and goes to the Check tab after this frame.
class _GoHome extends StatefulWidget {
  const _GoHome();

  @override
  State<_GoHome> createState() => _GoHomeState();
}

class _GoHomeState extends State<_GoHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(RoutePaths.home);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

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

/// What the guard reads from the profile, as one comparable value.
String _guardInput(ProfileState state) {
  // Enum values are not comparable: sort their names.
  final permissions = state.permissions.map((p) => p.name).toList()..sort();
  return '${state.status == ProfileStatus.loaded}|${permissions.join(',')}';
}

bool _allowsResult(ResultView view, Set<Permission> permissions) =>
    permissions.contains(
      view.origin == ResultOrigin.manyItems
          ? Permission.bulkLookup
          : Permission.lookup,
    );
Iterable<ResultView> _matchedResults(List<RouteMatchBase> matches) sync* {
  for (final match in matches) {
    switch (match) {
      case ImperativeRouteMatch(:final matches):
        if (matches.extra is ResultView) yield matches.extra! as ResultView;
        yield* _matchedResults(matches.matches);
      case ShellRouteMatch(:final matches):
        yield* _matchedResults(matches);
      default:
        break;
    }
  }
}
