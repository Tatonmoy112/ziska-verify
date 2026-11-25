import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

/// Every API service calls the backend through this client
/// (final.md §4), on a route of [ApiRoutes] (P-17). It returns the
/// envelope's `data` and throws one typed [AppException] on failure; a
/// route of the other method is refused before anything is sent.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Object?> get(
    ApiRoute route, {
    Map<String, Object?>? query,
    bool skipAuth = false,
  }) => _send(
    route,
    ApiMethod.get,
    () => _dio.get<Object?>(
      route.path,
      // Empty filters are never sent (final.md §10).
      queryParameters: _withoutEmpty(query),
      options: Options(extra: {RequestFlags.skipAuth: skipAuth}),
    ),
  );

  Future<Object?> post(
    ApiRoute route, {
    Object? body,
    bool skipAuth = false,
    bool keepSessionOn401 = false,
  }) => _send(
    route,
    ApiMethod.post,
    () => _dio.post<Object?>(
      route.path,
      data: body,
      options: Options(
        extra: {
          RequestFlags.skipAuth: skipAuth,
          RequestFlags.keepSessionOn401: keepSessionOn401,
        },
      ),
    ),
  );

  /// Sends a raw file as the body (report photos, app API guide §6.2).
  Future<Object?> postBytes(
    ApiRoute route,
    Uint8List bytes, {
    required String contentType,
  }) => _send(
    route,
    ApiMethod.post,
    () => _dio.post<Object?>(
      route.path,
      data: Stream.fromIterable([bytes]),
      options: Options(
        contentType: contentType,
        headers: {Headers.contentLengthHeader: bytes.length},
      ),
    ),
  );

  Future<Object?> _send(
    ApiRoute route,
    ApiMethod method,
    Future<Response<Object?>> Function() call,
  ) async {
    if (route.method != method) {
      throw ArgumentError.value(route, 'route', 'not a ${method.name} route');
    }
    try {
      final response = await call();
      return ApiEnvelope.unwrap(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final inner = e.error;
      if (inner is AppException) throw inner;
      throw ErrorMapper.fromDio(e);
    }
  }

  static Map<String, Object?>? _withoutEmpty(Map<String, Object?>? query) {
    if (query == null) return null;
    return Map.fromEntries(
      query.entries.where((e) => e.value != null && e.value != ''),
    );
  }
}

/// Builds the two Dio instances: the main one with interceptors, and the
/// renewal one without them (final.md §6).
abstract final class DioFactory {
  static BaseOptions options(String apiRoot) => BaseOptions(
    baseUrl: apiRoot,
    contentType: Headers.jsonContentType,
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
  );
}
