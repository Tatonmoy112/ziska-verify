import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/services/code_normalizer.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_link_parser.dart';

class GetFormats {
  const GetFormats(this._repository);
  final VerificationRepository _repository;

  Future<Result<InputFormats>> call() => _repository.getFormats();
}

/// The checked input, ready to send, or the reason it was refused.
sealed class PreparedInput {
  const PreparedInput();
}

final class ReadyInput extends PreparedInput {
  const ReadyInput(this.way, this.value);
  final LookupWay way;
  final String value;
}

final class RefusedInput extends PreparedInput {
  const RefusedInput(this.way, this.problem);
  final LookupWay way;
  final InputProblem problem;

  /// A scanned QR that is not a product QR link.
  bool get notProductQr => way == LookupWay.qr;
}

/// Steps 2 to 4 of the lookup flow (final.md Section 13.1.2): parse a QR
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
      value = normalizer.normalize(parsed);
    } else {
      value = normalizer.normalize(raw);
    }
    final problem = validator.validate(way, value, formats);
    return problem == null
        ? ReadyInput(way, value)
        : RefusedInput(way, problem);
  }
}

class LookupItem {
  const LookupItem(this._repository);
  final VerificationRepository _repository;

  /// Sends a value [PrepareInput] accepted.
  Future<Result<LookupResult>> call(ReadyInput input) =>
      _repository.lookup(input.way, input.value);
}

class BulkLookup {
  const BulkLookup(this._repository);
  final VerificationRepository _repository;

  Future<Result<BulkOutcome>> call(List<BulkEntry> entries) =>
      _repository.bulkLookup(entries);
}
