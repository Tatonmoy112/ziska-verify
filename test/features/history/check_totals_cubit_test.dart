import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';

class _MockRepo extends Mock implements HistoryRepository {}

const _totals = CheckTotals(
  total: 120,
  valid: 80,
  warning: 30,
  notFound: 9,
  unassigned: 1,
);

const Result<CheckPage> _page = Success(
  CheckPage(
    page: CursorPage(items: []),
    totals: _totals,
  ),
);

/// The Profile's check counts (final.md Section 13.8; TC-PROF-036, -038).
void main() {
  late _MockRepo repo;
  late List<(CheckQuery, PageRequest)> asked;

  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const PageRequest());
  });

  void answer(List<Result<CheckPage>> answers) {
    asked = [];
    var i = 0;
    when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
      asked.add((
        inv.positionalArguments[0] as CheckQuery,
        inv.positionalArguments[1] as PageRequest,
      ));
      // One answer per call; the last one repeats.
      final next = answers[i < answers.length ? i : answers.length - 1];
      i++;
      return next;
    });
  }

  setUp(() => repo = _MockRepo());

  CheckTotalsCubit build() => CheckTotalsCubit(GetChecks(repo));

  test('starts loading, with no counts', () {
    final cubit = build();
    expect(cubit.state.status, CheckTotalsStatus.loading);
    expect(cubit.state.totals, isNull);
  });

  blocTest<CheckTotalsCubit, CheckTotalsState>(
    'the counts: own checks, no filters, one check long',
    setUp: () => answer([_page]),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, CheckTotalsStatus.ready);
      expect(cubit.state.totals, _totals);
      final (query, page) = asked.single;
      expect(query, const CheckQuery());
      expect(page.limit, 1);
      expect(page.cursor, isNull);
    },
  );

  blocTest<CheckTotalsCubit, CheckTotalsState>(
    'a failure, then Try again',
    setUp: () => answer([const Err(Failure(NetworkException())), _page]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      expect(cubit.state.status, CheckTotalsStatus.failed);
      expect(cubit.state.totals, isNull);
      await cubit.load();
    },
    verify: (cubit) {
      expect(cubit.state.status, CheckTotalsStatus.ready);
      expect(cubit.state.totals, _totals);
    },
  );

  blocTest<CheckTotalsCubit, CheckTotalsState>(
    'asked again: the last counts stay while loading and after a failure',
    setUp: () => answer([_page, const Err(Failure(NetworkException()))]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      final again = cubit.load();
      expect(cubit.state.status, CheckTotalsStatus.loading);
      expect(cubit.state.totals, _totals);
      await again;
    },
    verify: (cubit) {
      expect(cubit.state.status, CheckTotalsStatus.failed);
      expect(cubit.state.totals, _totals);
    },
  );

  blocTest<CheckTotalsCubit, CheckTotalsState>(
    'a first page without totals: the counts are unknown',
    setUp: () => answer([
      const Success(CheckPage(page: CursorPage(items: []))),
    ]),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, CheckTotalsStatus.failed);
      expect(cubit.state.totals, isNull);
    },
  );

  blocTest<CheckTotalsCubit, CheckTotalsState>(
    'a second call while one runs is not sent',
    setUp: () => answer([_page]),
    build: build,
    act: (cubit) async {
      await Future.wait([cubit.load(), cubit.load()]);
    },
    verify: (_) => expect(asked, hasLength(1)),
  );
}
