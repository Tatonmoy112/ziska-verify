import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/pagination/paged_loader.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/my_reports_bloc.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/retail_user_usecases.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_picker_bloc.dart';

/// The wait the server asks for; short, so the tests run in real time.
const _wait = Duration(milliseconds: 80);
const _limited = Err<Never>(Failure(RateLimitedException(retryAfter: _wait)));
const _down = Err<Never>(Failure(InternalErrorException(statusCode: 500)));

/// A list owner as small as can be: its state is the list itself.
class _Owner {
  _Owner() {
    loader = PagedLoader.ofPages<int, String>(
      (query, page) async {
        sent.add((query, page.cursor));
        return answers.removeAt(0);
      },
      onWaitOver: () => waitsOver++,
    );
  }

  late final PagedLoader<int, String, CursorPage<int>> loader;
  final sent = <(String, String?)>[];
  final answers = <Result<CursorPage<int>>>[];
  final updates = <PagePhase>[];
  PaginatedState<int> list = const PaginatedState();
  String? shown;
  bool alive = true;
  int waitsOver = 0;

  PageSink<int, String, CursorPage<int>> get sink => PageSink(
    read: () => list,
    alive: () => alive,
    put: (u) {
      updates.add(u.phase);
      list = u.list;
      shown = u.query;
    },
  );
}

Success<CursorPage<int>> _page(List<int> items, [String? next]) =>
    Success(CursorPage(items: items, nextCursor: next));

