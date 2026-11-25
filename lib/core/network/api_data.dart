import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';

/// Reads the `data` of an answer (what `ApiClient` returns) as the shape
/// its route documents (final.md §15). Any other shape is an
/// `InternalErrorException` whose `reason` is the [ApiAnswer] it was
/// (production audit P-19, P-24).
abstract final class ApiData {
  /// [data] as a JSON object.
  static Map<String, dynamic> map(Object? data, ApiAnswer answer) {
    if (data is Map<String, dynamic>) return data;
    throw _shape(answer);
  }

  /// [data] as a list of JSON objects. Its items are checked as they are
  /// read: one that is not an object is a `TypeError`, which `guard` reports
  /// as `answer_shape`.
  static List<Map<String, dynamic>> list(Object? data, ApiAnswer answer) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    throw _shape(answer);
  }

  /// The whole number at [key] of the object [data].
  static int intField(Object? data, String key, ApiAnswer answer) {
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is int) return value;
    }
    throw _shape(answer);
  }

  static InternalErrorException _shape(ApiAnswer answer) =>
      InternalErrorException(reason: answer);
}
