import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A scripted answer for [ScriptedAdapter].
class ScriptedAnswer {
  const ScriptedAnswer(this.status, this.body, {this.headers = const {}})
    : raw = null,
      contentType = Headers.jsonContentType;

  /// A body sent as it is: an HTML page, an empty body, or cut-off JSON.
  const ScriptedAnswer.raw(
    this.status,
    String this.raw, {
    this.contentType = 'text/html',
    this.headers = const {},
  }) : body = const {};

  final int status;
  final Map<String, Object?> body;
  final Map<String, List<String>> headers;
  final String? raw;
  final String contentType;
}

/// A Dio adapter that answers from a function, records every request, and
/// can hold answers back to simulate requests in flight at the same time.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.answer);

  final Future<ScriptedAnswer> Function(RequestOptions options) answer;
  final List<RequestOptions> requests = [];

  int countPath(String path) => requests.where((r) => r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final a = await answer(options);
    return ResponseBody.fromString(
      a.raw ?? jsonEncode(a.body),
      a.status,
      headers: {
        Headers.contentTypeHeader: [a.contentType],
        ...a.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> okBody(Object? data) => {
  'success': true,
  'message': 'OK',
  'data': data,
};

Map<String, Object?> errorBody(String code, {String requestId = 'req-1'}) => {
  'success': false,
  'message': code,
  'error': {'code': code, 'message': code, 'request_id': requestId},
};
