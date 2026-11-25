import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/mappers/retail_user_mappers.dart';
import 'package:ziska_verify/features/retail_users/data/models/retail_user_dtos.dart';
import 'package:ziska_verify/features/retail_users/data/repositories/retail_user_repository_impl.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';

import '../../../fakes/scripted_adapter.dart';

/// TC-REP-073 and -074 (docs/test-cases/07-reports.md): `GET retail-users`
/// becomes the report's retail user picker in
/// `data/mappers/retail_user_mappers.dart` (production audit P-5).
void main() {
  group('TC-REP-073 normal and edge: users as the server sends them', () {
    test('every field; the email stays masked as received', () {
      const dto = RetailUserDto(
        id: 'ru-1',
        name: 'Rahim Store',
        email: 'ra***@gmail.com',
      );
      final user = dto.toEntity();
      expect(user.id, 'ru-1');
      expect(user.name, 'Rahim Store');
      expect(user.maskedEmail, 'ra***@gmail.com');
    });

    test('a page keeps the order, the text and the cursor', () {
      final page = const RetailUsersPageDto(
        retailUsers: [
          RetailUserDto(
            id: 'ru-2',
            name: '  আশা ফার্মেসি ',
            email: 'a***@x.bd',
          ),
          RetailUserDto(id: 'ru-1', name: 'Rahim Store', email: 'r***@y.com'),
        ],
        nextCursor: 'n-2',
      ).toEntity();
      expect(page.items.map((u) => u.id), ['ru-2', 'ru-1']);
      expect(page.items.first.name, '  আশা ফার্মেসি ');
      expect(page.nextCursor, 'n-2');
      expect(page.hasMore, isTrue);
    });

    test('no match: an empty last page', () {
      final page = const RetailUsersPageDto(retailUsers: []).toEntity();
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('TC-REP-074 worst: an unreadable answer fails, never hangs', () {
    late ScriptedAnswer next;
    late RetailUserRepositoryImpl repo;
    setUp(() {
      final dio = Dio(
        DioFactory.options('https://api.example.test/v1/clients/x/'),
      )..httpClientAdapter = ScriptedAdapter((_) async => next);
      repo = RetailUserRepositoryImpl(DioRetailUserApiService(ApiClient(dio)));
    });

    for (final (label, data) in [
      (
        'a user without an email',
        {
          'retail_users': [
            {'id': 'ru-1', 'name': 'Rahim Store'},
          ],
        },
      ),
      (
        'an ID as a number',
        {
          'retail_users': [
            {'id': 1, 'name': 'Rahim Store', 'email': 'r***@y.com'},
          ],
        },
      ),
      ('no list', <String, Object?>{'next_cursor': null}),
    ]) {
      test(label, () async {
        next = ScriptedAnswer(200, okBody(data));
        final result = await repo.search('rahim', const PageRequest());
        expect(result, isA<Err<Object?>>());
        final failure = (result as Err).failure;
        expect(failure.exception, isA<InternalErrorException>());
        expect(failure.exception.reason, CoreReason.answerShape);
      });
    }
  });
}
