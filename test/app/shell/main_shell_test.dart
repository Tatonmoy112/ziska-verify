import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/app/router/route_guard.dart';
import 'package:ziska_verify/app/shell/main_shell.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/domain/repositories/profile_repository.dart';
import 'package:ziska_verify/features/profile/domain/usecases/get_profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

import '../../fakes/fake_session_service.dart';

class _MockProfileRepo extends Mock implements ProfileRepository {}

Profile _profile(Set<Permission> permissions) => Profile(
  id: '1',
  name: 'Asha Rao',
  email: 'a@b.c',
  role: 'Inspector',
  permissions: permissions,
  mustChangePassword: false,
);

void main() {
  Future<void> pumpShell(
    WidgetTester tester,
    Set<Permission> permissions,
  ) async {
    final repo = _MockProfileRepo();
    when(
      repo.getProfile,
    ).thenAnswer((_) async => Success(_profile(permissions)));
    final cubit = ProfileCubit(
      GetProfile(repo),
      FakeSessionService(const SessionAuthenticated()),
    );
    addTearDown(cubit.close);
    await tester.pump();

    Widget page(String text) => Scaffold(body: Text(text));
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => MainShell(navigationShell: shell),
          branches: [
            for (final path in ['/home', '/history', '/profile'])
              StatefulShellBranch(
                routes: [GoRoute(path: path, builder: (_, _) => page(path))],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows all three tabs with history permission', (tester) async {
    await pumpShell(tester, {Permission.lookup, Permission.ownHistory});
    for (final label in ['Check', 'History', 'Profile']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('hides History without history permission', (
    tester,
  ) async {
    await pumpShell(tester, {Permission.lookup});
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('tapping a tab switches to it', (tester) async {
    await pumpShell(tester, {Permission.ownHistory});
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('/history'), findsOneWidget);
  });

  test('the guard sends /history to Home without permission', () {
    final guard = RouteGuard(permissionByPath: tabPermissionByPath);
    String? go(String path, Set<Permission> p) => guard.redirect(
      session: const SessionAuthenticated(),
      profileLoaded: true,
      permissions: p,
      location: path,
    );
    expect(go('/history', {}), '/home');
    expect(go('/history', {Permission.lookup}), '/home');
    expect(go('/history', {Permission.ownHistory}), isNull);
    expect(go('/profile', {}), isNull);
  });
}
