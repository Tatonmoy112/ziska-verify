import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// The serial or QR value and response time shown with a result.
class CheckedInput {
  /// A submitted serial or QR value; hidden-code input is not supported.
  const CheckedInput({
    required this.way,
    required this.shown,
    required this.at,
  });

  /// Preserve the value as sent, including serial leading zeros.
  factory CheckedInput.of(LookupWay way, String value, DateTime at) =>
      CheckedInput(
        way: way,
        shown: value,
        at: at,
      );

  final LookupWay way;
  final String shown;
  final DateTime at;
}
