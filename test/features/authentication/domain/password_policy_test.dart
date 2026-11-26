import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';

void main() {
  const policy = PasswordPolicy();

  // The examples of the app API guide §3.6 and build guide step 2.
  final cases = <(String, bool, String)>[
    ('abcd1234', true, 'letters and numbers, 8 long'),
    ('12345678', false, 'no letter'),
    ('password', false, 'no number'),
    ('abc123', false, 'only 6 characters'),
    ('a2345678', true, 'one letter is enough'),
    ('password1', true, 'one number is enough'),
    ('পাসওয়ার্ড১', true, 'Bangla letters and a Bangla digit'),
    ('my pass 1!', true, 'spaces and symbols are allowed'),
    ('abcd\t1234', false, 'a tab is refused'),
    ('abcd\n1234', false, 'a line break is refused'),
    ('a1${'x' * 126}', true, '128 characters'),
    ('a1${'x' * 127}', false, '129 characters'),
  ];

  for (final (password, valid, why) in cases) {
    // TC-AUTH-016: Weak passwords are stopped.
    // TC-AUTH-017: Bangla password accepted.
    test('${valid ? 'accepts' : 'refuses'}: $why', () {
      expect(policy.check(password).isValid, valid);
    });
  }

  // docs/test-cases/01-auth.md, boundaries of the rule.
  group('TC-AUTH-069 … -074', () {
    test('TC-AUTH-069 7 characters fail the length, 8 pass', () {
      expect(policy.check('abcd123').hasLength, isFalse);
      expect(policy.check('abcd1234').isValid, isTrue);
    });

    test('TC-AUTH-070 128 characters pass, 129 fail', () {
      expect(policy.check('a1${'x' * 126}').isValid, isTrue);
      expect(policy.check('a1${'x' * 127}').hasLength, isFalse);
    });

    test('TC-AUTH-071 characters are counted, not bytes', () {
      // 7 Bangla characters (21 bytes in UTF-8).
      expect(policy.check('অআইঈউ১২').hasLength, isFalse);
      // 7 characters, 4 of them emoji (UTF-16 surrogate pairs).
      expect(policy.check('abc1😀😀😀').hasLength, isFalse);
      expect(policy.check('abc1😀😀😀😀').hasLength, isTrue);
    });

    test('TC-AUTH-072 control characters are refused', () {
      for (final p in ['abcd\t1234', 'abcd\n1234', 'abcd\r1234']) {
        expect(policy.check(p).isValid, isFalse, reason: p);
      }
      // NUL, DEL, and the C1 next-line character too.
      for (final code in [0x00, 0x7F, 0x85]) {
        final p = 'abcd${String.fromCharCode(code)}1234';
        expect(policy.check(p).isValid, isFalse, reason: 'U+$code');
      }
    });

    test('TC-AUTH-073 spaces and symbols are allowed', () {
      expect(policy.check('pass word 1').isValid, isTrue);
      expect(policy.check('P@ss w0rd!').isValid, isTrue);
    });

    test('TC-AUTH-074 symbols and a number only have no letter', () {
      final check = policy.check(r'!@#$%^&1');
      expect(check.hasLetter, isFalse);
      expect(check.isValid, isFalse);
    });
  });

  // TC-AUTH-015: Password rules tick live.
  test('reports each rule separately for the live ticks', () {
    final check = policy.check('abc');
    expect(check.hasLength, isFalse);
    expect(check.hasLetter, isTrue);
    expect(check.hasNumber, isFalse);
  });
}
