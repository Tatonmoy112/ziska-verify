import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

import '../fakes/staging_fixtures.dart';
import '../flow/harness.dart';

/// Step 8 of the test-server integration (docs/staging-integration-
/// 2026-11-22.md): reports, photos and retail users, on the server's real
/// answers replayed offline (TC-STG-041 … -045).
void main() {
  Answer real(String name) =>
      (_) => stagingScripted(name);

  /// The real server: report 3 filed; its photos; the reports; no retail
  /// users.
  Map<String, Answer> server([Map<String, Answer> more = const {}]) => {
    'POST incidents': real('report_filed_201.json'),
    'POST incidents/3/photos': real('photo_first_201.json'),
    'GET incidents': real('reports_200.json'),
    'GET retail-users': real('retail_users_empty_200.json'),
    ...more,
  };

  Future<FlowApp> open(
    WidgetTester tester,
    Key tool, [
    Map<String, Answer> more = const {},
  ]) async {
    final app = await startApp(tester, overrides: server(more));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    await app.tap(find.byKey(tool));
    return app;
  }

  Future<void> fileWithPhoto(FlowApp app, String note) async {
    await app.enter(const Key('report.note'), note);
    await app.tap(find.byKey(const Key('report.addPhoto')));
    await app.tapText('Choose from gallery');
    await app.tap(find.byKey(const Key('report.submit')));
  }

  testWidgets('TC-STG-041 a report and its photo on the real answers', (
    tester,
  ) async {
    final app = await open(tester, const Key('verify.tool.report'));
    await fileWithPhoto(app, '  Seal cut.\n');
    expect(app.backend.sent('POST', 'incidents').single.data, {
      'note': 'Seal cut.',
    });
    expect(find.text('Report 3 filed.'), findsOneWidget);
    expect(find.text('Photo 1'), findsOneWidget);
    final photo = app.backend.sent('POST', 'incidents/3/photos').single;
    expect(photo.contentType, 'image/jpeg');
  });

  for (final (fixture, text) in [
    (
      'report_unknown_check_404.json',
      'The check was not found. Remove it and try again.',
    ),
    (
      'report_unknown_retail_user_404.json',
      'This retail user can no longer be named. Choose another, or file '
          'without one.',
    ),
  ]) {
    testWidgets('TC-STG-042 the real 404 on filing names what is gone: '
        '$fixture', (tester) async {
      final app = await open(tester, const Key('verify.tool.report'), {
        'POST incidents': real(fixture),
      });
      await app.enter(const Key('report.note'), 'Torn seal');
      await app.tap(find.byKey(const Key('report.submit')));
      expect(find.text(text), findsOneWidget);
    });
  }

  testWidgets('TC-STG-043 the real 409 for a 4th photo says why', (
    tester,
  ) async {
    final app = await open(tester, const Key('verify.tool.report'), {
      'POST incidents/3/photos': real('photo_fourth_409.json'),
    });
    await fileWithPhoto(app, 'Torn seal');
    final failure = find.byKey(const Key('report.photoFailure'));
    expect(
      find.descendant(
        of: failure,
        matching: find.text('The report has 3 photos already.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: failure,
        matching: find.text('Reference: req-staging'),
      ),
      findsOneWidget,
    );
    expect(app.backend.sent('POST', 'incidents'), hasLength(1));
  });

  test('TC-STG-043 every real refusal maps to its kind', () {
    for (final (fixture, kind) in [
      ('report_note_spaces_400.json', isA<ValidationException>()),
      ('report_unknown_check_404.json', isA<NotFoundException>()),
      ('photo_not_image_400.json', isA<ValidationException>()),
      ('photo_over_1mb_400.json', isA<ValidationException>()),
      ('photo_webp_415.json', isA<ValidationException>()),
      ('photo_unknown_report_404.json', isA<NotFoundException>()),
      ('photo_fourth_409.json', isA<ConflictException>()),
    ]) {
      final answer = stagingAnswer(fixture);
      final error = ErrorMapper.fromResponse(
        statusCode: answer['status'] as int,
        body: answer['body'],
      );
      expect(error, kind, reason: fixture);
      expect(error.requestId, 'req-staging', reason: fixture);
    }
  });

  testWidgets('TC-STG-044 My reports from the real list: newest first, '
      'photos, the check, an emoji note', (tester) async {
    final app = await open(tester, const Key('verify.tool.myReports'));
    expect(app.backend.sent('GET', 'incidents').single.queryParameters, {
      'limit': 50,
    });
    for (final id in [3, 2, 1]) {
      await tester.scrollUntilVisible(
        find.byKey(Key('reports.row.$id')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(Key('reports.row.$id')), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.byKey(const Key('reports.row.3')),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await app.tap(find.byKey(const Key('reports.row.3')));
    final detail = find.byKey(const Key('reports.detail'));
    expect(detail, findsOneWidget);
    expect(
      find.descendant(of: detail, matching: find.text('3 photos')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detail, matching: find.text('MA-2026-000032')),
      findsOneWidget,
    );
    final body = stagingAnswer('reports_200.json')['body'] as Map;
    final reports = (body['data'] as Map)['reports'] as List;
    final note = (reports.first as Map)['note'] as String;
    expect(note.runes.length, 1000);
    expect(
      find.descendant(of: detail, matching: find.text(note)),
      findsOneWidget,
    );
  });

  testWidgets('TC-STG-045 the picker with the real empty list', (
    tester,
  ) async {
    final app = await open(tester, const Key('verify.tool.report'));
    await app.tap(find.byKey(const Key('report.retailUser')));
    expect(find.text('No retail user found'), findsOneWidget);
    await app.enter(const Key('picker.search'), 'rahim');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      app.backend.sent('GET', 'retail-users').last.queryParameters['search'],
      'rahim',
    );
    expect(find.text('No retail user found'), findsOneWidget);
  });
}
