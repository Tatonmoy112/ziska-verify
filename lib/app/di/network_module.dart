import 'package:dio/dio.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/bodiless_request_interceptor.dart';
import 'package:ziska_verify/core/network/demo/postman_mock_routing.dart';
import 'package:ziska_verify/core/network/dio_session_service.dart';
import 'package:ziska_verify/core/network/logging_interceptor.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/session/forbidden_signal.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// The network as the app uses it (final.md §4, §6): the API client, the
/// session with its own renewal client, and the signal of a `403`.
typedef NetworkStack = ({
  ApiClient api,
  DioSessionService session,
  ForbiddenSignal forbidden,
});

/// Builds the two Dio clients and their interceptors. The main client's, in
/// order: bodiless, Postman mock routing (mock build only), auth, logging;
/// the refresh client's: mock routing and logging only, so a renewal is
/// never itself renewed. [httpAdapter] replaces the transport of both,
/// for automated flow tests.
NetworkStack buildNetwork({
  required AppConfig config,
  required LoggerService logger,
  required SecureStorageService storage,
  HttpClientAdapter? httpAdapter,
}) {
  // Mock build only: picks the Postman mock's examples, on both clients
  // (docs/postman-mock-setup.md).
  final mockRouting =
      config.flavor == AppFlavor.mock && config.postmanMockRouting
      ? PostmanMockRouting()
      : null;
  final refreshDio = Dio(DioFactory.options(config.apiRoot))
    ..interceptors.addAll([?mockRouting, LoggingInterceptor(logger)]);
  final session = DioSessionService(
    storage: storage,
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
    ?mockRouting,
    AuthInterceptor(session: session, dio: dio, onForbidden: forbidden.raise),
    LoggingInterceptor(logger),
  ]);
  return (api: ApiClient(dio), session: session, forbidden: forbidden);
}
