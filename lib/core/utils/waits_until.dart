import 'package:clock/clock.dart';

/// Whether a wait is still running: [until] (a 429's `Retry-After`, or
/// when a new code may be asked for) is set and not yet reached
/// (production audit P-42: written once, for every state and bloc that
/// holds a wait). [now] is the bloc's own clock
/// when it takes one.
bool waitsUntil(DateTime? until, {DateTime? now}) =>
    until != null && (now ?? clock.now()).isBefore(until);
