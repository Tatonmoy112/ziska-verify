import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/utils/text_limits.dart';

void main() {
  group('TextLimits.fitUtf16', () {
    test('text within the limit is kept as it is', () {
      expect(TextLimits.fitUtf16('', 3), '');
      expect(TextLimits.fitUtf16('abc', 3), 'abc');
      expect(TextLimits.fitUtf16('a🙂', 3), 'a🙂');
    });

    test('longer text is cut at a whole character', () {
      expect(TextLimits.fitUtf16('abcd', 3), 'abc');
      expect(TextLimits.fitUtf16('ab🙂', 3), 'ab');
      expect(TextLimits.fitUtf16('🙂🙂', 3), '🙂');
      expect(TextLimits.fitUtf16('কখগঘ', 3), 'কখগ');
    });
  });
}
