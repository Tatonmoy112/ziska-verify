import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/app/app.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/bodiless_request_interceptor.dart';
import 'package:ziska_verify/core/network/demo/password_later_demo.dart';
import 'package:ziska_verify/core/network/demo/postman_mock_routing.dart';
import 'package:ziska_verify/core/network/logging_interceptor.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/logging/console_logger_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/session/dio_session_service.dart';
import 'package:ziska_verify/core/services/session/forbidden_signal.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/storage/flutter_secure_storage_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/features/authentication/data/repositories/access_request_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/access_request_repository.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/history/data/repositories/history_repository_impl.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';
import 'package:ziska_verify/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';
import 'package:ziska_verify/features/profile/domain/repositories/profile_repository.dart';
import 'package:ziska_verify/features/profile/domain/usecases/get_profile.dart';
import 'package:ziska_verify/features/retail_users/data/repositories/retail_user_repository_impl.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

/// The service locator. Used only here, in the composition root
/// (final.md Sections 4.2, 5.9).
final GetIt locator = GetIt.instance;

/// Wires every implementation to its interface, restores the session, and
/// starts the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  tz_data.initializeTimeZones();

  const crash = NoOpCrashReportingService();
  await crash.initialize();
  final logger = ConsoleLoggerService(crash, verbose: kDebugMode);

  FlutterError.onError = (details) => logger.error(
    'flutter error',
    error: details.exception,
    stackTrace: details.stack,
  );
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('uncaught error', error: error, stackTrace: stack);
    return true;
  };

  registerCore(config: config, crash: crash, logger: logger);
  registerFeatures();

  await prepareSession();

  runApp(App(locator: locator));
}

/// Makes the phone ID and restores the login before the first screen. The
/// app always starts: a phone ID that cannot be made now is made at the
/// login, and unreadable passes start at Login (final.md Section 6.1).
Future<void> prepareSession() async {
  try {
    await locator<PhoneIdService>().getOrCreate();
  } on Object catch (e) {
    locator<LoggerService>().warning('phone ID not ready: ${e.runtimeType}');
  }
  await locator<SessionService>().restore();
}

/// Registers the core services. Feature registrations are added per build
/// step (app build guide §5).
void registerCore({
  required AppConfig config,
  required CrashReportingService crash,
  required LoggerService logger,
  SecureStorageService? storage,

  /// Replaces the network for automated flow tests (test/flow/).
  HttpClientAdapter? httpAdapter,
}) {
  final secureStorage = storage ?? FlutterSecureStorageService();
  // Mock build only, until the backend ships `me/password/later`: plays its
  // answers on both clients (renewals go through `refreshDio`).
  final demo = config.flavor == AppFlavor.mock && config.demoPasswordLater
      ? PasswordLaterDemo(logger)
      : null;
  // Mock build only: picks the Postman mock's examples, on both clients
  // (docs/postman-mock-setup.md).
  final mockRouting =
      config.flavor == AppFlavor.mock && config.postmanMockRouting
      ? PostmanMockRouting()
      : null;
  final refreshDio = Dio(DioFactory.options(config.apiRoot))
    ..interceptors.addAll([?demo, ?mockRouting, LoggingInterceptor(logger)]);
  final session = DioSessionService(
    storage: secureStorage,
    refreshDio: refreshDio,
    logger: logger,
  );
  final dio = Dio(DioFactory.options(config.apiRoot));
  if (httpAdapter != null) {
    refreshDio.httpClientAdapter = httpAdapter;
    dio.httpClientAdapter = httpAdapter;
  }
  final forbidden = ForbiddenSignal();
  dio.interceptors.addAll([
    const BodilessRequestInterceptor(),
    ?demo,
    ?mockRouting,
    AuthInterceptor(session: session, dio: dio, onForbidden: forbidden.raise),
    LoggingInterceptor(logger),
  ]);

  locator
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<CrashReportingService>(crash)
    ..registerSingleton<LoggerService>(logger)
    ..registerSingleton<SecureStorageService>(secureStorage)
    ..registerSingleton<PhoneIdService>(SecurePhoneIdService(secureStorage))
    ..registerSingleton<SessionService>(
      session,
      dispose: (s) => s.dispose(),
    )
    ..registerSingleton<ForbiddenSignal>(
      forbidden,
      dispose: (s) => s.dispose(),
    )
    ..registerSingleton<ApiClient>(ApiClient(dio))
    ..registerLazySingleton<LauncherService>(UrlLauncherService.new)
    ..registerLazySingleton<AppInfoService>(PackageInfoAppInfoService.new)
    ..registerLazySingleton<ConnectivityService>(PlusConnectivityService.new)
    ..registerLazySingleton<ScannerService>(MobileScannerService.new)
    ..registerLazySingleton<PermissionService>(PermissionHandlerService.new)
    ..registerLazySingleton<PhotoService>(ImagePickerPhotoService.new)
    ..registerLazySingleton<PictureImages>(NetworkPictureImages.new);
}

