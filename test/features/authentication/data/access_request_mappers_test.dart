import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/mappers/access_request_mappers.dart';
import 'package:ziska_verify/features/authentication/data/models/access_request_dtos.dart';
import 'package:ziska_verify/features/authentication/data/repositories/access_request_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';

import '../../../fakes/scripted_adapter.dart';

/// TC-AUTH-119 and -120 (docs/test-cases/01-auth.md): `GET
/// roles/requestable` becomes the roles of Request access in
/// `data/mappers/access_request_mappers.dart` (production audit P-5).
void main() {
  group('TC-AUTH-119 normal and edge: the roles as the server sends them', () {
    test('ID and name', () {
      final role = const RequestableRoleDto(
        id: 3,
        name: 'Field inspector',
      ).toEntity();
      expect(role.id, 3);
      expect(role.name, 'Field inspector');
    });

    test('a list keeps its order, its names and its repeats', () {
      final roles = const [
        RequestableRoleDto(id: 7, name: 'খুচরা বিক্রেতা'),
        RequestableRoleDto(id: 3, name: 'Field inspector'),
        RequestableRoleDto(id: 3, name: 'Field inspector'),
      ].toEntities();
      expect(roles.map((r) => r.id), [7, 3, 3]);
      expect(roles.first.name, 'খুচরা বিক্রেতা');
    });

    test('no role to ask for: an empty list', () {
      expect(const <RequestableRoleDto>[].toEntities(), isEmpty);
    });
  });

  group('TC-AUTH-120 worst: an unreadable answer fails, never hangs', () {
    late ScriptedAnswer next;
    late AccessRequestRepositoryImpl repo;
    setUp(() {
      final dio = Dio(
        DioFactory.options('https://api.example.test/v1/clients/x/'),
      )..httpClientAdapter = ScriptedAdapter((_) async => next);
      repo = AccessRequestRepositoryImpl(
        AccessRequestApiService(ApiClient(dio)),
      );
    });

    for (final (label, data, message) in [
      (
        'an ID as text',
        [
          {'id': '3', 'name': 'Field inspector'},
        ],
        'answer_shape',
      ),
      (
        'a role without a name',
        [
          {'id': 3},
        ],
        'answer_shape',
      ),
      (
        'a role that is not an object',
        ['Field inspector'],
        'answer_shape',
      ),
      // The service's own check: the list is not a list.
      ('not a list', {'roles': <Object?>[]}, 'access_roles_shape'),
    ]) {
      test(label, () async {
        next = ScriptedAnswer(200, okBody(data));
        final result = await repo.roles();
        expect(result, isA<Err<Object?>>());
        final failure = (result as Err).failure;
        expect(failure.exception, isA<InternalErrorException>());
        expect(failure.exception.message, message);
      });
    }
  });
}
