import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';

import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: report and photo edge, worst, and failure cases
/// (docs/test-cases/07-reports.md, TC-REP-018 and later). The 1 MB rule is
/// a unit test in `photo_limit_test.dart`.
void main() {
  const general = 'Something went wrong. Try again.';
  const photosPath = 'incidents/1042/photos';

  Future<FlowApp> openReport(
    WidgetTester tester, {
    Map<String, Answer> overrides = const {},
  }) async {
    final app = await startApp(tester, overrides: overrides);
    await tester.scrollUntilVisible(
      find.byKey(const Key('verify.tool.report')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tap(find.byKey(const Key('verify.tool.report')));
    return app;
  }

  /// The report screen's own list (not the Verify list under it), found
  /// while the note field is still built.
  Finder reportList(WidgetTester tester) {
    final list = find
        .ancestor(
          of: find.byKey(const Key('report.note')),
          matching: find.byType(Scrollable),
        )
        .last
        .evaluate()
        .single;
    return find.byElementPredicate((e) => identical(e, list));
  }

  /// The report screen is a lazy list: the button is built once in view.
  Future<void> submit(FlowApp app, Finder list) async {
    final button = find.byKey(const Key('report.submit'));
    // Moved by its own position: a drag could land on the (scrolling)
    // note field instead of the list.
    for (var i = 0; i < 10 && button.evaluate().isEmpty; i++) {
      final position = app.tester.state<ScrollableState>(list).position;
      position.jumpTo(position.maxScrollExtent);
      await app.tester.pumpAndSettle();
    }
    await app.tap(button);
  }

  Future<void> file(FlowApp app, String note) async {
    final list = reportList(app.tester);
    await app.enter(const Key('report.note'), note);
    await submit(app, list);
  }

  Future<void> addPhoto(FlowApp app) async {
    await app.tap(find.byKey(const Key('report.addPhoto')));
    await app.tapText('Choose from gallery');
  }

  Map<String, dynamic> filed(FlowApp app) =>
      app.backend.sent('POST', 'incidents').last.data as Map<String, dynamic>;

  ScriptedAnswer photoN(int n) => ok({'n': n}, status: 201);

  group('Note', () {
    for (final (id, note) in [
      ('018', 'x'),
      ('019', 'n' * 1000),
      ('022', 'লেবেল ঝাপসা 😟'),
      ('023', 'line one\nline two\nline three'),
    ]) {
      testWidgets('TC-REP-$id the note is sent unchanged '
          '(${note.length} characters)', (tester) async {
        final app = await openReport(tester);
        await file(app, note);
        expect(filed(app)['note'], note);
      });
    }

    testWidgets('TC-REP-020 never more than 1 000 characters', (
      tester,
    ) async {
      final app = await openReport(tester);
      await file(app, 'n' * 1001);
      expect(app.fieldText(const Key('report.note')), hasLength(1000));
      expect((filed(app)['note'] as String).length, 1000);
    });

    testWidgets('TC-REP-021 a note of spaces only cannot be filed', (
      tester,
    ) async {
      final app = await openReport(tester);
      await app.enter(const Key('report.note'), '    ');
      expect(app.enabled(const Key('report.submit')), isFalse);
      expect(app.backend.sent('POST', 'incidents'), isEmpty);
    });
  });

  group('Filing', () {
    testWidgets('TC-REP-024 a report about nothing linked', (tester) async {
      final app = await openReport(tester);
      await file(app, 'Shop selling outside its area');
      expect(filed(app)['check_ref'], isNull);
      expect(filed(app)['retail_user_id'], isNull);
    });

    testWidgets('TC-REP-025 a linked check or retail user not found', (
      tester,
    ) async {
      final app = await openReport(
        tester,
        overrides: {'POST incidents': always(apiError(404, 'not_found'))},
      );
      await file(app, 'Torn seal');
      expect(
        find.text(
          'The check or the retail user was not found. Remove it and try '
          'again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-REP-026 filing rate limited counts down and waits', (
      tester,
    ) async {
      final app = await openReport(
        tester,
        overrides: {
          'POST incidents': always(
            apiError(429, 'rate_limited', retryAfter: 60),
          ),
        },
      );
      await file(app, 'Torn seal');
      expect(
        find.text('Too many attempts. Try again in 60 s.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Too many attempts. Try again in 59 s.'),
        findsOneWidget,
      );
      await submit(app, reportList(tester));
      expect(app.backend.sent('POST', 'incidents'), hasLength(1));
    });

    for (final (status, code, text) in [
      (500, 'internal_error', general),
      (503, 'service_unavailable', 'The service is busy. Try again shortly.'),
    ]) {
      testWidgets('TC-REP-027 filing answered $status: never filed again by '
          'itself', (tester) async {
        final app = await openReport(
          tester,
          overrides: {'POST incidents': always(apiError(status, code))},
        );
        await file(app, 'Torn seal');
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(find.text(text), findsOneWidget);
        expect(find.textContaining('req-1'), findsOneWidget);
        expect(app.backend.sent('POST', 'incidents'), hasLength(1));
      });
    }

    testWidgets('TC-REP-041 a report from a not-found result', (
      tester,
    ) async {
      final app = await startApp(
        tester,
        overrides: {
          'POST lookups': always(
            ok({'ref': 'MA-2026-000888', 'result': 'not_found'}),
          ),
        },
      );
      await app.enter(const Key('verify.input'), '1000001');
      await app.tap(find.byKey(const Key('verify.submit')));
      await app.tap(find.byKey(const Key('result.report')));
      expect(find.textContaining('MA-2026-000888'), findsWidgets);
      await file(app, 'Not in the system');
      expect(filed(app)['check_ref'], 'MA-2026-000888');
    });
  });

  group('Photos', () {
    for (final (id, problem, text) in [
      (
        '029',
        PhotoProblem.tooLarge,
        'This photo is too large even after shrinking.',
      ),
      (
        '031',
        PhotoProblem.unreadable,
        'This photo could not be read. Try another.',
      ),
    ]) {
      testWidgets('TC-REP-$id a photo that cannot be prepared is not added', (
        tester,
      ) async {
        final app = await openReport(tester);
        app.photos.problem = problem;
        await addPhoto(app);
        expect(find.text(text), findsOneWidget);
        await file(app, 'Torn seal');
        expect(
          app.backend.requests.where((r) => r.path == photosPath),
          isEmpty,
        );
      });
    }

    for (final (id, status, code) in [
      ('034', 409, 'conflict'),
      ('035', 404, 'not_found'),
    ]) {
      testWidgets('TC-REP-$id a refused photo ($status) is not offered '
          'again', (tester) async {
        final app = await openReport(
          tester,
          overrides: {'POST $photosPath': always(apiError(status, code))},
        );
        await addPhoto(app);
        await file(app, 'Torn seal');
        expect(find.text('This photo was refused.'), findsOneWidget);
        expect(find.text('Not sent. Tap to send again.'), findsNothing);
        await app.tapText('This photo was refused.');
        expect(app.backend.sent('POST', photosPath), hasLength(1));
      });
    }

    for (final (status, code) in [
      (429, 'rate_limited'),
      (500, 'internal_error'),
    ]) {
      testWidgets('TC-REP-036 a photo answered $status is sent again to the '
          'same report', (tester) async {
        var calls = 0;
        final app = await openReport(
          tester,
          overrides: {
            'POST $photosPath': (_) =>
                calls++ == 0 ? apiError(status, code) : photoN(1),
          },
        );
        await addPhoto(app);
        await file(app, 'Torn seal');
        expect(find.text('Not sent. Tap to send again.'), findsOneWidget);

        // The failed photo itself is tapped (TC-REP-006).
        await app.tap(find.byIcon(LucideIcons.refreshCw));
        expect(app.backend.sent('POST', photosPath), hasLength(2));
        expect(find.text('Photo 1'), findsOneWidget);
        expect(app.backend.sent('POST', 'incidents'), hasLength(1));
      });
    }

    testWidgets('TC-REP-038 a photo added after filing is sent at once', (
      tester,
    ) async {
      var n = 0;
      final app = await openReport(
        tester,
        overrides: {'POST $photosPath': (_) => photoN(++n)},
      );
      await addPhoto(app);
      await file(app, 'Torn seal');
      expect(find.text('Photo 1'), findsOneWidget);

      await addPhoto(app);
      expect(app.backend.sent('POST', photosPath), hasLength(2));
      expect(find.text('Photo 2'), findsOneWidget);
      expect(app.backend.sent('POST', 'incidents'), hasLength(1));
    });

    testWidgets('TC-REP-039 a cancelled picker adds nothing', (tester) async {
      final app = await openReport(tester);
      app.photos.cancel = true;
      await addPhoto(app);
      await file(app, 'Torn seal');
      expect(app.backend.sent('POST', photosPath), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('My reports', () {
    Map<String, Object?> report(
      int id, {
      String note = 'Seal is cut',
      int photos = 2,
      String? checkRef = 'MA-2026-000123',
      bool retailUser = true,
    }) => {
      'id': id,
      'at': '2026-10-28T10:04:37.512+00:00',
      'note': note,
      'photos': photos,
      'check_ref': checkRef,
      'retail_user': retailUser ? {'id': '9d2e', 'name': 'Rahim Store'} : null,
    };

    ScriptedAnswer reports(List<Map<String, Object?>> list, {String? next}) =>
        ok({'reports': list, 'next_cursor': next});

    Future<FlowApp> openMyReports(
      WidgetTester tester,
      Answer answer,
    ) async {
      final app = await startApp(tester, overrides: {'GET incidents': answer});
      await tester.scrollUntilVisible(
        find.byKey(const Key('verify.tool.myReports')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await app.tap(find.byKey(const Key('verify.tool.myReports')));
      return app;
    }

    testWidgets('TC-REP-042 the next page; TC-REP-046 only limit and '
        'cursor', (tester) async {
      final app = await openMyReports(
        tester,
        (r) => r.queryParameters['cursor'] == null
            ? reports([report(1042)], next: 'c1')
            : reports([report(1041)]),
      );
      final sent = app.backend.sent('GET', 'incidents');
      expect(sent, hasLength(2));
      expect(sent.first.queryParameters.keys.toSet(), {'limit'});
      expect(sent.last.queryParameters, {'limit': 50, 'cursor': 'c1'});
      expect(find.textContaining('1042'), findsWidgets);
      expect(find.textContaining('1041'), findsWidgets);
    });

    testWidgets('TC-REP-043 no reports yet', (tester) async {
      await openMyReports(tester, always(reports([])));
      expect(find.text('You have not filed any report yet.'), findsOneWidget);
    });

    testWidgets('TC-REP-044 a first-page error, then Try again', (
      tester,
    ) async {
      var calls = 0;
      final app = await openMyReports(
        tester,
        (_) => calls++ == 0
            ? apiError(500, 'internal_error', requestId: 'req-m')
            : reports([report(1042)]),
      );
      expect(find.text(general), findsOneWidget);
      expect(find.textContaining('req-m'), findsOneWidget);
      await app.tapText('Try again');
      expect(find.textContaining('1042'), findsWidgets);
    });

    testWidgets('TC-REP-045 a report with nothing linked', (tester) async {
      await openMyReports(
        tester,
        always(
          reports([report(1043, photos: 0, checkRef: null, retailUser: false)]),
        ),
      );
      expect(find.text('No photos'), findsOneWidget);
      expect(find.textContaining('Rahim Store'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('TC-REP-047 a 1 000-character note fits', (tester) async {
      await openMyReports(
        tester,
        always(reports([report(1044, note: 'Torn seal ' * 100)])),
      );
      expect(tester.takeException(), isNull);
      expect(find.textContaining('1044'), findsWidgets);
    });
  });
}
