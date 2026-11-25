import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

part 'serial_stack.freezed.dart';

const serialStackLimit = 50;

@freezed
abstract class SerialStackRow with _$SerialStackRow {
  const factory SerialStackRow({
    required String serial,
    required LookupResult result,
  }) = _SerialStackRow;
}

@freezed
abstract class SerialStackResult with _$SerialStackResult {
  const factory SerialStackResult({
    required SessionTotals session,
    required List<SerialStackRow> items,
  }) = _SerialStackResult;
}

/// A stack of serials as typed: split by commas, spaces or new lines, each
/// prepared like one serial, repeats kept once (app API guide §4.7).
@freezed
abstract class ParsedStack with _$ParsedStack {
  const factory ParsedStack({
    /// The serials sent, each once, in the order typed.
    required List<String> serials,

    /// How many values were typed, repeats included.
    required int typed,

    /// The first value that is not a serial, by its place (from 1).
    ({int position, String value})? bad,
  }) = _ParsedStack;

  const ParsedStack._();

  /// Values typed more than once, counted after preparing them, so
  /// "1000-001" and "1000001" are one serial.
  int get repeats => bad == null ? typed - serials.length : 0;

  /// The count shown as the stack is typed: its items, or every value
  /// typed while one is not a serial.
  int get counted => bad == null ? serials.length : typed;

  /// More than a stack holds ([serialStackLimit]).
  bool get tooMany => counted > serialStackLimit;
}
