import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// Why an input was refused before sending.
enum InputProblem { empty, wrongFormat }

/// Checks a normalized value against the client's formats from
/// `GET formats` (final.md Section 13.1.3). Nothing is hard-coded.
class InputFormatValidator {
  const InputFormatValidator();

  /// The API refuses longer values (app API guide §4.2).
  static const maxLength = 64;

  /// A serial "accepts leading zeros and is read without them", at most 40
  /// characters (backend DEC-371; on the test server serial 1 padded to 40
  /// characters is item 1, padded to 41 is not found).
  static const serialMaxLength = 40;

  static final _digits = RegExp(r'^[0-9]+$');
  static final _leadingZeros = RegExp('^0+(?=.)');

  /// Returns `null` when [value] may be sent.
  InputProblem? validate(LookupWay way, String value, InputFormats formats) {
    if (value.isEmpty) return InputProblem.empty;
    if (value.length > maxLength) return InputProblem.wrongFormat;
    final ok = switch (way) {
      LookupWay.serial =>
        _digits.hasMatch(value) &&
            value.length <= serialMaxLength &&
            // The serial's own digits, its leading zeros left out.
            value.replaceFirst(_leadingZeros, '').length <=
                formats.serialMaxDigits,
      LookupWay.qr => _matches(value, formats.qr),
    };
    return ok ? null : InputProblem.wrongFormat;
  }

  static bool _matches(String value, CodeFormat format) =>
      value.length == format.length &&
      value.split('').every(format.characters.contains);
}
