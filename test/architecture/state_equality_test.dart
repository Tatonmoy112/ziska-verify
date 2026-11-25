import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/history/presentation/bloc/check_totals_cubit.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/sessions_cubit.dart';

/// A cubit that emits what it is given, to see what reaches listeners.
class _Echo<S> extends Cubit<S> {
  _Echo(super.initialState);
  void put(S s) => emit(s);
}

final _photo = PreparedPhoto(Uint8List(4));
final _at = DateTime.utc(2026, 11, 25, 9);

/// TC-ARCH-035 … -037 (docs/test-cases/18-architecture.md): every bloc
/// state compares by value (Freezed); a failure stays one event
/// (production audit P-26).
void main() {
  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const PageRequest());
  });

  group('TC-ARCH-035 normal: equal states are equal', () {
    test('each state, built twice from the same values', () {
      final pairs = <(Object, Object)>[
        (
          const PaginatedState<int>(items: [1, 2], nextCursor: 'c'),
          const PaginatedState<int>(items: [1, 2], nextCursor: 'c'),
        ),
        (
          const SessionsState(query: SessionQuery(status: ScanStatus.open)),
          const SessionsState(query: SessionQuery(status: ScanStatus.open)),
        ),
        (
          const RetailUserPickerState(search: 'a'),
          const RetailUserPickerState(search: 'a'),
        ),
        (
          CheckTotalsState(status: CheckTotalsStatus.ready, retryAt: _at),
          CheckTotalsState(status: CheckTotalsStatus.ready, retryAt: _at),
        ),
        (
          const HistoryState(searchRefused: true),
          const HistoryState(searchRefused: true),
        ),
        (
          ReportIncidentState(
            checkRef: 'MA-1',
            photos: [ReportPhoto(localId: 1, photo: _photo)],
            filedAt: _at,
          ),
          ReportIncidentState(
            checkRef: 'MA-1',
            photos: [ReportPhoto(localId: 1, photo: _photo)],
            filedAt: _at,
          ),
        ),
      ];
      for (final (a, b) in pairs) {
        expect(a, b, reason: '${a.runtimeType}');
        expect(a.hashCode, b.hashCode, reason: '${a.runtimeType}');
      }
      expect(
        const HistoryState(searchRefused: true),
        isNot(const HistoryState()),
      );
    });
  });

  group('TC-ARCH-036 edge: lists by value; copyWith clears', () {
    test('two lists with the same items are equal', () {
      final a = PaginatedState<int>(items: List.of([1, 2]));
      final b = PaginatedState<int>(items: List.of([1, 2]));
      expect(a, b);
      expect(a, isNot(PaginatedState<int>(items: List.of([2, 1]))));
    });

    test('a field set to null by copyWith is cleared', () {
      const failure = Failure(NetworkException());
      final state = ReportIncidentState(
        checkRef: 'MA-1',
        failure: failure,
        missing: MissingLink.check,
        retryAt: _at,
      ).copyWith(failure: null, missing: null, checkRef: null);
      expect(state.failure, isNull);
      expect(state.missing, isNull);
      expect(state.checkRef, isNull);
      expect(state.retryAt, _at, reason: 'not named, so kept');
      const totals = CheckTotals(
        total: 1,
        valid: 1,
        warning: 0,
        notFound: 0,
        unassigned: 0,
      );
      final history = const HistoryState(
        totals: totals,
        chipTotals: totals,
      ).copyWith(totals: null);
      expect(history.totals, isNull);
      expect(history.chipTotals, totals);
      final photo = ReportPhoto(
        localId: 1,
        photo: _photo,
        failure: failure,
        retryAt: _at,
      ).copyWith(failure: null, retryAt: null);
      expect(photo.failure, isNull);
      expect(photo.retryAt, isNull);
    });
  });

  group('TC-ARCH-037 worst: what reaches the screen', () {
    test('an equal state is not emitted again', () async {
      final cubit = _Echo(const PaginatedState<RetailUser>());
      final seen = <PaginatedState<RetailUser>>[];
      final sub = cubit.stream.listen(seen.add);
      // Built at run time: two const states would be one object anyway.
      PaginatedState<RetailUser> loading() => PaginatedState(
        items: List.of(const []),
        status: PaginationStatus.loadingFirst,
      );
      cubit
        ..put(loading())
        ..put(loading());
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(1));
      await sub.cancel();
      await cubit.close();
    });

    test('the same failure twice is two events: each is shown', () async {
      final cubit = _Echo(const PaginatedState<RetailUser>());
      final seen = <PaginatedState<RetailUser>>[];
      final sub = cubit.stream.listen(seen.add);
      // Two answers that look alike are two failures (Failure has no
      // value equality on purpose): a retry that fails again says so.
      for (var i = 0; i < 2; i++) {
        cubit.put(
          PaginatedState<RetailUser>(
            items: List.of(const []),
            status: PaginationStatus.loadingFirst,
          ).failed(Failure(InternalErrorException(statusCode: 500 + 0 * i))),
        );
      }
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(2));
      await sub.cancel();
      await cubit.close();
    });

    test('every bloc state is Freezed', () {
      final files = [
        File('lib/core/pagination/paginated_state.dart'),
        ...Directory('lib/features')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path
                      .replaceAll(r'\', '/')
                      .contains('/presentation/bloc/') &&
                  f.path.endsWith('.dart') &&
                  !f.path.endsWith('.freezed.dart'),
            ),
      ];
      final state = RegExp(
        r'^(?:abstract |final |sealed )?class (\w+(?:State|Photo))\b',
        multiLine: true,
      );
      final plain = <String>[];
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (final (i, line) in lines.indexed) {
          final m = state.firstMatch(line);
          if (m == null) continue;
          if (i == 0 || lines[i - 1].trim() != '@freezed') {
            plain.add('${file.path}: ${m.group(1)}');
          }
        }
      }
      expect(plain, isEmpty);
    });

    // An equal state is no longer emitted, so a pull to refresh cannot wait
    // for "the next state": the refresh event says when it is done.
    group('a refresh that changes nothing still ends', () {
      test('History, on a search that is not sent', () async {
        final repo = _History();
        final bloc = HistoryBloc(
          GetChecks(repo),
          initialQuery: const CheckQuery(search: 'abc'),
        )..add(const HistoryRefreshed());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.searchRefused, isTrue);

        final done = Completer<void>();
        bloc.add(HistoryRefreshed(done: done));
        await done.future.timeout(const Duration(seconds: 2));
        verifyNever(() => repo.getChecks(any(), any()));
        await bloc.close();
      });

      test('My reports, during a 429 wait', () async {
        final repo = _Incidents();
        when(() => repo.myReports(any())).thenAnswer(
          (_) async => const Err<CursorPage<Report>>(
            Failure(RateLimitedException(retryAfter: Duration(minutes: 1))),
          ),
        );
        final bloc = MyReportsBloc(GetMyReports(repo))
          ..add(const MyReportsStarted());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(bloc.state.isWaiting, isTrue);

        final done = Completer<void>();
        bloc.add(MyReportsStarted(keepItems: true, done: done));
        await done.future.timeout(const Duration(seconds: 2));
        verify(() => repo.myReports(any())).called(1);
        await bloc.close();
      });
    });
  });
}

class _History extends Mock implements HistoryRepository {}

class _Incidents extends Mock implements IncidentRepository {}
