import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_totals_card.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/profile/presentation/screens/profile_screen.dart';

/// The Profile tab (final.md §13.7).
StatefulShellBranch profileBranch(RouteDeps d) {
  final locator = d.locator;
  return StatefulShellBranch(
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
              // the Profile reminder goes (final.md §13.7).
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
          // that can read it (final.md §13.7).
          final permissions = context.read<ProfileCubit>().state.permissions;
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
  );
}
