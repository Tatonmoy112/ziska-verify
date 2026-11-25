import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/local_day_pages.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';

/// A row with the time it is kept by and the time the list is sorted by.
typedef _Row = ({String id, DateTime kept, DateTime sorted});

_Row _row(String id, DateTime at, [DateTime? sorted]) =>
    (id: id, kept: at, sorted: sorted ?? at);

/// TC-HIST-058 … -060 (docs/test-cases/06-history.md): one helper reads a
/// list's pages on the backend's UTC days and keeps the rows of the
/// official's Bangladesh days (guide §4.5, §5; production audit P-28).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  // 23 November in Dhaka: 22 Nov 18:00 UTC to 23 Nov 18:00 UTC.
  final day = DateTime(2026, 11, 23);
  final inside = DateTime.utc(2026, 11, 23, 3);
  final after = DateTime.utc(2026, 11, 23, 20); // 24 Nov in Dhaka
  final before = DateTime.utc(2026, 11, 22, 12); // 22 Nov in Dhaka

  late List<(DateTime?, DateTime?, String?)> sent;
  late Map<String?, CursorPage<_Row>> pages;

  Future<CursorPage<_Row>> read({String? cursor, int limit = 50}) =>
      readLocalDayPages<_Row>(
        from: day,
        to: day,
        page: PageRequest(limit: limit, cursor: cursor),
        fetch: (from, to, page) async {
          sent.add((from, to, page.cursor));
          return pages[page.cursor]!;
        },
        keptBy: (r) => r.kept,
        sortedBy: (r) => r.sorted,
      );

  setUp(() {
    sent = [];
    pages = {};
  });

  group('TC-HIST-058 normal: the rows of the day, by its UTC days', () {
    test('asks for the UTC days it overlaps; keeps the rows inside', () async {
      pages[null] = CursorPage(
        items: [_row('late', after), _row('in', inside)],
        nextCursor: 'c2',
      );
      final page = await read();
      expect(sent.single.$1, DateTime(2026, 11, 22));
      expect(sent.single.$2, DateTime(2026, 11, 23));
      expect(page.items.map((r) => r.id), ['in']);
      expect(page.nextCursor, 'c2');
    });

    test('the limit and the cursor are passed on', () async {
      pages['c9'] = CursorPage(items: [_row('in', inside)]);
      final page = await read(cursor: 'c9', limit: 20);
      expect(sent.single.$3, 'c9');
      expect(page.items, hasLength(1));
      expect(page.nextCursor, isNull);
    });
  });

  group('TC-HIST-059 edge: pages that keep nothing', () {
    test('are read through to the next page with a row', () async {
      pages[null] = CursorPage(items: [_row('a', after)], nextCursor: 'c2');
      pages['c2'] = const CursorPage(items: [], nextCursor: 'c3');
      pages['c3'] = CursorPage(items: [_row('in', inside)], nextCursor: 'c4');
      final page = await read();
      expect(sent.map((s) => s.$3), [null, 'c2', 'c3']);
      expect(page.items.map((r) => r.id), ['in']);
      expect(page.nextCursor, 'c4');
    });

    test('kept by one time, stopped by another', () async {
      // Started inside the day, last scanned after it: kept; the list is
      // sorted by the last scan, so it does not stop there.
      pages[null] = CursorPage(
        items: [_row('s', inside, after)],
        nextCursor: 'c2',
      );
      final page = await read();
      expect(page.items.map((r) => r.id), ['s']);
      expect(page.nextCursor, 'c2');
    });
  });

  group('TC-HIST-060 worst: the read always ends', () {
    test('a row before the first day ends the list', () async {
      pages[null] = CursorPage(
        items: [_row('in', inside), _row('old', before)],
        nextCursor: 'c2',
      );
      final page = await read();
      expect(page.items.map((r) => r.id), ['in']);
      expect(page.nextCursor, isNull, reason: 'nothing older can be kept');
    });

    test('at most 50 empty pages, then the cursor to go on', () async {
      for (var i = 0; i < 60; i++) {
        pages[i == 0 ? null : 'c$i'] = CursorPage(
          items: [_row('late$i', after)],
          nextCursor: 'c${i + 1}',
        );
      }
      final page = await read();
      expect(sent, hasLength(localDayPagesCap));
      expect(localDayPagesCap, 50);
      expect(page.items, isEmpty);
      expect(page.nextCursor, 'c50', reason: 'the list goes on from there');
    });

    test('no repository reads the local days by itself', () {
      final own = RegExp(r'LocalDays\.(utcDays|beforeFirstDay)\(');
      final found = <String>[];
      for (final file in Directory('lib').listSync(recursive: true)) {
        final path = file.path.replaceAll(r'\', '/');
        if (file is! File ||
            !path.endsWith('.dart') ||
            path.endsWith('core/utils/local_days.dart') ||
            path.endsWith('core/pagination/local_day_pages.dart')) {
          continue;
        }
        if (own.hasMatch(file.readAsStringSync())) found.add(path);
      }
      expect(found, isEmpty);
    });
  });
}
