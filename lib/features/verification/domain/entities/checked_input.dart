import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// A hidden code as the app shows it everywhere: `*****` and its last 3
/// characters, like the API's `item.code` (final.md Section 12.1; backend
/// D14). The full code is never shown beyond the input field.
String maskHiddenCode(String code) =>
    '*****${code.length > 3 ? code.substring(code.length - 3) : code}';

/// What an official looked up, as the result screen shows it (final.md
/// Section 13.1.4): the way, the value as sent (a hidden code only masked),
/// and when the answer came.
class CheckedInput {
  /// [shown] is already safe to show (a hidden code masked).
  const CheckedInput({
    required this.way,
    required this.shown,
    required this.at,
  });

  /// From the value as sent: a hidden code is masked here, so the full code
  /// is never kept.
  factory CheckedInput.of(LookupWay way, String value, DateTime at) =>
      CheckedInput(
        way: way,
        shown: way == LookupWay.hiddenCode ? maskHiddenCode(value) : value,
        at: at,
      );

  final LookupWay way;
  final String shown;
  final DateTime at;
}