/// Registers the features built so far (app build guide §5). Lifetimes
/// follow final.md Section 5.9; BLoCs are created in the route builders.
void registerFeatures() {
  locator
    // Profile
    ..registerLazySingleton<ProfileApiService>(
      () => DioProfileApiService(locator()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(locator(), locator()),
    )
    ..registerFactory(() => GetProfile(locator()))
    ..registerLazySingleton<AccessRequestApiService>(
      () => AccessRequestApiService(locator()),
    )
    ..registerLazySingleton<AccessRequestRepository>(
      () => AccessRequestRepositoryImpl(locator()),
    )
    ..registerFactory(() => GetRequestableRoles(locator()))
    ..registerFactory(() => SendAccessCode(locator()))
    ..registerFactory(() => SubmitAccessRequest(locator()))
    // Authentication
    ..registerLazySingleton<AuthApiService>(
      () => DioAuthApiService(locator()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        api: locator(),
        session: locator(),
        phoneId: locator(),
        logger: locator(),
      ),
    )
    ..registerFactory(() => Login(locator()))
    ..registerFactory(() => VerifyCode(locator()))
    ..registerFactory(() => ResendCode(locator()))
    ..registerFactory(() => CancelCode(locator()))
    ..registerFactory(() => ChangePassword(locator()))
    ..registerFactory(() => PostponePasswordChange(locator()))
    ..registerFactory(() => RequestPasswordReset(locator()))
    ..registerFactory(() => ResetPassword(locator()))
    ..registerFactory(() => Logout(locator()))
    // Verification
    ..registerLazySingleton<VerificationApiService>(
      () => DioVerificationApiService(locator()),
    )
    ..registerLazySingleton<VerificationRepository>(
      () => VerificationRepositoryImpl(locator(), locator()),
    )
    ..registerFactory(() => GetFormats(locator()))
    ..registerFactory(() => LookupItem(locator()))
    ..registerFactory(() => GetSession(locator()))
    // History
    ..registerLazySingleton<HistoryApiService>(
      () => DioHistoryApiService(locator()),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(locator()),
    )
    ..registerFactory(() => GetChecks(locator()))
    // Incidents
    ..registerLazySingleton<IncidentApiService>(
      () => DioIncidentApiService(locator()),
    )
    ..registerLazySingleton<IncidentRepository>(
      () => IncidentRepositoryImpl(locator()),
    )
    ..registerFactory(() => FileReport(locator()))
    ..registerFactory(() => AddReportPhoto(locator()))
    ..registerFactory(() => GetMyReports(locator()))
    // Retail users
    ..registerLazySingleton<RetailUserApiService>(
      () => DioRetailUserApiService(locator()),
    )
    ..registerLazySingleton<RetailUserRepository>(
      () => RetailUserRepositoryImpl(locator()),
    )
    ..registerFactory(() => SearchRetailUsers(locator()));
}
