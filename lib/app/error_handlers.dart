import 'package:flutter/foundation.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/services/logging/console_logger_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/firebase_crash_reporting_service.dart';
import 'package:ziska_verify/core/services/monitoring/no_op_crash_reporting_service.dart';

/// The logger, and crash reporting behind it: the app reaches crash
/// reporting only through the logger (production audit P-50). Crashlytics
/// only for a staging or live release build given a Firebase app for this
/// platform; otherwise nothing leaves the phone (P-10).
Future<LoggerService> startMonitoring(AppConfig config) async {
  final target = config.crashTargetFor(
    defaultTargetPlatform,
    debug: kDebugMode,
  );
  final crash = target == null
      ? const NoOpCrashReportingService()
      : FirebaseCrashReportingService(target);
  await crash.initialize();
  return ConsoleLoggerService(
    crash,
    printing: kDebugMode,
    verbose: kDebugMode,
  );
}

/// Every error Flutter or the platform reports goes to [logger], so it
/// reaches crash reporting (final.md §12).
void installErrorHandlers(LoggerService logger) {
  FlutterError.onError = (details) => logger.error(
    'flutter error',
    error: details.exception,
    stackTrace: details.stack,
  );
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('uncaught error', error: error, stackTrace: stack);
    return true;
  };
}
