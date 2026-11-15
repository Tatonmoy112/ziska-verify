import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/auth_interceptor.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

/// Every API service calls the backend through this client
/// (final.md Section 4.3). It returns the envelope's `data` and throws one
/// typed [AppException] on failure.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Object?> get(
    String path, {
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.get<Object?>(
      path,
      // Empty filters are never sent (final.md Section 10.2).
      queryParameters: _withoutEmpty(query),
      cancelToken: cancelToken,
    ),
  );

  Future<Object?> post(
    String path, {
    Object? body,
    bool skipAuth = false,
    bool keepSessionOn401 = false,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.post<Object?>(
      path,
      data: body,
      cancelToken: cancelToken,
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
    String path,
    Uint8List bytes, {
    required String contentType,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.post<Object?>(
      path,
      data: Stream.fromIterable([bytes]),
      cancelToken: cancelToken,
      options: Options(
        contentType: contentType,
        headers: {Headers.contentLengthHeader: bytes.length},
      ),
    ),
  );

  Future<Object?> _send(Future<Response<Object?>> Function() call) async {
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
/// renewal one without them (final.md Section 5.5).
abstract final class DioFactory {
  static BaseOptions options(String apiRoot) => BaseOptions(
    baseUrl: apiRoot,
    contentType: Headers.jsonContentType,
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
  );
}
