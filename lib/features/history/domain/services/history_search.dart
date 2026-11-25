import 'package:ziska_verify/core/utils/ascii_digits.dart';

enum SearchStatus {
  /// Nothing typed: no search.
  empty,

  /// A serial or a reference number: [HistorySearch.value] is sent.
  ok,

  /// Neither: never sent, as the server would answer 400 (finding F-4).
  refused,
}

/// What a History search sends. The search is "a serial or a reference
/// number"; any other value answers 400 (app API guide §5).
///
/// - A serial is read as everywhere (guide §4, "Reading a serial"): digits
///   only, leading zeros kept, up to 64 characters (longer is the 400).
/// - A reference number is `MA-<year>-<6+ digits>` (phase 4), sent in
///   capitals, however it was typed.
///
/// Other digits, such as Bangla `১২৩`, read as `0`–`9` first, as the app
/// does in every field (final.md §16). Pure Dart.
class HistorySearch {
  const HistorySearch._(this.status, [this.value]);

  factory HistorySearch.read(String typed) {
    final text = toAsciiDigits(typed.trim());
    if (text.isEmpty) return const HistorySearch._(SearchStatus.empty);
    if (_serial.hasMatch(text)) return HistorySearch._(SearchStatus.ok, text);
    final upper = text.toUpperCase();
    if (_reference.hasMatch(upper)) {
      return HistorySearch._(SearchStatus.ok, upper);
    }
    return const HistorySearch._(SearchStatus.refused);
  }

  /// The longest serial the backend reads; over it answers 400 (guide §4).
  static const maxSerialLength = 64;

  static final _serial = RegExp('^[0-9]{1,$maxSerialLength}\$');
  static final _reference = RegExp(r'^MA-[0-9]{4}-[0-9]{6,}$');

  final SearchStatus status;

  /// What is sent, when [status] is [SearchStatus.ok].
  final String? value;

  /// The serial searched for, when it is one (not a reference number): its
  /// tracking log is shown (final.md §13.4; production audit P-38).
  String? get serial {
    final v = value;
    return v != null && _serial.hasMatch(v) ? v : null;
  }
}
