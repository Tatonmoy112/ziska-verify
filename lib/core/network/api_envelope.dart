import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

/// The answer shape of every route (final.md §15):
/// `{ success, message, data }` or `{ success: false, message, error }`.
abstract final class ApiEnvelope {
  /// Returns `data` of a success answer; throws an [AppException] otherwise.
  static Object? unwrap(Object? body, {int? statusCode}) {
    if (body is Map<String, dynamic> && body['success'] == true) {
      return body['data'];
    }
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ErrorMapper.fromResponse(statusCode: statusCode, body: body);
    }
    throw InternalErrorException(
      statusCode: statusCode,
      message: 'unexpected_answer_shape',
    );
  }
}
