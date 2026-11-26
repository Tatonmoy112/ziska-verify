import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/app/app.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/di/locator.dart';
import 'package:ziska_verify/app/di/register.dart';
import 'package:ziska_verify/app/error_handlers.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';

/// Starts the app, step by step (production audit P-35): monitoring and
/// the error handlers, the registrations, the session and the language,
/// then the first screen.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  tz_data.initializeTimeZones();

  final logger = await startMonitoring(config);
  installErrorHandlers(logger);

  registerCore(config: config, logger: logger);
  registerFeatures();

  await prepareSession();
  final language = await readLanguage();

  runApp(App(locator: locator, initialLocale: language));
}

/// Makes the phone ID and restores the login before the first screen. The
/// app always starts: a phone ID that cannot be made now is made at the
/// login, and unreadable passes start at Login (final.md §6).
Future<void> prepareSession() async {
  try {
    await locator<PhoneIdService>().getOrCreate();
  } on Object catch (e) {
    locator<LoggerService>().warning('phone ID not ready: ${e.runtimeType}');
  }
  await locator<SessionService>().restore();
}
