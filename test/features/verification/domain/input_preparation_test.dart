import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/services/code_normalizer.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_link_parser.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

/// The formats of the Postman example (`GET formats`).
const formats = InputFormats(
  hiddenCodes: [CodeFormat(length: 12, characters: '0123456789')],
  serialMaxDigits: 19,
  qr: CodeFormat(
    length: 12,
    characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  ),
);

void main() {
  group('QrLinkParser', () {
    const parser = QrLinkParser();
    final cases = <(String, String?)>[
      ('https://www.ziskaverify.com/q/Q8F2KD91XA7M', 'Q8F2KD91XA7M'),
      ('https://other-host.example/q/Q8F2KD91XA7M', 'Q8F2KD91XA7M'),
      ('https://a.example/q/x/q/Q8F2KD91XA7M', 'Q8F2KD91XA7M'),
      ('https://a.example/q/Q8F2KD91XA7M?utm=1', 'Q8F2KD91XA7M'),
      ('https://a.example/q/Q8F2KD91XA7M/', 'Q8F2KD91XA7M'),
      ('  https://a.example/q/Q8F2KD91XA7M  ', 'Q8F2KD91XA7M'),
      ('https://a.example/product/123', null),
      ('Q8F2KD91XA7M', null),
      ('https://a.example/q/', null),
    ];
    for (final (input, expected) in cases) {
      test('"$input" → $expected', () {
        expect(parser.parse(input), expected);
      });
    }
  });

  group('CodeNormalizer', () {
    const normalizer = CodeNormalizer();
    test('removes spaces and dashes and reads lower case as capitals', () {
      expect(normalizer.normalize(' 4815 1623-4200 '), '481516234200');
      expect(normalizer.normalize('q8f2kd91xa7m'), 'Q8F2KD91XA7M');
    });
  });

  group('InputFormatValidator', () {
    const validator = InputFormatValidator();
    final cases = <(LookupWay, String, InputProblem?)>[
      (LookupWay.serial, '1000001', null),
      (LookupWay.serial, '1' * 19, null),
      (LookupWay.serial, '1' * 20, InputProblem.wrongFormat),
      (LookupWay.serial, '10A1', InputProblem.wrongFormat),
      (LookupWay.serial, '', InputProblem.empty),
      (LookupWay.hiddenCode, '481516234200', null),
      (LookupWay.hiddenCode, '48151623420', InputProblem.wrongFormat),
      (LookupWay.hiddenCode, '48151623420A', InputProblem.wrongFormat),
      (LookupWay.qr, 'Q8F2KD91XA7M', null),
      (LookupWay.qr, 'Q8F2KD91XA7', InputProblem.wrongFormat),
    ];
    for (final (way, value, expected) in cases) {
      test('$way "$value" → $expected', () {
        expect(validator.validate(way, value, formats), expected);
      });
    }

    test('any of several hidden code formats is accepted', () {
      const two = InputFormats(
        hiddenCodes: [
          CodeFormat(length: 12, characters: '0123456789'),
          CodeFormat(length: 8, characters: 'ABCDEF0123456789'),
        ],
        serialMaxDigits: 10,
        qr: CodeFormat(length: 12, characters: 'ABC'),
      );
      expect(validator.validate(LookupWay.hiddenCode, 'ABCD1234', two), isNull);
    });
  });

  group('PrepareInput', () {
    const prepare = PrepareInput();

    test('a QR link sends only the value after /q/', () {
      final out = prepare(
        LookupWay.qr,
        'https://www.ziskaverify.com/q/q8f2kd91xa7m',
        formats,
      );
      expect(out, isA<ReadyInput>());
      expect((out as ReadyInput).value, 'Q8F2KD91XA7M');
    });

    test('a QR that is not a product link is refused', () {
      final out = prepare(LookupWay.qr, 'https://example.com/menu', formats);
      expect(out, isA<RefusedInput>());
    });

    test('a typed hidden code is normalized before checking', () {
      final out = prepare(LookupWay.hiddenCode, '4815 1623 4200', formats);
      expect((out as ReadyInput).value, '481516234200');
    });
  });

  // docs/test-cases/04-lookup.md and 11-security.md: every input boundary.
  group('Input boundaries (TC-LOOK-023 … -042, TC-SEC-016, -017)', () {
    const prepare = PrepareInput();
    const other = InputFormats(
      hiddenCodes: [
        CodeFormat(length: 12, characters: '0123456789'),
        CodeFormat(
          length: 8,
          characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
        ),
      ],
      serialMaxDigits: 10,
      qr: CodeFormat(
        length: 12,
        characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
      ),
    );
    const qr = 'Q8F2KD91XA7M';

    // (case, way, raw, formats, value sent or null when refused)
    final cases = <(String, LookupWay, String, InputFormats, String?)>[
      ('LOOK-023', LookupWay.hiddenCode, '481516234200', other, '481516234200'),
      ('LOOK-023', LookupWay.hiddenCode, 'AB12CD34', other, 'AB12CD34'),
      ('LOOK-023', LookupWay.hiddenCode, '4815162342', other, null),
      ('LOOK-024', LookupWay.serial, '1234567890', other, '1234567890'),
      ('LOOK-024', LookupWay.serial, '12345678901', other, null),
      ('LOOK-026', LookupWay.serial, '7', formats, '7'),
      ('LOOK-027', LookupWay.serial, '9' * 19, formats, '9' * 19),
      ('LOOK-028', LookupWay.serial, '0001000001', formats, '0001000001'),
      ('LOOK-029', LookupWay.serial, '1000 001', formats, '1000001'),
      ('LOOK-029', LookupWay.serial, '1000-001', formats, '1000001'),
      ('LOOK-030', LookupWay.serial, '10O0001', formats, null),
      ('LOOK-031', LookupWay.serial, '', formats, null),
      ('LOOK-032', LookupWay.serial, '0', formats, '0'),
      ('LOOK-033', LookupWay.hiddenCode, '4' * 11, formats, null),
      ('LOOK-033', LookupWay.hiddenCode, '4' * 13, formats, null),
      ('LOOK-034', LookupWay.hiddenCode, 'ab12cd34', other, 'AB12CD34'),
      ('LOOK-035', LookupWay.hiddenCode, '48151623420O', formats, null),
      (
        'LOOK-036',
        LookupWay.hiddenCode,
        '481516234200\n',
        formats,
        '481516234200',
      ),
      (
        'LOOK-036',
        LookupWay.hiddenCode,
        '481516\t234200',
        formats,
        '481516234200',
      ),
      ('LOOK-037', LookupWay.hiddenCode, '4' * 65, formats, null),
      (
        'LOOK-038',
        LookupWay.qr,
        'https://www.ziskaverify.com/q/$qr',
        formats,
        qr,
      ),
      (
        'LOOK-038',
        LookupWay.qr,
        'http://www.ziskaverify.com/q/$qr',
        formats,
        qr,
      ),
      ('LOOK-038', LookupWay.qr, 'https://example.org/q/$qr', formats, qr),
      ('LOOK-038', LookupWay.qr, 'https://a.example/q/$qr?utm=1', formats, qr),
      ('LOOK-038', LookupWay.qr, 'https://a.example/q/$qr#top', formats, qr),
      ('LOOK-038', LookupWay.qr, 'https://a.example/q/$qr/', formats, qr),
      (
        'LOOK-039',
        LookupWay.qr,
        'https://a.example/q/AAAAAAAAAAAA/q/$qr',
        formats,
        qr,
      ),
      (
        'LOOK-040',
        LookupWay.qr,
        'https://a.example/q/Q8F2KD91XA7',
        formats,
        null,
      ),
      (
        'LOOK-040',
        LookupWay.qr,
        'https://a.example/q/Q8F2KD91XA7MX',
        formats,
        null,
      ),
      (
        'LOOK-041',
        LookupWay.qr,
        'https://a.example/q/${qr.toLowerCase()}',
        formats,
        qr,
      ),
      ('LOOK-042', LookupWay.qr, qr, formats, null),
      ('SEC-016', LookupWay.qr, 'javascript:alert(1)/q/$qr', formats, qr),
      ('SEC-016', LookupWay.qr, 'x' * 4000, formats, null),
      ('SEC-016', LookupWay.qr, 'intent://scan/#Intent;end', formats, null),
      (
        'SEC-017',
        LookupWay.qr,
        'https://a.example/q/Q8F2KD91XA7Ｍ',
        formats,
        null,
      ),
      (
        'SEC-017',
        LookupWay.qr,
        'https://a.example/q/Q8F2KD91​XA7M',
        formats,
        null,
      ),
    ];

    for (final (id, way, raw, f, sent) in cases) {
      final shown =
          (raw.length > 50 ? '${raw.substring(0, 20)}… (${raw.length})' : raw)
              .replaceAll('\n', r'\n')
              .replaceAll('\t', r'\t');
      test(
        'TC-$id ${way.name} "$shown" → ${sent ?? 'refused'}',
        () {
          final out = prepare(way, raw, f);
          if (sent == null) {
            expect(out, isA<RefusedInput>());
          } else {
            expect(out, isA<ReadyInput>());
            expect((out as ReadyInput).value, sent);
          }
        },
      );
    }

    test(
      'TC-LOOK-040 a QR value of the wrong length is "not a product QR"',
      () {
        final out = prepare(
          LookupWay.qr,
          'https://a.example/q/Q8F2KD91XA7',
          formats,
        );
        expect((out as RefusedInput).notProductQr, isTrue);
      },
    );
  });
}
