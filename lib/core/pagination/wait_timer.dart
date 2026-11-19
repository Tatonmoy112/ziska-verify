import 'dart:async';

import 'package:clock/clock.dart';

/// Runs one action once a `429` wait has passed (guide section 1).
///
/// A new [schedule] replaces the one waiting, so taps during the wait end
/// in a single request. A timer may fire a little early, so the time is
/// checked again before the action runs.
class WaitTimer {
  Timer? _timer;

  void schedule(DateTime until, void Function() action) {
    _timer?.cancel();
    final left = until.difference(clock.now());
    _timer = Timer(left.isNegative ? Duration.zero : left, () {
      if (clock.now().isBefore(until)) {
        schedule(until, action);
      } else {
        action();
      }
    });
  }

  void cancel() => _timer?.cancel();
}
