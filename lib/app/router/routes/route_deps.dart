import 'package:get_it/get_it.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';

/// What every route group needs: the service locator (used only in `app/`,
/// final.md §11), the app-wide profile and the session.
class RouteDeps {
  const RouteDeps({
    required this.locator,
    required this.profileCubit,
    required this.session,
  });

  final GetIt locator;
  final ProfileCubit profileCubit;
  final SessionService session;
}
