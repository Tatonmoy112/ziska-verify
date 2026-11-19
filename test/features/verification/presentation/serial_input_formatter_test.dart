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

  test('TC-PROF-035 a typed Bangla digit enters as 0-9', () {
    expect(type('100', '১'), '1001');
    expect(type('', '০'), '0');
    expect(type('12', '৯'), '129');
    // In the middle of the text, the cursor kept.
    final out = formatter.formatEditUpdate(
      const TextEditingValue(
        text: '1200',
        selection: TextSelection.collapsed(offset: 2),
      ),
      const TextEditingValue(
        text: '12৫00',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    expect(out.text, '12500');
    expect(out.selection.baseOffset, 3);
  });

  test('a typed Bangla letter does not enter', () {
    expect(type('100', 'ক'), '100');
  });

  test('TC-LOOK-030 a paste is kept as it is, to be refused', () {
    expect(
      formatter.formatEditUpdate(value(''), value('10O0001')).text,
      '10O0001',
    );
  });
}
