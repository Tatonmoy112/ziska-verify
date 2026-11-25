/// Crash reporting: Firebase Crashlytics in a staging or live release
/// build given a Firebase app (`config/<flavor>.json`), otherwise
/// `NoOpCrashReportingService` (docs/release-backlog.md). It receives only
/// what `LoggerService` lets out: redacted lines and `ReportedError`s,
/// never an error's own text (final.md §12).
abstract interface class CrashReportingService {
  Future<void> initialize();
  void log(String message);
  void recordError(Object error, StackTrace? stackTrace, {String? reason});
}

/// The Firebase project of a build and its app on each platform
/// (`FIREBASE_*` in `config/<flavor>.json`). A platform without its app
/// reports nothing.
class CrashReportingConfig {
  const CrashReportingConfig({
    required this.projectId,
    required this.senderId,
    this.android,
    this.ios,
  });

  final String projectId;
  final String senderId;
  final ({String apiKey, String appId})? android;
  final ({String apiKey, String appId})? ios;
}

/// The one Firebase app this phone reports to.
class CrashTarget {
  const CrashTarget({
    required this.projectId,
    required this.senderId,
    required this.apiKey,
    required this.appId,
  });

  final String projectId;
  final String senderId;
  final String apiKey;
  final String appId;
}
