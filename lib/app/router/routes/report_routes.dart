import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/routes/route_deps.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/history/domain/usecases/check_usecases.dart';
import 'package:ziska_verify/features/history/presentation/widgets/check_picker_sheet.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/my_reports_screen.dart';
import 'package:ziska_verify/features/incidents/presentation/screens/report_incident_screen.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/retail_user_usecases.dart';
import 'package:ziska_verify/features/retail_users/presentation/widgets/retail_user_picker_sheet.dart';

/// My reports and a new report, above the tabs (final.md §9, §13.5).
List<RouteBase> reportRoutes(RouteDeps d) {
  final locator = d.locator;
  final profileCubit = d.profileCubit;
  return [
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
  ];
}
