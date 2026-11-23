import 'package:timezone/timezone.dart' as tz;
import 'package:ziska_verify/core/utils/display_time.dart';

/// Bangladesh calendar days over the backend's UTC days.
///
/// The backend's `from` and `to` are whole UTC days (guide §4.5 and §5),
/// and a Bangladesh day runs from 18:00 UTC the day before to 18:00 UTC.
/// To show a Bangladesh day, the app asks for the UTC days it overlaps and
/// keeps only what falls inside it, as the guide describes.
abstract final class LocalDays {
  /// The UTC calendar days that the Bangladesh days [from] to [to] (both
  /// included) overlap. A side left out stays open.
  static ({DateTime? from, DateTime? to}) utcDays({
    DateTime? from,
    DateTime? to,
  }) => (
    from: from == null ? null : _utcDate(_start(from)),
    to: to == null
        ? null
        : _utcDate(_start(_next(to)).subtract(const Duration(microseconds: 1))),
  );

  /// Whether [instant] falls inside the Bangladesh days [from] to [to], both
  /// included. A side left out is open.
  static bool contains(DateTime instant, {DateTime? from, DateTime? to}) {
    final at = instant.toUtc();
    if (from != null && at.isBefore(_start(from))) return false;
    if (to != null && !at.isBefore(_start(_next(to)))) return false;
    return true;
  }

  /// Whether [instant] is before the first Bangladesh day [from] starts.
  /// The backend's lists come newest first (guide §4.5, §5), so a row
  /// before it means no later row is inside the days chosen.
  static bool beforeFirstDay(DateTime instant, DateTime? from) =>
      from != null && instant.toUtc().isBefore(_start(from));

  /// 00:00 in Dhaka on [day]'s date, as a UTC instant.
  static DateTime _start(DateTime day) => tz.TZDateTime(
    tz.getLocation(DisplayTime.zone),
    day.year,
    day.month,
    day.day,
  ).toUtc();

  static DateTime _next(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  static DateTime _utcDate(DateTime instant) {
    final utc = instant.toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }
}
