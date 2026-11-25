/// Why the app itself failed something, as opposed to the server's
/// `message` (production audit P-24). Code compares reasons, never text:
/// a typo does not compile, and no server text can pass for one.
///
/// Each layer names its own reasons as an enum that implements this, so
/// the core never needs to know a feature's.
abstract interface class FailureReason {}

/// The core's own reasons.
enum CoreReason implements FailureReason {
  /// A field of the wrong type, or missing, found by a parser (`guard`).
  answerShape,

  /// An answer without the `{ success, … }` envelope (final.md §15).
  notEnvelope,

  /// The secure storage could not be written.
  storage,
}

/// An answer whose `data` is not of the shape its route documents
/// (`ApiData`, P-19). Two are acted on: [incidentId] (a report filed but
/// unreadable) and [verification] (a serial stack recorded but unreadable).
enum ApiAnswer implements FailureReason {
  auth,
  accessRoles,
  accessPending,
  me,
  checks,
  reports,
  retailUsers,
  incidentId,
  incidentN,
  verification,
  renewal,
}
