import 'package:ziska_verify/core/errors/failure_reason.dart';

/// What a `404 not_found` on filing a report says is gone (guide §6.1;
/// production audit P-25). Without one, the route itself is gone.
enum IncidentReason implements FailureReason {
  /// "Check not found.": the check is not this official's, or not at all.
  checkGone,

  /// "Retail user not found.": unknown, blocked, or not a retail user.
  retailUserGone,
}
