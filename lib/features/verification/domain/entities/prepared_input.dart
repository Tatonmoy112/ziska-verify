import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';

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
