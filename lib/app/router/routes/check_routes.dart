import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/serial_stack_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/lookup_result_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/scan_session_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/serial_stack_screen.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verify_screen.dart';

/// The result page, scanner mode and the serial stack: lookup flows that
/// open above the bottom bar (final.md Section 9.2).
List<RouteBase> checkRoutes(RouteDeps d) {
  final locator = d.locator;
  final profileCubit = d.profileCubit;
  final session = d.session;

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

  return [
    GoRoute(
      name: RouteNames.lookupResult,
      path: RoutePaths.lookupResult,
      // Without its result (the system restored the app) it goes back to
      // the Check tab (final.md Section 9.5).
      redirect: (_, state) {
        final view = state.extra;
        return view is ResultView &&
                allowsResult(view, profileCubit.state.permissions)
            ? null
            : RoutePaths.home;
      },
      builder: (context, state) {
        final view = state.extra;
        if (view is! ResultView ||
            !allowsResult(view, profileCubit.state.permissions)) {
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
          // The report carries this check's reference (Section 13.5).
          onReport: (checkRef) => context.pushNamed<void>(
            RouteNames.reportIncident,
            queryParameters: {'check_ref': checkRef},
          ),
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
  ];
}

/// The Check tab: the camera and the serial field (final.md §13.10).
StatefulShellBranch checkBranch(RouteDeps d) {
  final locator = d.locator;
  return StatefulShellBranch(
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: RoutePaths.home,
        builder: (context, _) => BlocProvider(
          create: (_) => _lookupBloc(locator),
          // The tab opens on the camera (final.md Section 13.7).
          child: VerifyScreen(
            onOpenProfile: () => context.goNamed(RouteNames.profile),
            onNewReport: () =>
                context.pushNamed<void>(RouteNames.reportIncident),
            onMyReports: () => context.pushNamed<void>(RouteNames.myReports),
            scanner: locator<ScannerService>(),
            onOpenSettings: locator<PermissionService>().openSettings,
          ),
        ),
      ),
    ],
  );
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

/// Whether [permissions] allow [view]: a result of scanner mode or a
/// stack needs `item:bulk_lookup`, one item `item:lookup`.
bool allowsResult(ResultView view, Set<Permission> permissions) =>
    permissions.contains(
      view.origin == ResultOrigin.manyItems
          ? Permission.bulkLookup
          : Permission.lookup,
    );
