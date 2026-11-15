import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/serial_input_formatter.dart';

void main() {
  const formatter = SerialInputFormatter();

  TextEditingValue value(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  String type(String before, String char) =>
      formatter.formatEditUpdate(value(before), value(before + char)).text;

  test('TC-LOOK-002 a typed letter does not enter', () {
    expect(type('100', 'a'), '100');
    expect(type('100', 'O'), '100');
  });

  test('typed digits, spaces, and dashes enter', () {
    expect(type('100', '1'), '1001');
    expect(type('100', ' '), '100 ');
    expect(type('100', '-'), '100-');
  });

  test('TC-LOOK-030 a paste is kept as it is, to be refused', () {
    expect(
      formatter.formatEditUpdate(value(''), value('10O0001')).text,
      '10O0001',
    );
  });
}
