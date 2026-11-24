import 'package:logger/logger.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// [LoggerService] on the `logger` package. Every line is redacted; warnings
/// and errors are also sent to crash reporting, an error as a
/// [ReportedError].
class ConsoleLoggerService implements LoggerService {
  ConsoleLoggerService(this._crash, {Logger? logger, bool verbose = false})
    : _logger =
          logger ??
          Logger(
            level: verbose ? Level.debug : Level.info,
            printer: SimplePrinter(printTime: true),
          );

  final CrashReportingService _crash;
  final Logger _logger;

  @override
  void debug(String message) => _logger.d(LogRedactor.redact(message));

  @override
  void info(String message) => _logger.i(LogRedactor.redact(message));

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    final line = LogRedactor.redact(message);
    _crash.log(line);
    _print(
      () => _logger.w(line, error: error, stackTrace: stackTrace),
      () => _logger.w(line, stackTrace: stackTrace),
    );
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final line = LogRedactor.redact(message);
    // Off the phone: the error's type only, never its text (P-10). First,
    // so a console failure cannot keep it from crash reporting.
    _crash.recordError(
      error == null ? ReportedError.line(line) : ReportedError.of(error),
      stackTrace,
      reason: line,
    );
    _print(
      () => _logger.e(line, error: error, stackTrace: stackTrace),
      () => _logger.e(line, stackTrace: stackTrace),
    );
  }

  /// Logging never throws: an error whose own text cannot be read (its
  /// `toString` fails) is printed without it. The global error handlers
  /// log through here, and a throw would hide the error being reported.
  static void _print(void Function() write, void Function() withoutError) {
    try {
      write();
    } on Object {
      withoutError();
    }
  }
}
