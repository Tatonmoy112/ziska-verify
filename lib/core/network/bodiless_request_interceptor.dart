import 'package:dio/dio.dart';

/// A request with no body says no type for it: `auth/logout` and
/// `me/password/later` are sent bare, as in the backend's Postman
/// collection, never as an empty JSON body.
class BodilessRequestInterceptor extends Interceptor {
  const BodilessRequestInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data == null) options.contentType = null;
    handler.next(options);
  }
}
