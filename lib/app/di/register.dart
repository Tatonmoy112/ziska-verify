import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/app/di/locator.dart';
import 'package:ziska_verify/app/di/network_module.dart';
import 'package:ziska_verify/app/di/platform_services.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/core/services/connectivity/plus_connectivity_service.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/device/package_info_app_info_service.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/launcher/url_launcher_service.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/media/image_picker_photo_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/permission/permission_handler_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/mobile_scanner_service.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/session/forbidden_signal.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/storage/flutter_secure_storage_service.dart';
import 'package:ziska_verify/core/services/storage/preferences_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/core/services/storage/shared_preferences_service.dart';
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

/// Registers the core services, each against its interface: storage, the
/// session, the API client and the plugin wrappers (final.md §11). A
/// platform service in [platform] is used as it is; the others are the
/// real ones, made when first used.
void registerCore({
  required AppConfig config,
  required CrashReportingService crash,
  required LoggerService logger,
  PlatformServices platform = const PlatformServices(),

  /// Replaces the network for automated flow tests (test/flow/).
  HttpClientAdapter? httpAdapter,
}) {
  final storage = platform.storage ?? FlutterSecureStorageService();
  final network = buildNetwork(
    config: config,
    logger: logger,
    storage: storage,
    httpAdapter: httpAdapter,
  );
  locator
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<CrashReportingService>(crash)
    ..registerSingleton<LoggerService>(logger)
    ..registerSingleton<SecureStorageService>(storage)
    ..registerSingleton<PhoneIdService>(SecurePhoneIdService(storage))
    ..registerSingleton<SessionService>(
      network.session,
      dispose: (s) => s.dispose(),
    )
    ..registerSingleton<ForbiddenSignal>(
      network.forbidden,
      dispose: (s) => s.dispose(),
    )
    ..registerSingleton<ApiClient>(network.api, dispose: (c) => c.close())
    ..registerLazySingleton<LauncherService>(
      () => platform.launcher ?? const UrlLauncherService(),
    )
    ..registerLazySingleton<AppInfoService>(
      () => platform.appInfo ?? PackageInfoAppInfoService(),
    )
    ..registerLazySingleton<ConnectivityService>(
      () => platform.connectivity ?? PlusConnectivityService(),
    )
    ..registerLazySingleton<PreferencesService>(
      () => platform.preferences ?? SharedPreferencesService(),
    )
    ..registerLazySingleton<ScannerService>(
      () => platform.scanner ?? const MobileScannerService(),
    )
    ..registerLazySingleton<PermissionService>(
      () => platform.permission ?? const PermissionHandlerService(),
    )
    ..registerLazySingleton<PhotoService>(
      () => platform.photos ?? ImagePickerPhotoService(),
    )
    ..registerLazySingleton<PictureImages>(
      () => platform.pictures ?? const NetworkPictureImages(),
    );
}

/// Registers each feature's API service, repository and use cases.
/// Lifetimes follow final.md §11; BLoCs are created in the route builders.
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
      () => DioAccessRequestApiService(locator()),
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
    ..registerFactory(() => RequestPasswordReset(locator()))
    ..registerFactory(() => ResetPassword(locator()))
    ..registerFactory(() => Logout(locator()))
    // Verification
    ..registerLazySingleton<VerificationApiService>(
      () => DioVerificationApiService(locator()),
    )
    ..registerLazySingleton<VerificationRepository>(
      () => VerificationRepositoryImpl(locator(), locator()),
      // It listens to the session and keeps the formats (P-34). The
      // listener stops at once; its clean-up is not waited for, as a reset
      // must not hang on it.
      dispose: (r) {
        if (r is VerificationRepositoryImpl) unawaited(r.dispose());
      },
    )
    ..registerFactory(() => GetFormats(locator()))
    ..registerFactory(() => LookupItem(locator()))
    ..registerFactory(() => GetSession(locator()))
    ..registerFactory(() => ScanItem(locator()))
    ..registerFactory(() => CheckSerials(locator()))
    ..registerFactory(() => EndSession(locator()))
    ..registerFactory(() => GetSessions(locator()))
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

/// Reads the chosen language before the first screen, so the app never
/// starts in one language and turns to another (final.md §16).
Future<void> prepareLanguage() async {
  final initial = await LocaleCubit.stored(locator(), locator());
  locator.registerSingleton<LocaleCubit>(
    LocaleCubit(locator(), locator(), initial: initial),
    dispose: (c) => c.close(),
  );
}
