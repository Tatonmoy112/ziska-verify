import 'package:ziska_verify/core/services/logging/logger_service.dart';

/// Collects log lines for tests.
class FakeLoggerService implements LoggerService {
  final List<String> lines = [];

  @override
  void debug(String message) => lines.add(message);

  @override
  void info(String message) => lines.add(message);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      lines.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      lines.add(message);
}
