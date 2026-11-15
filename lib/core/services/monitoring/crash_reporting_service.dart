/// Crash reporting (final.md Section 2.2: Firebase Crashlytics). Receives
/// only redacted text from `LoggerService`.
abstract interface class CrashReportingService {
  Future<void> initialize();
  void log(String message);
  void recordError(Object error, StackTrace? stackTrace, {String? reason});
}

/// Used until the Firebase project exists (final.md Section 20.3), and in
/// the `mock` flavor.
class NoOpCrashReportingService implements CrashReportingService {
  const NoOpCrashReportingService();

  @override
  Future<void> initialize() async {}

  @override
  void log(String message) {}

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) {}
}
