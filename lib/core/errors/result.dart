import 'package:ziska_verify/core/errors/app_exception.dart';

/// What a repository returns: repositories never throw
/// (final.md Section 5.4).
sealed class Result<T> {
  const Result();

  /// Runs [onSuccess] or [onFailure] and returns its value.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Err<T>(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// A failure the presentation layer turns into a localized message
/// (final.md Section 16). [exception] keeps the type, `request_id`, and
/// `Retry-After`.
final class Failure {
  const Failure(this.exception);

  final AppException exception;

  String? get requestId => exception.requestId;

  Duration? get retryAfter => switch (exception) {
    RateLimitedException(:final retryAfter) => retryAfter,
    _ => null,
  };

  /// The wait shown when a `429` has no usable `Retry-After`.
  static const defaultRetryAfter = Duration(seconds: 60);

  /// For a `429`: when a new request may be sent, counted from [now]
  /// (final.md Section 15.4). `null` for any other failure.
  DateTime? retryAtFrom(DateTime now) => exception is RateLimitedException
      ? now.add(retryAfter ?? defaultRetryAfter)
      : null;
}

/// Runs [action] and turns any [AppException] into an [Err].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on AppException catch (e) {
    return Err(Failure(e));
  }
}
