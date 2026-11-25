import 'package:ziska_verify/core/errors/failure_reason.dart';

/// The reasons logging in fails in the app itself, not at the server
/// (production audit P-24).
enum AuthReason implements FailureReason {
  /// A code was entered with no login waiting for one.
  noChallenge,

  /// The phone ID could not be read or made (final.md §6).
  phoneId,

  /// The login answer lacks what its `status` needs (§6).
  loginAnswer,

  /// "Role not found." on sending a request: the role can no longer be
  /// asked for (guide §3.9).
  roleGone,
}
