import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/router/app_router.dart';
import 'package:ziska_verify/core/services/session/forbidden_signal.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/features/profile/domain/usecases/get_profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/theme/app_theme.dart';

/// The root widget: the app-scoped profile (final.md Section 5.9), the
/// router (Section 9), the theme (Section 14), and localization (Section 16).
class App extends StatefulWidget {
  const App({required this.locator, super.key});

  final GetIt locator;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ProfileCubit _profile = ProfileCubit(
    widget.locator<GetProfile>(),
    widget.locator<SessionService>(),
    forbidden: widget.locator<ForbiddenSignal>().stream,
  );
  late final GoRouter _router = buildRouter(
    locator: widget.locator,
    profileCubit: _profile,
  );

  @override
  void dispose() {
    _router.dispose();
    unawaited(_profile.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = widget.locator<AppConfig>().flavor;
    return BlocProvider.value(
      value: _profile,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: flavor != AppFlavor.live,
        theme: AppTheme.light(),
        routerConfig: _router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
