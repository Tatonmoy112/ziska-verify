import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// Used until a Firebase app is configured, in the `mock` flavor, and in
/// debug builds.
class NoOpCrashReportingService implements CrashReportingService {
  const NoOpCrashReportingService();

  @override
  Future<void> initialize() async {}

  @override
  void log(String message) {}

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) {}
}
