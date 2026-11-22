import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';

import '../fakes/scripted_adapter.dart';
import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 1 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): the server's real answers, replayed offline through the
/// app's own client and parsers (TC-STG-001 … -004).
void main() {
  late ScriptedAnswer next;
  late ApiClient api;

  setUp(() {
    final dio = Dio(
      DioFactory.options(
        'https://testapp.protecb.com/v1/clients/ziska-test/',
      ),
    )..httpClientAdapter = ScriptedAdapter((_) async => next);
    api = ApiClient(dio);
  });

  test(
    'TC-STG-001 the public roles are read as the server sends them',
    () async {
      next = stagingScripted('roles_requestable_200.json');
      final roles = await AccessRequestApiService(api).roles();
      expect(
        [for (final r in roles) (r.id, r.name)],
        [
          (2, 'Distributor'),
          (1, 'Retail seller'),
        ],
      );
    },
  );

  test('TC-STG-002 a route that needs a login, without one: "not logged in" '
      'with its reference', () async {
    next = stagingScripted('formats_no_login_401.json');
    await expectLater(
      api.get('formats', skipAuth: true),
      throwsA(
        isA<UnauthenticatedException>()
            .having((e) => e.statusCode, 'status', 401)
            .having((e) => e.code, 'code', 'unauthenticated')
            .having((e) => e.requestId, 'reference', 'req-staging'),
      ),
    );
  });

  test(
    'TC-STG-003 an unknown route: "not available" with its reference',
    () async {
      next = stagingScripted('unknown_route_404.json');
      await expectLater(
        api.get('no-such-route', skipAuth: true),
        throwsA(
          isA<NotFoundException>()
              .having((e) => e.code, 'code', 'not_found')
              .having((e) => e.requestId, 'reference', 'req-staging'),
        ),
      );
    },
  );

  testWidgets("TC-STG-004 Sign up offers the server's roles", (tester) async {
    final app = await startApp(
      tester,
      loggedIn: false,
      overrides: {
        'GET roles/requestable': (_) => stagingScripted(
          'roles_requestable_200.json',
        ),
      },
    );
    await app.tapText('Sign up');
    final picker = find.byType(DropdownButtonFormField<int>);
    expect(picker, findsOneWidget);
    await app.tap(picker);
    expect(find.text('Distributor'), findsWidgets);
    expect(find.text('Retail seller'), findsWidgets);
  });
}
