import 'package:ziska_verify/core/errors/failure_reason.dart';

/// One typed exception per API `error.code` (final.md §15).
///
/// Thrown by the network layer and API services; caught in repositories and
/// turned into a `Failure`. Decisions are made on the type and [reason],
/// never on [message] (production audit P-24).
sealed class AppException implements Exception {
  const AppException({
    this.statusCode,
    this.code,
    this.message,
    this.requestId,
    this.reason,
  });

  /// The HTTP status, `null` when no answer arrived.
  final int? statusCode;

  /// The API's `error.code`, `null` when no envelope arrived.
  final String? code;

  /// The server's message, shown only as a fallback (final.md §16).
  final String? message;

  /// Shown on every error screen as "Reference: {requestId}".
  final String? requestId;

  /// Why the app itself failed, when it did; `null` for the server's own
  /// errors.
  final FailureReason? reason;

  /// For logs: never the server's [message].
  @override
  String toString() =>
      'AppException(status: $statusCode, code: ${code ?? reason}, '
      'requestId: $requestId)';
}

/// 400 / 413 / 415 `validation_failed`: an app defect, logged.
final class ValidationException extends AppException {
  const ValidationException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
    super.reason,
  });
}

/// 401 `token_expired`: renewed once, then retried once.
final class TokenExpiredException extends AppException {
  const TokenExpiredException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 401 `unauthenticated`: the login ended, or wrong login details.
final class UnauthenticatedException extends AppException {
  const UnauthenticatedException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
    super.reason,
  });
}

/// 403 `password_change_required`.
final class PasswordChangeRequiredException extends AppException {
  const PasswordChangeRequiredException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 403 `policy_denied`: the new password breaks the password rule.
final class PolicyDeniedException extends AppException {
  const PolicyDeniedException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 403 `forbidden`: the role lacks the permission.
final class ForbiddenException extends AppException {
  const ForbiddenException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 404 `not_found`.
final class NotFoundException extends AppException {
  const NotFoundException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 409 `conflict`.
final class ConflictException extends AppException {
  const ConflictException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// A QR scan cannot join its current session.
final class ScanSessionException extends AppException {
  const ScanSessionException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 429 `rate_limited`, carrying the `Retry-After` seconds.
final class RateLimitedException extends AppException {
  const RateLimitedException({
    this.retryAfter,
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });

  /// From the `Retry-After` header; `null` when the header is missing.
  final Duration? retryAfter;
}

/// 503 `app_preparing`.
final class AppPreparingException extends AppException {
  const AppPreparingException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 503 `service_unavailable`.
final class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
  });
}

/// 5xx `internal_error`, and any answer the app does not recognise.
final class InternalErrorException extends AppException {
  const InternalErrorException({
    super.statusCode,
    super.code,
    super.message,
    super.requestId,
    super.reason,
  });
}

/// No answer: offline, timeout, or connection failure.
final class NetworkException extends AppException {
  const NetworkException({super.message, this.wasNotSent = false});

  /// The request never reached a server (no connection): nothing was
  /// recorded, so sending again is safe.
  final bool wasNotSent;
}

/// The request was cancelled by the app (a screen closed, a newer search).
final class RequestCancelledException extends AppException {
  const RequestCancelledException();
}
