import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// Where a lookup started: where **Try again** returns (final.md Section
/// 13.1.4).
enum ResultOrigin { verify, scanner, bulk }

/// Everything the result screen shows, passed as the route's `extra`
/// (final.md Sections 9.5, 13.1.4). Holds no secret: a hidden code is only
/// in [input] and only masked.
class ResultView {
  const ResultView({
    required this.result,
    required this.input,
    required this.origin,
    this.formats,
  });

  final LookupResult result;
  final CheckedInput input;
  final ResultOrigin origin;

  /// The client's formats, for the hints of a `not_found` result.
  final InputFormats? formats;
}
