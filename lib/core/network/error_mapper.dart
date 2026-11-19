import 'dart:io' show HttpDate;

import 'package:clock/clock.dart';
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
      // No connection was made: the request never reached a server.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(message: NetworkException.notSent);
      // Sent, but the answer was lost: it may have been recorded.
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException();
      // The secure connection was refused before anything was sent.
      case DioExceptionType.badCertificate:
        return const NetworkException(message: NetworkException.notSent);
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
      case 'session_full':
      case 'session_ended':
      case 'session_not_yours':
        return ScanSessionException(
          statusCode: s,
          code: code,
          message: message,
          requestId: requestId,
        );
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
    // Not our envelope (a proxy or gateway page): the status still says
    // what happened (guide section 1 table).
    if (code == null) {
      switch (s) {
        case 400 || 413 || 415:
          return ValidationException(
            statusCode: s,
            message: message,
            requestId: requestId,
          );
        case 403:
          return ForbiddenException(
            statusCode: s,
            message: message,
            requestId: requestId,
          );
        case 404:
          return NotFoundException(
            statusCode: s,
            message: message,
            requestId: requestId,
          );
      }
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

  /// `Retry-After` in seconds, or as an HTTP date still to come (counted
  /// from now); `null` when missing, unreadable or already past.
  static Duration? parseRetryAfter(String? header) {
    final text = header?.trim() ?? '';
    final seconds = int.tryParse(text);
    if (seconds != null) {
      return seconds < 0 ? null : Duration(seconds: seconds);
    }
    try {
      final left = HttpDate.parse(text).difference(clock.now().toUtc());
      return left > Duration.zero ? left : null;
    } on Object {
      return null;
    }
  }
}
