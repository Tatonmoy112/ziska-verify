import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/services/prepare_input.dart';
import 'package:ziska_verify/features/verification/domain/services/serial_key.dart';

/// Splits a typed stack by commas, spaces or new lines and prepares each
/// value like one serial (app API guide §4.7).
class ParseStack {
  const ParseStack([this._prepare = const PrepareInput()]);
  final PrepareInput _prepare;

  ParsedStack call(String text, InputFormats formats) {
    final serials = <String>[];
    final tokens = text
        .split(RegExp(r'[,\s]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    for (final (index, token) in tokens.indexed) {
      final input = _prepare(LookupWay.serial, token, formats);
      if (input is! ReadyInput) {
        return ParsedStack(
          serials: serials,
          typed: tokens.length,
          bad: (position: index + 1, value: token),
        );
      }
      if (!serials.any((s) => sameSerial(s, input.value))) {
        serials.add(input.value);
      }
    }
    return ParsedStack(serials: serials, typed: tokens.length);
  }
}
