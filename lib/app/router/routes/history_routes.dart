import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/history/presentation/screens/history_screen.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/session_summary_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_summary_card.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/sessions_view.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// One session's checks, above the tabs (final.md §9, §13.4).
List<RouteBase> historyRoutes(RouteDeps d) {
  final locator = d.locator;
  return [
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
            top: BlocProvider(
              key: ValueKey(query.sessionId),
              create: (_) {
                final cubit = SessionSummaryCubit(
                  () => locator<GetSession>()(query.sessionId!),
                );
                unawaited(cubit.load());
                return cubit;
              },
              child: const SessionSummaryCard(),
            ),
          ),
        );
      },
    ),
  ];
}

/// The History tab: the checks and the sessions (final.md §13.4).
StatefulShellBranch historyBranch(RouteDeps d) {
  final locator = d.locator;
  return StatefulShellBranch(
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
  );
}
