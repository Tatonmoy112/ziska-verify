import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// Why an input was refused before sending.
enum InputProblem { empty, wrongFormat }

/// Checks a normalized value against the client's formats from
/// `GET formats` (final.md Section 13.1.3). Nothing is hard-coded.
class InputFormatValidator {
  const InputFormatValidator();

  /// The API refuses longer values (app API guide §4.2).
  static const maxLength = 64;

  static final _digits = RegExp(r'^[0-9]+$');

  /// Returns `null` when [value] may be sent.
  InputProblem? validate(LookupWay way, String value, InputFormats formats) {
    if (value.isEmpty) return InputProblem.empty;
    if (value.length > maxLength) return InputProblem.wrongFormat;
    final ok = switch (way) {
      LookupWay.serial =>
        _digits.hasMatch(value) && value.length <= formats.serialMaxDigits,
      LookupWay.hiddenCode => formats.hiddenCodes.any(
        (f) => _matches(value, f),
      ),
      LookupWay.qr => _matches(value, formats.qr),
    };
    return ok ? null : InputProblem.wrongFormat;
  }

  static bool _matches(String value, CodeFormat format) =>
      value.length == format.length &&
      value.split('').every(format.characters.contains);
}
