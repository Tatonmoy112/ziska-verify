import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

part 'checked_input.freezed.dart';

/// The serial or QR value and response time shown with a result.
@freezed
abstract class CheckedInput with _$CheckedInput {
  /// A submitted serial or QR value; hidden-code input is not supported.
  const factory CheckedInput({
    required LookupWay way,
    required String shown,
    required DateTime at,
  }) = _CheckedInput;
}
