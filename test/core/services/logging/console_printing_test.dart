import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:ziska_verify/core/services/logging/console_logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

class _Lines extends LogOutput {
  final lines = <String>[];

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}

class _Crash implements CrashReportingService {
  final logs = <String>[];
  final errors = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  void log(String message) => logs.add(message);

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) =>
      errors.add('$error');
}

class _Unprintable implements Exception {
  @override
  String toString() => throw StateError('no text');
}

/// TC-SEC-034 … -036 (docs/test-cases/11-security.md): a release build
/// prints nothing to the phone's log, by the app's own switch rather than
/// a package default any code could change (final.md §12; production audit
/// P-12). A debug build prints, its lines redacted.
void main() {
  late _Lines out;
  late _Crash crash;
  setUp(() {
    out = _Lines();
    crash = _Crash();
  });

  ConsoleLoggerService logger({bool printing = false, bool verbose = false}) =>
      ConsoleLoggerService(
        crash,
        output: out,
        printing: printing,
        verbose: verbose,
      );

  const answer = FormatException('bad', '{"value":"Q8F2KD91XA7M"}');

  void everyKind(ConsoleLoggerService l) => l
    ..debug('debug 482913')
    ..info('info Bearer eyJhbGciOiJIUzI1NiJ9')
    ..warning('warning', error: answer)
    ..error('error', error: answer, stackTrace: StackTrace.current);

  group('TC-SEC-034 normal: a release build prints nothing', () {
    test('no line of any kind, errors included', () {
      everyKind(logger());
      expect(out.lines, isEmpty);
    });

    test('crash reporting still gets what it gets', () {
      everyKind(logger());
      expect(crash.logs, ['warning']);
      expect(crash.errors, ['FormatException']);
    });
  });

  group('TC-SEC-035 edge: nothing changes it but the app', () {
    tearDown(() => Logger.defaultFilter = DevelopmentFilter.new);

    test("the package's global default set to print everywhere", () {
      Logger.defaultFilter = ProductionFilter.new;
      Logger.level = Level.trace;
      addTearDown(() => Logger.level = Level.trace);
      everyKind(logger());
      expect(out.lines, isEmpty);
    });

    test('verbose alone does not print', () {
      everyKind(logger(verbose: true));
      expect(out.lines, isEmpty);
    });
  });

  group('TC-SEC-036 a debug build prints, redacted, and never throws', () {
    test('lines are redacted; debug lines only when verbose', () {
      everyKind(logger(printing: true));
      final text = out.lines.join('\n');
      expect(text, isNot(contains('482913')));
      expect(text, isNot(contains('eyJhbGciOiJIUzI1NiJ9')));
      expect(text, contains('info Bearer ***'));
      expect(text, isNot(contains('debug')), reason: 'not verbose');

      out.lines.clear();
      logger(printing: true, verbose: true).debug('debug 482913');
      expect(out.lines.join('\n'), contains('debug ***'));
    });

    test("a developer's build shows the error itself", () {
      logger(printing: true).error('error', error: answer);
      expect(out.lines.join('\n'), contains('FormatException'));
    });

    test('an error whose text cannot be read: printed without it', () {
      final l = logger(printing: true);
      expect(() => l.error('uncaught', error: _Unprintable()), returnsNormally);
      expect(
        () => l.warning('odd', error: _Unprintable()),
        returnsNormally,
      );
      expect(out.lines.join('\n'), contains('uncaught'));
    });
  });
}
