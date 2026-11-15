import 'package:dio/dio.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';

/// Turns a failed HTTP exchange into one typed [AppException]
/// (final.md Section 15.4). Decided by `error.code`, then by status.
class ErrorMapper {
  const ErrorMapper._();

  static AppException fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'bad_certificate');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final response = e.response;
        if (response == null) return const NetworkException();
        return fromResponse(
          statusCode: response.statusCode,
          body: response.data,
          retryAfterHeader: response.headers.value('retry-after'),
        );
    }
  }

  /// Maps an error answer. [body] is the decoded JSON envelope, or anything
  /// else (for example an HTML page from a proxy).
  static AppException fromResponse({
    required int? statusCode,
    required Object? body,
    String? retryAfterHeader,
  }) {
    String? code;
    String? message;
    String? requestId;
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        code = error['code'] as String?;
        message = error['message'] as String?;
        requestId = error['request_id'] as String?;
      }
      message ??= body['message'] as String?;
    }

    final s = statusCode;
    switch (code) {
      case 'validation_failed':
        return ValidationException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'token_expired':
        return TokenExpiredException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'unauthenticated':
        return UnauthenticatedException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'password_change_required':
        return PasswordChangeRequiredException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'policy_denied':
        return PolicyDeniedException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'forbidden':
        return ForbiddenException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'not_found':
        return NotFoundException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'conflict':
        return ConflictException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'rate_limited':
        return RateLimitedException(
          retryAfter: parseRetryAfter(retryAfterHeader),
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'app_preparing':
        return AppPreparingException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
      case 'service_unavailable':
        return ServiceUnavailableException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
    }

    // No known code: decide by status.
    if (s == 429) {
      return RateLimitedException(
        retryAfter: parseRetryAfter(retryAfterHeader),
        statusCode: s,
        code: code,
        message: message,
        requestId: requestId,
      );
    }
    if (s == 503) {
      return ServiceUnavailableException(
        statusCode: s,
        code: code,
        message: message,
        requestId: requestId,
      );
    }
    return InternalErrorException(
      statusCode: s,
      code: code,
      message: message,
      requestId: requestId,
    );
  }

  /// `Retry-After` in seconds; `null` when missing or not a whole number.
  static Duration? parseRetryAfter(String? header) {
    final seconds = int.tryParse(header?.trim() ?? '');
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }
}
