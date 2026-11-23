import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/core/utils/local_days.dart';

/// TC-HIST-051: the backend's `from`/`to` are whole UTC days (guide §4.5,
/// §5); the app shows Bangladesh days, so it asks for the UTC days a
/// Bangladesh day overlaps and keeps what falls inside it.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('LocalDays.utcDays', () {
    test('one Bangladesh day overlaps that UTC day and the one before', () {
      final days = LocalDays.utcDays(
        from: DateTime(2026, 11, 23),
        to: DateTime(2026, 11, 23),
      );
      expect(days.from, DateTime(2026, 11, 22));
      expect(days.to, DateTime(2026, 11, 23));
    });

    test('a range across months and years', () {
      final month = LocalDays.utcDays(
        from: DateTime(2026, 12),
        to: DateTime(2026, 12, 31),
      );
      expect(month.from, DateTime(2026, 11, 30));
      expect(month.to, DateTime(2026, 12, 31));
      final year = LocalDays.utcDays(from: DateTime(2027), to: DateTime(2027));
      expect(year.from, DateTime(2026, 12, 31));
      expect(year.to, DateTime(2027));
    });

    test('an open side stays open', () {
      expect(LocalDays.utcDays(from: DateTime(2026, 11, 23)).to, isNull);
      expect(LocalDays.utcDays(to: DateTime(2026, 11, 23)).from, isNull);
    });
  });

  group('LocalDays.contains', () {
    final day = DateTime(2026, 11, 23);
    bool on(DateTime instant, DateTime d) =>
        LocalDays.contains(instant, from: d, to: d);

    test('01:00 in Dhaka on the 23rd is the 22nd in UTC, and in the 23rd', () {
      final instant = DateTime.utc(2026, 11, 22, 19);
      expect(on(instant, day), isTrue);
      expect(on(instant, DateTime(2026, 11, 22)), isFalse);
    });

    test('the Bangladesh day runs from 18:00 UTC the day before to 18:00', () {
      expect(on(DateTime.utc(2026, 11, 22, 18), day), isTrue);
      expect(on(DateTime.utc(2026, 11, 22, 17, 59, 59), day), isFalse);
      expect(on(DateTime.utc(2026, 11, 23, 17, 59, 59), day), isTrue);
      expect(on(DateTime.utc(2026, 11, 23, 18), day), isFalse);
    });

    test('a range includes both ends; an open side has no limit', () {
      final instant = DateTime.utc(2026, 11, 25, 10);
      expect(
        LocalDays.contains(
          instant,
          from: DateTime(2026, 11, 23),
          to: DateTime(2026, 11, 25),
        ),
        isTrue,
      );
      expect(LocalDays.contains(instant, from: DateTime(2026, 11, 23)), isTrue);
      expect(LocalDays.contains(instant, to: DateTime(2026, 11, 24)), isFalse);
      expect(LocalDays.contains(instant), isTrue);
    });
  });

  // Rows come newest first (guide §4.5, §5): one older than the first day
  // means none after it can be inside the days chosen.
  group('LocalDays.beforeFirstDay', () {
    test('before 00:00 in Dhaka on the first day', () {
      final from = DateTime(2026, 11, 23);
      expect(
        LocalDays.beforeFirstDay(DateTime.utc(2026, 11, 22, 17, 59), from),
        isTrue,
      );
      expect(
        LocalDays.beforeFirstDay(DateTime.utc(2026, 11, 22, 18), from),
        isFalse,
      );
    });

    test('no first day: never before it', () {
      expect(LocalDays.beforeFirstDay(DateTime.utc(2000), null), isFalse);
    });
  });
}
