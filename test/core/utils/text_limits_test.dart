import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/utils/text_limits.dart';

/// Every length counts Unicode code points: an emoji counts as one (backend
/// DEC-429; guide §1).
void main() {
  group('TextLimits.fitCodePoints', () {
    test('text within the limit is kept as it is', () {
      expect(TextLimits.fitCodePoints('', 3), '');
      expect(TextLimits.fitCodePoints('abc', 3), 'abc');
      expect(TextLimits.fitCodePoints('ab🙂', 3), 'ab🙂');
      expect(TextLimits.fitCodePoints('🙂🙂🙂', 3), '🙂🙂🙂');
    });

    test('longer text is cut after the limit, at a whole character', () {
      expect(TextLimits.fitCodePoints('abcd', 3), 'abc');
      expect(TextLimits.fitCodePoints('🙂🙂🙂🙂', 3), '🙂🙂🙂');
      expect(TextLimits.fitCodePoints('কখগঘ', 3), 'কখগ');
    });
  });
}
