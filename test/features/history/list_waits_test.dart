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
