import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/retail_users/data/repositories/retail_user_repository_impl.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';

import '../../fakes/postman_examples.dart';
import '../../fakes/scripted_adapter.dart';

/// Reports, photos, and the retail user picker against the backend's
/// Postman examples (final.md §13.5, §13.6, §18).
void main() {
  late ScriptedAdapter adapter;
  late ApiClient api;
  late ScriptedAnswer next;

  setUp(() {
    adapter = ScriptedAdapter((_) async => next);
    final dio = Dio(
      DioFactory.options('https://api.example.test/v1/clients/x/'),
    )..httpClientAdapter = adapter;
    api = ApiClient(dio);
  });

  IncidentRepositoryImpl reports() =>
      IncidentRepositoryImpl(DioIncidentApiService(api));

  ScriptedAnswer example(int status, String request, String name) =>
      ScriptedAnswer(status, postmanExample(request: request, example: name));

  test('filing sends the note and leaves out unused fields', () async {
    next = example(201, 'File a report', '201 Filed');
    final result = await reports().fileReport(note: 'Seal is cut');
    expect((result as Success<int>).value, 1042);
    expect(adapter.requests.single.path, 'incidents');
    expect(adapter.requests.single.data, {'note': 'Seal is cut'});
  });

  test('filing with a check and a retail user', () async {
    next = example(201, 'File a report', '201 Filed');
    await reports().fileReport(
      note: 'N',
      checkRef: 'MA-2026-000123',
      retailUserId: '9d2e',
    );
    expect(adapter.requests.single.data, {
      'note': 'N',
      'check_ref': 'MA-2026-000123',
      'retail_user_id': '9d2e',
    });
  });

  test('a photo is the raw file with its type and length', () async {
    next = example(
      201,
      'Add a photo to the report',
      '201 Uploaded as photo 1',
    );
    final bytes = Uint8List.fromList(List.filled(1234, 7));
    final result = await reports().addPhoto(
      1042,
      bytes,
      contentType: 'image/jpeg',
    );
    expect((result as Success<int>).value, 1);
    final request = adapter.requests.single;
    expect(request.path, 'incidents/1042/photos');
    expect(request.contentType, 'image/jpeg');
    expect(request.headers[Headers.contentLengthHeader], 1234);
  });

  test('409 after the hour is a conflict', () async {
    next = example(
      409,
      'Add a photo to the report',
      '409 More than an hour after the report',
    );
    final result = await reports().addPhoto(
      1042,
      Uint8List(1),
      contentType: 'image/jpeg',
    );
    expect(
      (result as Err<int>).failure.exception,
      isA<ConflictException>(),
    );
  });

  test('My reports: the list key is reports', () async {
    next = example(200, 'My own reports', '200 The reports');
    final result = await reports().myReports(const PageRequest());
    final page = (result as Success<CursorPage<Report>>).value;
    final report = page.items.single;
    expect(report.id, 1042);
    expect(report.photos, 2);
    expect(report.checkRef, 'MA-2026-000123');
    expect(report.retailUserName, 'Rahim Store');
    expect(page.hasMore, isFalse);
  });

  test('retail user picker: masked emails as received', () async {
    next = example(200, 'Pick a retail user', '200 The retail users');
    final repo = RetailUserRepositoryImpl(DioRetailUserApiService(api));
    final result = await repo.search('rahim', const PageRequest());
    final user = (result as Success<CursorPage<RetailUser>>).value.items.single;
    expect(user.name, 'Rahim Store');
    expect(user.maskedEmail, 'ra***@gmail.com');
    expect(adapter.requests.single.queryParameters, {
      'search': 'rahim',
      'limit': 50,
    });
  });
}
