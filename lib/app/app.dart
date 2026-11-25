import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/router/app_router.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/session/forbidden_signal.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/features/profile/domain/usecases/get_profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/theme/app_theme.dart';
import 'package:ziska_verify/shared/widgets/network_status_banner.dart';

/// The root widget: the app-scoped profile (final.md §11), the
/// router (§9), the theme (§14), and the chosen language
/// (§16), applied at once.
class App extends StatefulWidget {
  const App({required this.locator, super.key});

  final GetIt locator;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _official;
  StreamSubscription<ProfileState>? _profileChanges;
  StreamSubscription<SessionState>? _sessionChanges;
  void _clearRecovery(String official) {
    unawaited(
      ActiveScanStore(
        widget.locator<SecureStorageService>(),
        client: widget.locator<AppConfig>().clientSlug,
        official: official,
      ).clear().catchError((Object _) {}),
    );
  }

  @override
  void initState() {
    super.initState();
    _profileChanges = _profile.stream.listen((state) {
      final id = state.profile?.id;
      if (id != null && id != _official) {
        if (_official != null) _clearRecovery(_official!);
        _official = id;
      }
    });
    _sessionChanges = widget.locator<SessionService>().states.listen((state) {
      if (state is SessionUnauthenticated && _official != null) {
        _clearRecovery(_official!);
        _official = null;
      }
    });
  }

  late final ProfileCubit _profile = ProfileCubit(
    widget.locator<GetProfile>(),
    widget.locator<SessionService>(),
    forbidden: widget.locator<ForbiddenSignal>().stream,
  );
  late final AppRouter _router = buildRouter(
    locator: widget.locator,
    profileCubit: _profile,
  );

  @override
  void dispose() {
    unawaited(_profileChanges?.cancel());
    unawaited(_sessionChanges?.cancel());
    _router.dispose();
    unawaited(_profile.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = widget.locator<AppConfig>().flavor;
    return BlocProvider.value(
      value: _profile,
      child: BlocBuilder<LocaleCubit, Locale>(
        bloc: widget.locator<LocaleCubit>(),
        builder: (context, locale) => MaterialApp.router(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: flavor != AppFlavor.live,
          theme: AppTheme.light(),
          routerConfig: _router.config,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          // The offline banner above every screen (final.md §14.2).
          // Dark status bar icons where a screen says nothing (a white
          // top); navy screens and app bars set their own (finding F-7).
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: NetworkStatusShell(
              connectivity: widget.locator<ConnectivityService>(),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
