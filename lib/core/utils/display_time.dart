import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Times are shown in Bangladesh time whatever the phone's time zone
/// (ProtectB DEC-205; final.md Section 16). `timezone` data is loaded in
/// `bootstrap`.
abstract final class DisplayTime {
  static const zone = 'Asia/Dhaka';

  static tz.TZDateTime inZone(DateTime instant) =>
      tz.TZDateTime.from(instant, tz.getLocation(zone));

  /// For example "12 Oct 2026, 3:14 PM".
  static String dateTime(DateTime instant, String locale) =>
      DateFormat.yMMMd(locale).add_jm().format(inZone(instant));

  /// With the offset: "2026-10-12 15:14 +06:00".
  static String withOffset(DateTime instant) {
    final local = inZone(instant);
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final h = offset.inHours.abs().toString().padLeft(2, '0');
    final m = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${DateFormat('yyyy-MM-dd HH:mm').format(local)} $sign$h:$m';
  }

  /// "Today · 4:02 PM", "Yesterday · 9:08 AM", or "Oct 12, 2026 · 3:14 PM":
  /// the day counted in Bangladesh time against [now].
  static String dayAndTime(
    DateTime instant,
    String locale, {
    required DateTime now,
    required String today,
    required String yesterday,
  }) {
    final at = inZone(instant);
    final here = inZone(now);
    final day = DateTime.utc(at.year, at.month, at.day);
    final todayDay = DateTime.utc(here.year, here.month, here.day);
    final days = todayDay.difference(day).inDays;
    final dayText = switch (days) {
      0 => today,
      1 => yesterday,
      _ => DateFormat.yMMMd(locale).format(at),
    };
    return '$dayText · ${DateFormat.jm(locale).format(at)}';
  }

  /// A `YYYY-MM-DD` date from the API (no time, no zone).
  static String date(DateTime date, String locale) =>
      DateFormat.yMMMd(locale).format(date);
}
