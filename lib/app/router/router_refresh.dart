import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tells the router to run its guard again whenever the session state or
/// the profile changes (final.md Section 9.4).
class RouterRefresh extends ChangeNotifier {
  RouterRefresh(List<Stream<Object?>> streams) {
    _subscriptions = [
      for (final stream in streams) stream.listen((_) => notifyListeners()),
    ];
  }

  late final List<StreamSubscription<Object?>> _subscriptions;

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }
}
