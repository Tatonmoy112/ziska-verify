import 'package:ziska_verify/core/errors/failure_reason.dart';

/// The reasons a check fails in the app itself, not at the server
/// (production audit P-24).
enum VerificationReason implements FailureReason {
  /// A scan answered for another session than the one it was sent in.
  sessionMismatch,

  /// A typed serial that is not one (the serial is named on screen).
  serialInput,

  /// A stack of no serial, or more than `serialStackLimit`.
  serialStackSize,

  /// A stack was recorded, but its answer could not be read or does not
  /// match what was sent: never sent again (final.md §13.3).
  serialStackMismatch,

  /// A scanned QR that is not a code the app reads.
  scanInput,

  /// The open scan session could not be kept on the phone.
  scanStorage,
}
