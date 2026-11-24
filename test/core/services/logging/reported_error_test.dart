import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/services/logging/console_logger_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// What crash reporting records, from the phone of an official.
class _Recorded implements CrashReportingService {
  final logs = <String>[];
  final errors = <(Object, StackTrace?, String?)>[];

  @override
  Future<void> initialize() async {}

  @override
  void log(String message) => logs.add(message);

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) =>
      errors.add((error, stackTrace, reason));
}

class _Unprintable implements Exception {
  @override
  String toString() => throw StateError('no text');
}

/// TC-SEC-032 (docs/test-cases/11-security.md): what leaves the phone for
/// crash reporting holds no lookup value, answer, address, code or pass
/// (final.md §12; production audit P-10). An error's own text can hold any
/// of them (a `FormatException` quotes the answer it could not read), so
/// only its type goes, with an app error's code, status and reference.
void main() {
  late _Recorded crash;
  late ConsoleLoggerService logger;
  setUp(() {
    crash = _Recorded();
    logger = ConsoleLoggerService(crash);
  });

  /// Texts that must never leave the phone.
  const secrets = [
    '1000001',
    'Q8F2KD91XA7M',
    'asha@example.com',
    '482913',
    'eyJhbGciOiJIUzI1NiJ9',
    'Rahim Store',
  ];

  void expectClean(String text) {
    for (final s in secrets) {
      expect(text, isNot(contains(s)), reason: 'sent: $text');
    }
  }

  test('a FormatException goes as its type only', () {
    final stack = StackTrace.current;
    logger.error(
      'uncaught error',
      error: const FormatException(
        'Unexpected character',
        '{"serial":"1000001","value":"Q8F2KD91XA7M","name":"Rahim Store"}',
      ),
      stackTrace: stack,
    );
    final (error, sentStack, reason) = crash.errors.single;
    expect(error.toString(), 'FormatException');
    expect(identical(sentStack, stack), isTrue, reason: 'the stack is kept');
    expect(reason, 'uncaught error');
  });

  test('an app error keeps its code, status and reference, not the '
      "server's message", () {
    logger.error(
      'checks failed',
      error: const RateLimitedException(
        retryAfter: Duration(seconds: 30),
        statusCode: 429,
        code: 'rate_limited',
        requestId: 'req-429',
        message: 'Too many checks by asha@example.com for 1000001',
      ),
    );
    final text = crash.errors.single.$1.toString();
    expect(
      text,
      'RateLimitedException(code: rate_limited, status: 429, '
      'request: req-429)',
    );
    expectClean(text);
  });

  test('any other error, even a layout error naming text on screen', () {
    logger
      ..error(
        'flutter error',
        error: AssertionError('Text("1000001") overflowed by 12 pixels'),
      )
      ..error('flutter error', error: StateError('code 482913 for Asha'))
      ..error('flutter error', error: 'Bearer eyJhbGciOiJIUzI1NiJ9 raw');
    expect(crash.errors.map((e) => e.$1.toString()), [
      'AssertionError',
      'StateError',
      'String',
    ]);
    for (final (error, _, reason) in crash.errors) {
      expectClean('$error $reason');
    }
  });

  test('an error whose text cannot even be read: still its type', () {
    logger.error('uncaught error', error: _Unprintable());
    expect(crash.errors.single.$1.toString(), '_Unprintable');
  });

  test('no error object: the app-written line goes, redacted', () {
    logger.error('code 482913 rejected; Bearer eyJhbGciOiJIUzI1NiJ9');
    final (error, _, reason) = crash.errors.single;
    expectClean('$error $reason');
    expect(error.toString(), 'code *** rejected; Bearer ***');
  });

  test('a warning sends its redacted line, never its error', () {
    logger.warning(
      'phone ID not readable: code 482913',
      error: const FormatException('{"value":"Q8F2KD91XA7M"}'),
    );
    expect(crash.errors, isEmpty);
    expect(crash.logs, ['phone ID not readable: code ***']);
    expectClean(crash.logs.single);
  });

  test('ReportedError is what crash reporting receives', () {
    logger.error('x', error: const FormatException('1000001'));
    expect(crash.errors.single.$1, isA<ReportedError>());
  });
}
