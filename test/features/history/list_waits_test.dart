import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';

class _History extends Mock implements HistoryRepository {}

class _Verification extends Mock implements VerificationRepository {}

class _RetailUsers extends Mock implements RetailUserRepository {}

class _Incidents extends Mock implements IncidentRepository {}

/// The wait the server asks for; short, so the tests run in real time.
const _wait = Duration(milliseconds: 80);

const _limited = Err<Never>(
  Failure(RateLimitedException(retryAfter: _wait)),
);

/// A tap during a `429` wait is not sent at once and not lost: the list
/// follows the new filter or search once the wait ends (guide section 1).
void main() {
  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const SessionQuery());
    registerFallbackValue(const PageRequest());
  });

  test(
    'TC-MIG-043 History: a filter during a wait loads once, after it',
    () async {
      final repo = _History();
      final sent = <CheckQuery>[];
      when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
        sent.add(inv.positionalArguments[0] as CheckQuery);
        return sent.length == 1
            ? _limited
            : const Success(CheckPage(page: CursorPage(items: [])));
      });
      final bloc = HistoryBloc(GetChecks(repo))
        ..add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.list.isWaiting, isTrue);

      const picked = CheckQuery(way: CheckWay.qr);
      bloc
        ..add(const HistoryQueryChanged(picked))
        ..add(const HistoryRefreshed());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.query, picked, reason: 'the chips follow the tap');
      expect(sent, hasLength(1), reason: 'nothing is sent during the wait');

      await Future<void>.delayed(_wait * 2);
      expect(sent.skip(1).every((q) => q.way == CheckWay.qr), isTrue);
      expect(sent.skip(1).where((q) => q.result == null), hasLength(1));
      await bloc.close();
    },
  );

  // TC-HIST-055 (audit 7.1; guide §5: a cursor goes back to the list that
  // gave it): the next page waits out a 429; a filter picked meanwhile
  // loads its own first page, never the new filter with the old cursor.
  test(
    'TC-HIST-055 History: a filter during a next-page wait starts its own '
    'list',
    () async {
      CheckRecord row(String ref) => CheckRecord(
        ref: ref,
        at: DateTime.utc(2026, 11, 23, 5),
        way: CheckWay.serial,
        result: CheckResult.valid,
        reasons: const [],
        official: 'Asha Rao',
      );
      final repo = _History();
      final sent = <(CheckQuery, String?)>[];
      when(() => repo.getChecks(any(), any())).thenAnswer((inv) async {
        final query = inv.positionalArguments[0] as CheckQuery;
        final cursor = (inv.positionalArguments[1] as PageRequest).cursor;
        sent.add((query, cursor));
        if (sent.length == 1) {
          return Success(
            CheckPage(
              page: CursorPage(items: [row('OLD')], nextCursor: 'c1'),
            ),
          );
        }
        if (sent.length == 2) return _limited;
        return Success(CheckPage(page: CursorPage(items: [row('NEW')])));
      });
      final bloc = HistoryBloc(GetChecks(repo))
        ..add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const HistoryNextPageRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.list.isWaiting, isTrue);

      const picked = CheckQuery(way: CheckWay.qr);
      bloc.add(const HistoryQueryChanged(picked));
      await Future<void>.delayed(_wait * 2);

      final after = sent.skip(2).toList();
      expect(after, isNotEmpty);
      for (final (query, cursor) in after) {
        expect(query.way, CheckWay.qr);
        expect(cursor, isNull, reason: 'never the old list cursor');
      }
      expect(bloc.state.list.items.map((c) => c.ref), ['NEW']);
      await bloc.close();
    },
  );

  test(
    'TC-MIG-043 Sessions: a filter during a wait loads once, after it',
    () async {
      final repo = _Verification();
      final sent = <SessionQuery>[];
      when(() => repo.sessions(any(), any())).thenAnswer((inv) async {
        sent.add(inv.positionalArguments[0] as SessionQuery);
        return sent.length == 1
            ? _limited
            : const Success(CursorPage<ScanSessionSummary>(items: []));
      });
      final cubit = SessionsCubit(repo);
      await cubit.load();
      expect(cubit.state.list.isWaiting, isTrue);

      await cubit.load(const SessionQuery(status: ScanStatus.ended));
      expect(cubit.state.query.status, ScanStatus.ended);
      expect(sent, hasLength(1));

      await Future<void>.delayed(_wait * 2);
      expect(sent, hasLength(2));
      expect(sent.last.status, ScanStatus.ended);
      await cubit.close();
    },
  );

  test(
    'TC-MIG-043 Retail picker: a search during a wait runs after it',
    () async {
      final repo = _RetailUsers();
      final sent = <String?>[];
      when(() => repo.search(any(), any())).thenAnswer((inv) async {
        sent.add(inv.positionalArguments[0] as String?);
        return sent.length == 1
            ? _limited
            : const Success(CursorPage<RetailUser>(items: []));
      });
      final bloc = RetailUserPickerBloc(SearchRetailUsers(repo))
        ..add(const PickerStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.list.isWaiting, isTrue);

      bloc.add(const PickerSearchTyped('Dhaka'));
      // The search is debounced (400 ms), so the wait ends before it runs.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(sent, [null, 'Dhaka']);
      await bloc.close();
    },
  );

  test('TC-MIG-043 Retail picker: a search inside the wait is kept', () async {
    final repo = _RetailUsers();
    final sent = <String?>[];
    when(() => repo.search(any(), any())).thenAnswer((inv) async {
      sent.add(inv.positionalArguments[0] as String?);
      return sent.length == 1
          ? const Err<Never>(
              Failure(
                RateLimitedException(retryAfter: Duration(milliseconds: 700)),
              ),
            )
          : const Success(CursorPage<RetailUser>(items: []));
    });
    final bloc = RetailUserPickerBloc(SearchRetailUsers(repo))
      ..add(const PickerStarted());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(const PickerSearchTyped('Dhaka'));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(sent, [null], reason: 'still waiting');
    expect(bloc.state.search, 'Dhaka');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(sent, [null, 'Dhaka']);
    await bloc.close();
  });

  test('TC-MIG-043 My reports: a pull during a wait sends nothing', () async {
    final repo = _Incidents();
    var sent = 0;
    when(() => repo.myReports(any())).thenAnswer((_) async {
      sent++;
      return sent == 1
          ? _limited
          : const Success(CursorPage<Report>(items: []));
    });
    final bloc = MyReportsBloc(GetMyReports(repo))
      ..add(const MyReportsStarted());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.isWaiting, isTrue);
    bloc
      ..add(const MyReportsStarted(keepItems: true))
      ..add(const MyReportsRetried());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(sent, 1);
    await Future<void>.delayed(_wait * 2);
    bloc.add(const MyReportsRetried());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(sent, 2);
    await bloc.close();
  });
}
