import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/data/repositories/access_request_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/failure_reasons.dart';

class _Incidents extends Mock implements IncidentApiService {}

class _Access extends Mock implements AccessRequestApiService {}

const _request = AccessRequest(
  email: 'person@example.com',
  code: '123456',
  name: 'Rahim Store',
  roleId: 7,
  password: 'x',
);

NotFoundException _gone(String? message) => NotFoundException(
  statusCode: 404,
  code: 'not_found',
  message: message,
  requestId: 'req-7',
);

/// TC-REP-075 … -077 (docs/test-cases/07-reports.md): what a 404 says is
/// gone is read once, in the repository, into a typed reason; presentation
/// never reads the server's text (production audit P-25).
void main() {
  setUpAll(() {
    registerFallbackValue(_request);
  });

  late _Incidents api;
  late IncidentRepositoryImpl repo;
  setUp(() {
    api = _Incidents();
    repo = IncidentRepositoryImpl(api);
  });

  /// Files a report with the links given, answered 404 [message].
  Future<NotFoundException> file(
    String? message, {
    bool check = false,
    bool retail = false,
  }) async {
    when(
      () => api.fileReport(
        note: any(named: 'note'),
        checkRef: any(named: 'checkRef'),
        retailUserId: any(named: 'retailUserId'),
      ),
    ).thenThrow(_gone(message));
    final result = await repo.fileReport(
      note: 'Seal is cut',
      checkRef: check ? 'MA-2026-000123' : null,
      retailUserId: retail ? 'r1' : null,
    );
    return (result as Err).failure.exception as NotFoundException;
  }

  group('TC-REP-075 normal: the guide texts name what is gone', () {
    test('"Check not found." and "Retail user not found."', () async {
      final check = await file('Check not found.', check: true, retail: true);
      expect(check.reason, IncidentReason.checkGone);
      final retail = await file(
        'Retail user not found.',
        check: true,
        retail: true,
      );
      expect(retail.reason, IncidentReason.retailUserGone);
    });

    test('everything else of the answer is kept', () async {
      final e = await file('Check not found.', check: true);
      expect(e.statusCode, 404);
      expect(e.code, 'not_found');
      expect(e.message, 'Check not found.');
      expect(e.requestId, 'req-7');
    });

    test('"Role not found." on Request access', () async {
      final access = _Access();
      when(
        () => access.submit(any()),
      ).thenThrow(_gone('Role not found.'));
      final result = await AccessRequestRepositoryImpl(access).submit(_request);
      expect(
        (result as Err).failure.exception.reason,
        AuthReason.roleGone,
      );
    });
  });

  group('TC-REP-076 edge: other spellings, and the one link sent', () {
    test('case and spaces as a proxy may change them', () async {
      expect(
        (await file(
          '  RETAIL USER not found. ',
          check: true,
          retail: true,
        )).reason,
        IncidentReason.retailUserGone,
      );
      expect(
        (await file('check NOT FOUND', check: true, retail: true)).reason,
        IncidentReason.checkGone,
      );
    });

    test('a text naming neither: the one link that was sent', () async {
      expect(
        (await file(null, check: true)).reason,
        IncidentReason.checkGone,
      );
      expect(
        (await file('Not found.', retail: true)).reason,
        IncidentReason.retailUserGone,
      );
    });
  });

  group('TC-REP-077 worst: never a wrong link taken off', () {
    test('a text naming neither, with both links or none', () async {
      expect((await file(null, check: true, retail: true)).reason, isNull);
      expect((await file('Not found.')).reason, isNull);
      expect((await file('')).reason, isNull);
    });

    test('another 404 on Request access is not the role', () async {
      final access = _Access();
      when(() => access.submit(any())).thenThrow(_gone('Not found.'));
      final result = await AccessRequestRepositoryImpl(access).submit(_request);
      expect((result as Err).failure.exception.reason, isNull);
    });

    test('a failure that is not a 404 is left as it is', () async {
      when(
        () => api.fileReport(
          note: any(named: 'note'),
          checkRef: any(named: 'checkRef'),
          retailUserId: any(named: 'retailUserId'),
        ),
      ).thenThrow(
        const ConflictException(statusCode: 409, message: 'Check is busy'),
      );
      final result = await repo.fileReport(note: 'n', checkRef: 'c');
      final e = (result as Err).failure.exception;
      expect(e, isA<ConflictException>());
      expect(e.reason, isNull);
    });

    test('presentation never decides on the server text', () {
      final decides = RegExp(r'message\??\.(toLowerCase|contains|startsWith)');
      final files = Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.replaceAll(r'\', '/').contains('/presentation/') &&
                f.path.endsWith('.dart') &&
                !f.path.endsWith('.freezed.dart'),
          );
      for (final file in files) {
        expect(
          file.readAsStringSync(),
          isNot(matches(decides)),
          reason: file.path,
        );
      }
    });
  });
}
