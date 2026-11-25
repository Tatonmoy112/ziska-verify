import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/app/bridges/recovered_scans.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

class _History extends Mock implements HistoryRepository {}

CheckRecord _check(String ref, CheckResult result) => CheckRecord(
  ref: ref,
  at: DateTime.utc(2026, 11, 25, 9),
  way: CheckWay.qr,
  result: result,
  reasons: const [],
  official: 'Test Official',
  serial: '1000$ref',
  product: 'Napa 500',
);

/// TC-MIG-083 … -085 (docs/test-cases/16-mobile-migration.md): a resumed
/// scan session's scans, read from History's checks of the session, by a
/// bridge in `app/` rather than in the routes (production audit P-30).
void main() {
  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const PageRequest());
  });

  late _History repo;
  late RecoveredScansBridge bridge;
  late List<(CheckQuery, PageRequest)> asked;
  late Result<CheckPage> answer;
  setUp(() {
    repo = _History();
    asked = [];
    when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
      asked.add((
        inv.positionalArguments[0] as CheckQuery,
        inv.positionalArguments[1] as PageRequest,
      ));
      return answer;
    });
    bridge = RecoveredScansBridge(GetChecks(repo));
  });

  Future<RecoveredScans> scans(String? cursor) async =>
      (await bridge('S-1', cursor) as Success<RecoveredScans>).value;

  group('TC-MIG-083 normal: each check is a scan of the session', () {
    test('every result maps to its outcome; the rest is kept', () async {
      answer = Success(
        CheckPage(
          page: CursorPage(
            items: [
              _check('1', CheckResult.valid),
              _check('2', CheckResult.warning),
              _check('3', CheckResult.notFound),
              _check('4', CheckResult.unassigned),
            ],
            nextCursor: 'c2',
          ),
        ),
      );
      final page = await scans(null);
      expect(page.items.map((s) => s.outcome), [
        LookupOutcome.valid,
        LookupOutcome.warning,
        LookupOutcome.notFound,
        LookupOutcome.unassigned,
      ]);
      expect(page.items.first.ref, '1');
      expect(page.items.first.serial, '10001');
      expect(page.items.first.product, 'Napa 500');
      expect(page.nextCursor, 'c2');
    });

    test("the session's own checks, 100 at a time, by its cursor", () async {
      answer = const Success(CheckPage(page: CursorPage(items: [])));
      await scans('c7');
      expect(asked.single.$1, const CheckQuery(sessionId: 'S-1'));
      expect(asked.single.$2.limit, PageRequest.maxLimit);
      expect(asked.single.$2.cursor, 'c7');
    });
  });

  group('TC-MIG-084 edge: an empty page', () {
    test('no scans, no cursor', () async {
      answer = const Success(CheckPage(page: CursorPage(items: [])));
      final page = await scans(null);
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('Result.map: a value mapped, a failure kept as it is', () {
      const failure = Failure(InternalErrorException(statusCode: 500));
      final mapped = const Success(2).map((v) => v * 10);
      expect((mapped as Success<int>).value, 20);
      final err = const Err<int>(failure).map((v) => '$v');
      expect((err as Err<String>).failure, same(failure));
    });
  });

  group('TC-MIG-085 worst', () {
    test('an unknown result stays unknown, never a valid one', () async {
      answer = Success(
        CheckPage(
          page: CursorPage(items: [_check('9', CheckResult.unknown)]),
        ),
      );
      final page = await scans(null);
      expect(page.items.single.outcome, LookupOutcome.unknown);
    });

    test('a failure passes through unchanged', () async {
      const failure = Failure(
        RateLimitedException(retryAfter: Duration(seconds: 30)),
      );
      answer = const Err(failure);
      final result = await bridge('S-1', null);
      expect((result as Err).failure, same(failure));
    });

    test('no route maps one feature into another itself', () {
      final mapped = RegExp(r'\bCheckResult\.\w+\s*=>');
      final found = [
        for (final file in Directory(
          'lib/app/router',
        ).listSync(recursive: true))
          if (file is File && mapped.hasMatch(file.readAsStringSync()))
            file.path,
      ];
      expect(found, isEmpty);
    });
  });
}