/// TC-MIG-077 … -079 (docs/test-cases/16-mobile-migration.md): one
/// `PagedLoader` holds the paging rules every list follows (final.md §10;
/// production audit P-27).
void main() {
  setUpAll(() => registerFallbackValue(const PageRequest()));

  group('TC-MIG-077 normal: first page, next page, the end', () {
    test('pages in order, with their cursors', () async {
      final o = _Owner()
        ..answers.addAll([
          _page([1, 2], 'c2'),
          _page([3]),
        ]);
      await o.loader.first(o.sink, 'all');
      expect(o.list.items, [1, 2]);
      expect(o.list.canLoadMore, isTrue);
      await o.loader.next(o.sink, 'all');
      expect(o.list.items, [1, 2, 3]);
      expect(o.list.hasReachedEnd, isTrue);
      expect(o.sent, [('all', null), ('all', 'c2')]);
      expect(o.updates, [
        PagePhase.loadingFirst,
        PagePhase.first,
        PagePhase.loadingNext,
        PagePhase.next,
      ]);
      await o.loader.next(o.sink, 'all'); // the end: nothing more is sent
      expect(o.sent, hasLength(2));
    });

    test('retry: the failed page, then the first page', () async {
      final o = _Owner()
        ..answers.addAll([
          _page([1], 'c2'),
          _down,
          _page([2]),
          _down,
        ]);
      await o.loader.first(o.sink, 'all');
      await o.loader.next(o.sink, 'all');
      expect(o.list.status, PaginationStatus.failureMore);
      await o.loader.retry(o.sink, 'all');
      expect(o.list.items, [1, 2]);
      expect(o.sent.last, ('all', 'c2'));
      final p = _Owner()
        ..answers.addAll([
          _down,
          _page([9]),
        ]);
      await p.loader.first(p.sink, 'all');
      await p.loader.retry(p.sink, 'all');
      expect(p.sent, [('all', null), ('all', null)]);
      expect(p.list.items, [9]);
    });
  });

  group('TC-MIG-078 edge: a load asked for during a 429 wait', () {
    test('is held: nothing sent, the query shown, run once after', () async {
      final o = _Owner()..answers.addAll([_limited]);
      await o.loader.first(o.sink, 'all');
      expect(o.list.isWaiting, isTrue);
      await o.loader.first(o.sink, 'ended');
      await o.loader.first(o.sink, 'open');
      expect(o.sent, hasLength(1), reason: 'nothing during the wait');
      expect(o.shown, 'open', reason: 'the query follows the taps');
      expect(o.updates.last, PagePhase.held);
      await Future<void>.delayed(_wait * 2);
      expect(o.waitsOver, 1, reason: 'once, for all the taps');
    });

    test('My reports holds a load too, and loads after the wait', () async {
      final repo = _Incidents();
      final answers = <Result<CursorPage<Report>>>[
        _limited,
        const Success(CursorPage(items: [])),
      ];
      when(
        () => repo.myReports(any()),
      ).thenAnswer((_) async => answers.removeAt(0));
      final bloc = MyReportsBloc(GetMyReports(repo))
        ..add(const MyReportsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isWaiting, isTrue);
      bloc.add(const MyReportsStarted(keepItems: true));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      verify(() => repo.myReports(any())).called(1);
      await Future<void>.delayed(_wait * 2);
      verify(() => repo.myReports(any())).called(1); // the held one
      expect(bloc.state.status, PaginationStatus.empty);
      await bloc.close();
    });
  });

  group('TC-MIG-079 worst', () {
    test('an answer for an older list is dropped', () async {
      final slow = Completer<Result<CursorPage<int>>>();
      final o = _Owner();
      var first = true;
      final loader = PagedLoader.ofPages<int, String>(
        (query, page) {
          o.sent.add((query, page.cursor));
          if (first) {
            first = false;
            return slow.future;
          }
          return Future.value(_page([7]));
        },
        onWaitOver: () {},
      );
      final old = loader.first(o.sink, 'all');
      await loader.first(o.sink, 'ended');
      slow.complete(_page([1, 2, 3]));
      await old;
      expect(o.list.items, [7], reason: "All's late answer is not shown");
      expect(o.shown, 'ended');
    });

    test('an owner that is gone gets nothing', () async {
      final o = _Owner()
        ..answers.addAll([
          _page([1]),
        ]);
      final loading = o.loader.first(o.sink, 'all');
      o.alive = false;
      await loading;
      expect(o.list.status, PaginationStatus.loadingFirst);
    });

    test('a next page or retry during the wait sends nothing', () async {
      final o = _Owner()
        ..answers.addAll([
          _page([1], 'c2'),
          _limited,
        ]);
      await o.loader.first(o.sink, 'all');
      await o.loader.next(o.sink, 'all');
      expect(o.list.isWaiting, isTrue);
      await o.loader.next(o.sink, 'all');
      await o.loader.retry(o.sink, 'all');
      expect(o.sent, hasLength(2));
      expect(o.list.items, [1]);
    });

    test(
      'a query changed during a page-2 wait never gets the old cursor',
      () async {
        final o = _Owner()
          ..answers.addAll([
            _page([1], 'c2'),
            _limited,
            _page([5]),
            _page([6]),
          ]);
        await o.loader.first(o.sink, 'all');
        await o.loader.next(o.sink, 'all');
        await o.loader.first(o.sink, 'ended'); // held
        await Future<void>.delayed(_wait * 2);
        await o.loader.retry(o.sink, 'ended');
        await o.loader.next(o.sink, 'ended');
        for (final (query, cursor) in o.sent.skip(2)) {
          expect(query, 'ended');
          expect(cursor, isNull, reason: "All's cursor sent with Ended");
        }
        expect(o.list.items, [5]);
      },
    );

    test(
      'the retail picker: a search typed during a page-2 wait',
      () async {
        final repo = _RetailUsers();
        final sent = <(String?, String?)>[];
        final answers = <Result<CursorPage<RetailUser>>>[
          const Success(
            CursorPage(
              items: [
                RetailUser(id: 'r1', name: 'A', maskedEmail: 'a***@x.com'),
              ],
              nextCursor: 'c2',
            ),
          ),
          // Longer than the picker's 400 ms debounce, so the search is
          // typed and handled during the wait.
          const Err(
            Failure(
              RateLimitedException(retryAfter: Duration(milliseconds: 700)),
            ),
          ),
          const Success(CursorPage(items: [])),
        ];
        when(() => repo.search(any(), any())).thenAnswer((inv) async {
          final page = inv.positionalArguments[1] as PageRequest;
          sent.add((inv.positionalArguments[0] as String?, page.cursor));
          return answers.removeAt(0);
        });
        final bloc = RetailUserPickerBloc(SearchRetailUsers(repo))
          ..add(const PickerStarted());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const PickerNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(bloc.state.list.isWaiting, isTrue);
        bloc.add(const PickerSearchTyped('Rahim'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(sent, hasLength(2), reason: 'held during the wait');
        expect(bloc.state.search, 'Rahim');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(sent, hasLength(3));
        expect(sent[2], ('Rahim', null), reason: 'its own page 1');
        await bloc.close();
      },
    );
  });
  test('TC-MIG-079 worst: no list pages by itself', () {
    // Only the loader builds pages; a list that wrote its own would bring
    // back its own rules (the scan session's rows are P-36's).
    final own = RegExp(r'\.(loadingFirst|loadingMore|firstPage|nextPage)\(');
    final found = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      final path = file.path.replaceAll(r'\', '/');
      if (file is! File ||
          !path.endsWith('.dart') ||
          path.endsWith('.freezed.dart') ||
          path.contains('lib/core/pagination/')) {
        continue;
      }
      if (own.hasMatch(file.readAsStringSync())) found.add(path);
    }
    expect(found, isEmpty);
  });
}

class _Incidents extends Mock implements IncidentRepository {}

class _RetailUsers extends Mock implements RetailUserRepository {}
