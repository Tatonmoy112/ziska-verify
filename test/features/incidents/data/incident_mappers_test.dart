import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/data/mappers/incident_mappers.dart';
import 'package:ziska_verify/features/incidents/data/models/incident_dtos.dart';
import 'package:ziska_verify/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';

import '../../../fakes/scripted_adapter.dart';

/// TC-REP-070 … -072 (docs/test-cases/07-reports.md): `GET incidents`
/// becomes the official's reports in `data/mappers/incident_mappers.dart`
/// (production audit P-5).
void main() {
  ReportDto report({
    int id = 1042,
    String at = '2026-11-24T04:30:00Z',
    String note = 'Seal broken',
    int photos = 2,
    String? checkRef = 'MA-2026-000123',
    ReportRetailUserDto? retailUser = const ReportRetailUserDto(
      id: 'ru-1',
      name: 'Rahim Store',
    ),
  }) => ReportDto(
    id: id,
    at: at,
    note: note,
    photos: photos,
    checkRef: checkRef,
    retailUser: retailUser,
  );

  group('TC-REP-070 normal: a report and a page', () {
    test('every field of a report', () {
      final r = report().toEntity();
      expect(r.id, 1042);
      expect(r.at, DateTime.utc(2026, 11, 24, 4, 30));
      expect(r.at.isUtc, isTrue);
      expect(r.note, 'Seal broken');
      expect(r.photos, 2);
      expect(r.checkRef, 'MA-2026-000123');
      expect(r.retailUserName, 'Rahim Store');
    });

    test('a page keeps the order and the cursor as given', () {
      final page = ReportsPageDto(
        reports: [report(), report(id: 7), report(id: 9001)],
        nextCursor: 'c-9',
      ).toEntity();
      expect(page.items.map((r) => r.id), [1042, 7, 9001]);
      expect(page.nextCursor, 'c-9');
      expect(page.hasMore, isTrue);
    });
  });

  group('TC-REP-071 edge: optional fields, times and text', () {
    test('no check and no retail user', () {
      final r = report(checkRef: null, retailUser: null).toEntity();
      expect(r.checkRef, isNull);
      expect(r.retailUserName, isNull);
    });

    test('no photos', () {
      expect(report(photos: 0).toEntity().photos, 0);
    });

    test('a time with an offset is the same moment in UTC', () {
      final r = report(at: '2026-11-24T10:30:00+06:00').toEntity();
      expect(r.at, DateTime.utc(2026, 11, 24, 4, 30));
      expect(r.at.isUtc, isTrue);
    });

    test('fractions of a second are kept', () {
      final r = report(at: '2026-11-24T04:30:00.123456Z').toEntity();
      expect(r.at, DateTime.utc(2026, 11, 24, 4, 30, 0, 123, 456));
    });

    test('the note as written: Bangla, an emoji, lines, spaces', () {
      const note = '  সিল ভাঙা 👎\nsecond line  ';
      expect(report(note: note).toEntity().note, note);
    });

    test('an empty last page', () {
      final page = const ReportsPageDto(reports: []).toEntity();
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });
  });

  group('TC-REP-072 worst: an unreadable answer fails, never hangs', () {
    test('the mapper refuses a time that is not one', () {
      expect(
        () => report(at: 'yesterday').toEntity(),
        throwsFormatException,
      );
    });

    late ScriptedAdapter adapter;
    late ScriptedAnswer next;
    late IncidentRepositoryImpl repo;
    setUp(() {
      adapter = ScriptedAdapter((_) async => next);
      final dio = Dio(
        DioFactory.options('https://api.example.test/v1/clients/x/'),
      )..httpClientAdapter = adapter;
      repo = IncidentRepositoryImpl(DioIncidentApiService(ApiClient(dio)));
    });

    Map<String, Object?> reportJson(Map<String, Object?> change) => {
      'id': 1042,
      'at': '2026-11-24T04:30:00Z',
      'note': 'Seal broken',
      'photos': 2,
      ...change,
    };

    for (final (label, data) in [
      (
        'a time that is not one',
        {
          'reports': [
            reportJson({'at': 'yesterday'}),
          ],
        },
      ),
      (
        'photos as text',
        {
          'reports': [
            reportJson({'photos': '2'}),
          ],
        },
      ),
      (
        'a report without its note',
        {
          'reports': [
            reportJson({})..remove('note'),
          ],
        },
      ),
      ('no reports list', <String, Object?>{'next_cursor': null}),
    ]) {
      test(label, () async {
        next = ScriptedAnswer(200, okBody(data));
        final result = await repo.myReports(const PageRequest());
        expect(result, isA<Err<Object?>>());
        final failure = (result as Err).failure;
        expect(failure.exception, isA<InternalErrorException>());
        expect(failure.exception.reason, CoreReason.answerShape);
      });
    }
  });
}
