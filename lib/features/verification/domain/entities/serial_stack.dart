import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

const serialStackLimit = 50;

class SerialStackRow {
  const SerialStackRow({required this.serial, required this.result});
  final String serial;
  final LookupResult result;
}

class SerialStackResult {
  const SerialStackResult({required this.session, required this.items});
  final SessionTotals session;
  final List<SerialStackRow> items;
}

/// A stack of serials as typed: split by commas, spaces or new lines, each
/// prepared like one serial, repeats kept once (app API guide §4.7).
class ParsedStack {
  const ParsedStack({
    required this.serials,
    required this.typed,
    this.bad,
  });

  /// The serials sent, each once, in the order typed.
  final List<String> serials;

  /// How many values were typed, repeats included.
  final int typed;

  /// The first value that is not a serial, by its place (from 1).
  final ({int position, String value})? bad;

  /// Values typed more than once, counted after preparing them, so
  /// "1000-001" and "1000001" are one serial.
  int get repeats => bad == null ? typed - serials.length : 0;

  /// The count shown as the stack is typed: its items, or every value
  /// typed while one is not a serial.
  int get counted => bad == null ? serials.length : typed;

  /// More than a stack holds ([serialStackLimit]).
  bool get tooMany => counted > serialStackLimit;
}
