import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';

part 'prepared_input.freezed.dart';

/// The checked input, ready to send, or the reason it was refused.
@freezed
sealed class PreparedInput with _$PreparedInput {
  const factory PreparedInput.ready(LookupWay way, String value) = ReadyInput;

  const factory PreparedInput.refused(LookupWay way, InputProblem problem) =
      RefusedInput;
}

extension RefusedInputKind on RefusedInput {
  /// A scanned QR that is not a product QR link.
  bool get notProductQr => way == LookupWay.qr;
}
