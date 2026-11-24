import 'package:dio/dio.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';

/// Logs the method, the route, the status, and `request_id` only. Bodies,
/// headers, and query values are never logged (final.md §12).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final LoggerService _logger;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final o = response.requestOptions;
    _logger.debug('${o.method} ${o.path} → ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final status = err.response?.statusCode;
    final body = err.response?.data;
    String? requestId;
    if (body is Map<String, dynamic> && body['error'] is Map) {
      requestId = (body['error'] as Map)['request_id'] as String?;
    }
    _logger.info(
      '${o.method} ${o.path} → ${status ?? err.type.name}'
      '${requestId == null ? '' : ' (request_id $requestId)'}',
    );
    handler.next(err);
  }
}
