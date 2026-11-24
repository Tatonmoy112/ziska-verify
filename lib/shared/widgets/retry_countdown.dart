import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

/// Rebuilds every second with the seconds left until [until]; once it has
/// passed, builds with 0 (final.md §14.1). Used for `Retry-After` and
/// the resend-code wait.
class RetryCountdown extends StatefulWidget {
  const RetryCountdown({
    required this.until,
    required this.builder,
    super.key,
  });

  final DateTime? until;
  final Widget Function(BuildContext context, int secondsLeft) builder;

  @override
  State<RetryCountdown> createState() => _RetryCountdownState();
}

class _RetryCountdownState extends State<RetryCountdown> {
  Timer? _timer;

  int get _secondsLeft {
    final until = widget.until;
    if (until == null) return 0;
    final left = until.difference(clock.now()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(RetryCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.until != widget.until) _start();
  }

  void _start() {
    _timer?.cancel();
    if (_secondsLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (_secondsLeft == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _secondsLeft);
}
