import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';

/// What a repository returns: repositories never throw
/// (final.md §3).
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

  /// The value turned by [convert]; a failure passed on as it is
  /// (production audit P-30).
  Result<R> map<R>(R Function(T value) convert) => switch (this) {
    Success<T>(:final value) => Success(convert(value)),
    Err<T>(:final failure) => Err(failure),
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
/// (final.md §16). [exception] keeps the type, `request_id`, and
/// `Retry-After`.
final class Failure {
  const Failure(this.exception);

  final AppException exception;

  String? get requestId => exception.requestId;

  Duration? get retryAfter => switch (exception) {
    RateLimitedException(:final retryAfter) => retryAfter,
    _ => null,
  };

  /// For a `429`: when a new request may be sent, counted from [now]
  /// (final.md §15). `null` for any other failure.
  DateTime? retryAtFrom(DateTime now) => exception is RateLimitedException
      ? (retryAfter == null ? null : now.add(retryAfter!))
      : null;
}

/// Runs [action] and turns any [AppException] into an [Err]. An answer of
/// the wrong shape (a field of the wrong type or missing, which the parsers
/// report as a `TypeError` or a `FormatException`) is an
/// [InternalErrorException] too, so a screen never waits forever (final.md
/// §6).
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on AppException catch (e) {
    return Err(Failure(e));
  } on FormatException {
    return const Err(
      Failure(InternalErrorException(reason: CoreReason.answerShape)),
    );
    // The generated parsers report a wrong field type this way; nothing else
    // in an action is expected to.
    // ignore: avoid_catching_errors
  } on TypeError {
    return const Err(
      Failure(InternalErrorException(reason: CoreReason.answerShape)),
    );
  }
}
