import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

import '../../fakes/scripted_adapter.dart';

Matcher _shape(ApiAnswer answer) => isA<InternalErrorException>()
    .having((e) => e.reason, 'reason', answer)
    .having((e) => e.message, 'message', isNull);

/// TC-ARCH-032 … -034 (docs/test-cases/18-architecture.md): every service
/// reads the `data` of an answer through `ApiData`, and a wrong shape is an
/// `InternalErrorException` whose `reason` names the answer (production
/// audit P-19, P-24).
void main() {
  group('TC-ARCH-032 normal: the documented shape passes through', () {
    test('a map', () {
      final data = <String, dynamic>{'id': 7, 'name': 'x'};
      expect(ApiData.map(data, ApiAnswer.me), same(data));
    });

    test('a list of maps', () {
      final data = <Object?>[
        <String, dynamic>{'id': 3},
      ];
      expect(ApiData.list(data, ApiAnswer.accessRoles), [
        {'id': 3},
      ]);
    });

    test('a whole-number field', () {
      expect(ApiData.intField({'id': 1042}, 'id', ApiAnswer.incidentId), 1042);
    });
  });

  group('TC-ARCH-033 edge: empty answers', () {
    test('an empty map and an empty list', () {
      expect(ApiData.map(<String, dynamic>{}, ApiAnswer.me), isEmpty);
      expect(ApiData.list(<Object?>[], ApiAnswer.accessRoles), isEmpty);
    });

    test('a list whose items are not maps is left to the parser', () {
      // The parser reports it as a TypeError, which `guard` turns into
      // `answer_shape` (TC-AUTH-120).
      final list = ApiData.list(<Object?>['x'], ApiAnswer.accessRoles);
      expect(() => list.first, throwsA(isA<TypeError>()));
    });

    test('a field of 0 is a number', () {
      expect(ApiData.intField({'n': 0}, 'n', ApiAnswer.incidentN), 0);
    });
  });

  group('TC-ARCH-034 worst: a wrong shape names its answer', () {
    for (final (label, data) in <(String, Object?)>[
      ('nothing', null),
      ('text', 'ok'),
      ('a number', 1),
      ('a list', <Object?>[]),
      ('a map with other keys', <String, Object?>{'id': 1}),
    ]) {
      test('$label where a map is expected', () {
        if (data is Map<String, dynamic>) return; // the one right shape
        expect(
          () => ApiData.map(data, ApiAnswer.me),
          throwsA(_shape(ApiAnswer.me)),
        );
      });
      test('$label where a list is expected', () {
        if (data is List) return;
        expect(
          () => ApiData.list(data, ApiAnswer.accessRoles),
          throwsA(_shape(ApiAnswer.accessRoles)),
        );
      });
    }

    test('a field missing, as text, as a fraction or not in a map', () {
      for (final data in <Object?>[
        <String, dynamic>{},
        <String, dynamic>{'id': '1042'},
        <String, dynamic>{'id': 1.5},
        <String, dynamic>{'id': null},
        <Object?>[1042],
        null,
      ]) {
        expect(
          () => ApiData.intField(data, 'id', ApiAnswer.incidentId),
          throwsA(_shape(ApiAnswer.incidentId)),
          reason: '$data',
        );
      }
    });

    group('each service keeps its name, which the app acts on', () {
      late Object? answer;
      late ApiClient api;
      setUp(() {
        answer = 'not the documented shape';
        api = ApiClient(
          Dio(DioFactory.options('https://api.example.test/v1/clients/x/'))
            ..httpClientAdapter = ScriptedAdapter(
              (_) async => ScriptedAnswer(200, okBody(answer)),
            ),
        );
      });

      const page = PageRequest();
      final calls = <(ApiAnswer, Future<Object?> Function(ApiClient))>[
        (
          ApiAnswer.auth,
          (a) => DioAuthApiService(
            a,
          ).login(email: 'nobody@example.com', password: 'x', phoneId: 'p'),
        ),
        (
          ApiAnswer.auth,
          (a) => DioAuthApiService(
            a,
          ).verifyPhone(challengeId: 'c', code: '1', phoneId: 'p'),
        ),
        (
          ApiAnswer.auth,
          (a) => DioAuthApiService(
            a,
          ).changePassword(oldPassword: 'x', newPassword: 'y'),
        ),
        (
          ApiAnswer.accessRoles,
          (a) => DioAccessRequestApiService(a).roles(),
        ),
        (
          ApiAnswer.accessPending,
          (a) => DioAccessRequestApiService(a).submit(
            const AccessRequest(
              email: 'nobody@example.com',
              code: '1',
              name: 'n',
              roleId: 1,
              password: 'x',
            ),
          ),
        ),
        (ApiAnswer.me, (a) => DioProfileApiService(a).getMe()),
        (
          ApiAnswer.checks,
          (a) => DioHistoryApiService(a).getChecks(const CheckQuery(), page),
        ),
        (
          ApiAnswer.incidentId,
          (a) => DioIncidentApiService(a).fileReport(note: 'n'),
        ),
        (
          ApiAnswer.incidentN,
          (a) => DioIncidentApiService(
            a,
          ).addPhoto(1, Uint8List(1), 'image/jpeg'),
        ),
        (ApiAnswer.reports, (a) => DioIncidentApiService(a).myReports(page)),
        (
          ApiAnswer.retailUsers,
          (a) => DioRetailUserApiService(a).search(null, page),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(a).getFormats(),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(a).lookup(way: 'qr', value: 'v'),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(a).scan('v', 's'),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(a).serials(['v']),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(a).session('s'),
        ),
        (
          ApiAnswer.verification,
          (a) => DioVerificationApiService(
            a,
          ).sessions(const SessionQuery(), page),
        ),
      ];
      for (final (i, (name, call)) in calls.indexed) {
        test('${i + 1}. ${name.name}', () async {
          await expectLater(call(api), throwsA(_shape(name)));
          // The other container: a map for the one route that answers a
          // list, a list for the rest.
          answer = name == ApiAnswer.accessRoles
              ? <String, Object?>{}
              : <Object?>[];
          await expectLater(call(api), throwsA(_shape(name)));
        });
      }
    });

    test('no service checks the shape by itself', () {
      final services = Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('_api_service.dart'));
      expect(services, hasLength(7));
      for (final file in [
        ...services,
        File('lib/core/network/dio_session_service.dart'),
      ]) {
        // `is Map…`, `is! Map…`, `is List`, `is! List`: the answer's
        // container checked by hand instead of by `ApiData`.
        expect(
          file.readAsStringSync(),
          isNot(matches(RegExp(r'\bis!? (Map|List)\b'))),
          reason: file.path,
        );
      }
    });
  });
}
