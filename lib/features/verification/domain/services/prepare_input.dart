import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/services/code_normalizer.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_link_parser.dart';

/// Steps 2 to 4 of the lookup flow (final.md §13.1): parse a QR
/// link, normalize, and check against the client's formats.
class PrepareInput {
  const PrepareInput({
    this.parser = const QrLinkParser(),
    this.normalizer = const CodeNormalizer(),
    this.validator = const InputFormatValidator(),
  });

  final QrLinkParser parser;
  final CodeNormalizer normalizer;
  final InputFormatValidator validator;

  PreparedInput call(LookupWay way, String raw, InputFormats formats) {
    final String value;
    if (way == LookupWay.qr) {
      final parsed = parser.parse(raw);
      if (parsed == null) {
        return const RefusedInput(LookupWay.qr, InputProblem.wrongFormat);
      }
      // The QR value is sent as read (guide section 4): only the spaces
      // around it go; the formats' characters decide whether it is valid.
      value = parsed.trim();
    } else {
      value = normalizer.normalize(raw);
    }
    final problem = validator.validate(way, value, formats);
    return problem == null
        ? ReadyInput(way, value)
        : RefusedInput(way, problem);
  }
}
