import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/router/route_guard.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

void main() {
  const guard = RouteGuard(
    permissionByPath: {'/home/lookup': _canLookup},
  );

  String? go(
    SessionState? session,
    String location, {
    bool profileLoaded = true,
    Set<Permission> permissions = const {},
  }) => guard.redirect(
    session: session,
    profileLoaded: profileLoaded,
    permissions: permissions,
    location: location,
  );

  const out = SessionUnauthenticated();
  const code = SessionAwaitingCode(challengeId: 'c', email: 'a@b.c');
  const change = SessionPasswordChangeRequired();
  const inside = SessionAuthenticated();

  // One case per row of final.md §9.
  // TC-NAV-003: Every session state has its screen.
  test('start-up goes to Splash', () {
    expect(go(null, RoutePaths.home), RoutePaths.splash);
    expect(go(null, RoutePaths.splash), isNull);
  });

  test('logged out: pre-login routes stay, the rest go to Login', () {
    for (final path in RoutePaths.preLogin) {
      expect(go(out, path), isNull, reason: path);
    }
    expect(go(out, RoutePaths.home), RoutePaths.login);
    expect(go(out, RoutePaths.splash), RoutePaths.login);
    expect(go(out, RoutePaths.verifyCode), RoutePaths.login);
  });

  test('awaiting the code: only Verify code', () {
    expect(go(code, RoutePaths.verifyCode), isNull);
    expect(go(code, RoutePaths.login), RoutePaths.verifyCode);
    expect(go(code, RoutePaths.home), RoutePaths.verifyCode);
  });

  // TC-AUTH-013: Forced password change is the only screen.
  test('password change required: only Change password', () {
    expect(go(change, RoutePaths.changePassword), isNull);
    expect(go(change, RoutePaths.home), RoutePaths.changePassword);
    expect(go(change, RoutePaths.login), RoutePaths.changePassword);
  });

  test('logged in, profile not loaded: Splash', () {
    expect(
      go(inside, RoutePaths.home, profileLoaded: false),
      RoutePaths.splash,
    );
  });

  test('logged in: Splash and pre-login routes go Home', () {
    expect(go(inside, RoutePaths.splash), RoutePaths.home);
    expect(go(inside, RoutePaths.login), RoutePaths.home);
    expect(go(inside, RoutePaths.verifyCode), RoutePaths.home);
    expect(go(inside, RoutePaths.home), isNull);
    expect(go(inside, RoutePaths.changePassword), isNull);
  });

  // TC-NAV-002: A route without its permission goes Home.
  test('logged in: a route without its permission goes Home', () {
    expect(go(inside, '/home/lookup'), RoutePaths.home);
    expect(
      go(inside, '/home/lookup', permissions: {Permission.lookup}),
      isNull,
    );
  });
}

bool _canLookup(Set<Permission> p) => p.contains(Permission.lookup);
