import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/logging/log_redactor.dart';

void main() {
  // TC-SEC-002: Secrets never logged.
  group('LogRedactor', () {
    test('removes bearer passes', () {
      expect(
        LogRedactor.redact('Authorization: Bearer eyJabc.def-ghi_jk'),
        'Authorization: Bearer ***',
      );
    });

    test('removes secret JSON fields', () {
      final out = LogRedactor.redact(
        '{"password":"hunter2","refresh_token":"Xk2","phone_id":"Qm9",'
        '"value":"481516234200","email":"a@b.c"}',
      );
      expect(out, isNot(contains('hunter2')));
      expect(out, isNot(contains('Xk2')));
      expect(out, isNot(contains('Qm9')));
      expect(out, isNot(contains('481516234200')));
      expect(out, contains('a@b.c'));
    });

    test('removes 6-digit emailed codes', () {
      expect(LogRedactor.redact('code 123456 sent'), 'code *** sent');
    });

    test('keeps request ids and routes', () {
      const line = 'GET checks → 400 (request_id 6f1c-ab)';
      expect(LogRedactor.redact(line), line);
    });
  });
}
