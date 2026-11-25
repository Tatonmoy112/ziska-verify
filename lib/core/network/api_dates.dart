/// The API's days and times, read and written in one place (app API guide
/// §1; production audit P-42): times are ISO 8601 with their offset, days
/// `YYYY-MM-DD`. A value of another form is a `FormatException`, which
/// `guard` turns into a wrong answer, as for every other field (final.md
/// §6).
abstract final class ApiDates {
  /// A time of an answer, in UTC. One without its offset would be read in
  /// the phone's zone, so it is refused.
  static DateTime instant(String text) {
    final time = DateTime.parse(text);
    if (!time.isUtc) {
      throw FormatException('A time without its offset', text);
    }
    return time;
  }

  /// A calendar day of an answer, such as a batch's expiry.
  static DateTime day(String text) {
    final m = _day.firstMatch(text);
    if (m == null) throw FormatException('Not a YYYY-MM-DD day', text);
    final [y, mo, d] = [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
    final day = DateTime(y, mo, d);
    if (day.year != y || day.month != mo || day.day != d) {
      throw FormatException('Not a calendar day', text);
    }
    return day;
  }

  /// A day for a query (`from`, `to`), in Latin digits.
  static String dayText(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${_two(day.month)}-${_two(day.day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  static final _day = RegExp(r'^([0-9]{4})-([0-9]{2})-([0-9]{2})$');
}
