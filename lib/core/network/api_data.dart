import 'package:ziska_verify/core/errors/app_exception.dart';

/// Reads the `data` of an answer (what `ApiClient` returns) as the shape
/// its route documents (final.md §15). Any other shape is
/// `InternalErrorException('<name>_shape')`, where `name` says which answer
/// it was; some callers act on that name, so it never changes (production
/// audit P-19).
abstract final class ApiData {
  /// [data] as a JSON object.
  static Map<String, dynamic> map(Object? data, String name) {
    if (data is Map<String, dynamic>) return data;
    throw _shape(name);
  }

  /// [data] as a list of JSON objects. Its items are checked as they are
  /// read: one that is not an object is a `TypeError`, which `guard` reports
  /// as `answer_shape`.
  static List<Map<String, dynamic>> list(Object? data, String name) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    throw _shape(name);
  }

  /// The whole number at [key] of the object [data].
  static int intField(Object? data, String key, String name) {
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is int) return value;
    }
    throw _shape(name);
  }

  static InternalErrorException _shape(String name) =>
      InternalErrorException(message: '${name}_shape');
}
