import 'package:clock/clock.dart';

/// Which QR reads are new (guide §4.3: "Do not send the same QR twice in a
/// row while it stays in front of the camera"; production audit P-38).
/// The camera reports the same code many times a second; only a new code,
/// or the same one after a while, is a new read.
class QrReadFilter {
  QrReadFilter({this.window, this.afterResult});

  /// How long the same code is not read again. `null`: until another code
  /// is read (a scanner session).
  final Duration? window;

  /// How long the same code is not read again once its result closes; it
  /// also covers a slow camera start. [window] when `null`.
  final Duration? afterResult;

  String? _last;
  DateTime? _at;
  bool _closedResult = false;

  /// Whether [raw] is the last code again, still within its window.
  bool isRepeat(String raw) {
    if (raw != _last) return false;
    final hold = _closedResult ? (afterResult ?? window) : window;
    if (hold == null) return true;
    final at = _at;
    return at != null && clock.now().difference(at) < hold;
  }

  /// [raw] is the code now read.
  void take(String raw) {
    _last = raw;
    _at = clock.now();
    _closedResult = false;
  }

  /// Takes [raw] when it is a new read; `false` when it is not.
  bool accept(String raw) {
    if (isRepeat(raw)) return false;
    take(raw);
    return true;
  }

  /// The next read of any code is new (Scan again, a typed serial).
  void forget() {
    _last = null;
    _closedResult = false;
  }

  /// The last code's result just closed: its [afterResult] starts now.
  void resultClosed() {
    _at = clock.now();
    _closedResult = true;
  }
}
