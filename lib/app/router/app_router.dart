import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/app_navigation_observer.dart';
import 'package:ziska_verify/app/router/route_guard.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/router_refresh.dart';
import 'package:ziska_verify/app/router/routes/auth_routes.dart';
import 'package:ziska_verify/app/router/routes/check_routes.dart';
import 'package:ziska_verify/app/router/routes/history_routes.dart';
import 'package:ziska_verify/app/router/routes/profile_routes.dart';
import 'package:ziska_verify/app/router/routes/report_routes.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/app/shell/main_shell.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';

/// Builds the app's single `GoRouter` (final.md §9): the guard, the
/// check of pushed pages, and the route groups. Each area's routes, the
/// only code that imports feature screens, are in `routes/`.
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

  final deps = RouteDeps(
    locator: locator,
    profileCubit: profileCubit,
    session: session,
  );

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
      ...authRoutes(deps),
      ...checkRoutes(deps),
      ...historyRoutes(deps),
      ...reportRoutes(deps),
      // The three tabs of the bottom navigation (final.md §9).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          checkBranch(deps),
          historyBranch(deps),
          profileBranch(deps),
        ],
      ),
    ],
  );

  // go_router runs the redirect on the base location only, so a pushed
  // screen whose permission was just lost (a `403 forbidden` reload,
  // final.md §7, §9) is checked here: the official goes Home.
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
        views.any((view) => !allowsResult(view, profile.permissions))) {
      router.go(RoutePaths.home);
    }
  });
  return router;
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
