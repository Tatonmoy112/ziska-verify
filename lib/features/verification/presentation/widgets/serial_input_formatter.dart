import 'package:flutter/services.dart';

/// The serial field: a typed character other than a digit, a space, or `-`
/// does not enter. A paste is kept as it is, so a serial holding a letter
/// is refused by the input check, never silently changed into another
/// serial that would be looked up and recorded (final.md Section 13.1.2).
class SerialInputFormatter extends TextInputFormatter {
  const SerialInputFormatter();

  static final _typeable = RegExp(r'^[0-9 \-]$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final typed = newValue.text.length - oldValue.text.length == 1;
    if (!typed) return newValue;
    final at = newValue.selection.baseOffset - 1;
    if (at < 0 || at >= newValue.text.length) return newValue;
    return _typeable.hasMatch(newValue.text[at]) ? newValue : oldValue;
  }
}
