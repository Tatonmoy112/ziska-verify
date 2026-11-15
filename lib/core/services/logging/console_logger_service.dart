import 'package:logger/logger.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// [LoggerService] on the `logger` package. Every line is redacted; warnings
/// and errors are also sent to crash reporting.
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
    _logger.w(line, error: error, stackTrace: stackTrace);
    _crash.log(line);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final line = LogRedactor.redact(message);
    _logger.e(line, error: error, stackTrace: stackTrace);
    _crash.recordError(error ?? line, stackTrace, reason: line);
  }
}
