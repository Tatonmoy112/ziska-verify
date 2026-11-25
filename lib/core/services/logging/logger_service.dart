/// Logging that never carries passes, passwords, emailed codes, hidden
/// codes, or the phone ID (final.md §12). Callers log the route,
/// the status, and `request_id` instead.
abstract interface class LoggerService {
  void debug(String message);
  void info(String message);
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}
