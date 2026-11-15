import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/core/utils/display_time.dart';

/// History's "Today · 4:02 PM" (a narrow space before AM/PM, as intl writes it) (final.md Section 13.4): the day is counted
/// in Bangladesh time (UTC+6), whatever the phone's zone.
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting('en');
  });

  // 12:23 on 15 Nov 2026 in Bangladesh.
  final now = DateTime.utc(2026, 11, 15, 6, 23);

  String at(DateTime instant) => DisplayTime.dayAndTime(
    instant,
    'en',
    now: now,
    today: 'Today',
    yesterday: 'Yesterday',
  );

  test('TC-HIST-048 today, in Bangladesh time', () {
    expect(at(DateTime.utc(2026, 11, 15, 5)), 'Today · 11:00\u202fAM');
    // 00:30 on 15 Nov in Bangladesh, still 14 Nov in UTC.
    expect(at(DateTime.utc(2026, 11, 14, 18, 30)), 'Today · 12:30\u202fAM');
  });

  test('TC-HIST-048 yesterday, up to Bangladesh midnight', () {
    // 23:59 on 14 Nov in Bangladesh.
    expect(at(DateTime.utc(2026, 11, 14, 17, 59)), 'Yesterday · 11:59\u202fPM');
    expect(at(DateTime.utc(2026, 11, 13, 18)), 'Yesterday · 12:00\u202fAM');
  });

  test('TC-HIST-048 older days show the date', () {
    expect(at(DateTime.utc(2026, 11, 13, 10)), 'Nov 13, 2026 · 4:00\u202fPM');
    expect(at(DateTime.utc(2025, 12, 31, 20)), 'Jan 1, 2026 · 2:00\u202fAM');
  });
}
