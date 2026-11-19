import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

import '../../fakes/scripted_adapter.dart';

void main() {
  group('ErrorMapper.fromResponse', () {
    final cases = <(int, String, Type)>[
      (400, 'validation_failed', ValidationException),
      (413, 'validation_failed', ValidationException),
      (401, 'token_expired', TokenExpiredException),
      (401, 'unauthenticated', UnauthenticatedException),
      (403, 'password_change_required', PasswordChangeRequiredException),
      (403, 'policy_denied', PolicyDeniedException),
      (403, 'forbidden', ForbiddenException),
      (404, 'not_found', NotFoundException),
      (409, 'conflict', ConflictException),
      (429, 'rate_limited', RateLimitedException),
      (503, 'app_preparing', AppPreparingException),
      (503, 'service_unavailable', ServiceUnavailableException),
      (500, 'internal_error', InternalErrorException),
    ];

    for (final (status, code, type) in cases) {
      test('$status $code → $type, carrying code and request_id', () {
        final e = ErrorMapper.fromResponse(
          statusCode: status,
          body: errorBody(code, requestId: 'r-$code'),
        );
        expect(e.runtimeType, type);
        expect(e.statusCode, status);
        expect(e.code, code);
        expect(e.requestId, 'r-$code');
      });
    }

    test('429 carries Retry-After', () {
      final e = ErrorMapper.fromResponse(
        statusCode: 429,
        body: errorBody('rate_limited'),
        retryAfterHeader: '42',
      );
      expect(
        (e as RateLimitedException).retryAfter,
        const Duration(seconds: 42),
      );
    });

    test('an unknown code with an unknown status is an internal error', () {
      final e = ErrorMapper.fromResponse(
        statusCode: 418,
        body: errorBody('something_new'),
      );
      expect(e, isA<InternalErrorException>());
    });

    // TC-ERR-047: a proxy page has no envelope; the status still decides.
    for (final (status, type) in <(int, Type)>[
      (400, ValidationException),
      (413, ValidationException),
      (415, ValidationException),
      (403, ForbiddenException),
      (404, NotFoundException),
      (502, InternalErrorException),
    ]) {
      test('TC-ERR-047 a $status page without the envelope is $type', () {
        final e = ErrorMapper.fromResponse(statusCode: status, body: '<html>');
        expect(e.runtimeType, type);
      });
    }

    test('TC-ERR-048 Retry-After as seconds or as an HTTP date', () {
      expect(ErrorMapper.parseRetryAfter('30'), const Duration(seconds: 30));
      expect(ErrorMapper.parseRetryAfter('-1'), isNull);
      expect(ErrorMapper.parseRetryAfter('soon'), isNull);
      expect(ErrorMapper.parseRetryAfter(null), isNull);
      withClock(Clock.fixed(DateTime.utc(2026, 11, 17, 10)), () {
        expect(
          ErrorMapper.parseRetryAfter('Tue, 17 Nov 2026 10:00:45 GMT'),
          const Duration(seconds: 45),
        );
        expect(
          ErrorMapper.parseRetryAfter('Tue, 17 Nov 2026 09:00:00 GMT'),
          isNull,
        );
      });
    });

    test('a non-JSON 503 from a proxy is service unavailable', () {
      final e = ErrorMapper.fromResponse(statusCode: 503, body: '<html>');
      expect(e, isA<ServiceUnavailableException>());
    });
  });

  group('ErrorMapper.fromDio', () {
    final options = RequestOptions(path: 'me');

    test('connection errors and timeouts are network errors', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final e = ErrorMapper.fromDio(
          DioException(requestOptions: options, type: type),
        );
        expect(e, isA<NetworkException>());
      }
    });

    test('TC-ERR-049 a refused certificate means nothing was sent', () {
      final e = ErrorMapper.fromDio(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badCertificate,
        ),
      );
      expect(e, isA<NetworkException>());
      expect((e as NetworkException).wasNotSent, isTrue);
    });

    test('cancel is a cancelled request', () {
      final e = ErrorMapper.fromDio(
        DioException(requestOptions: options, type: DioExceptionType.cancel),
      );
      expect(e, isA<RequestCancelledException>());
    });
  });

  group('ApiEnvelope.unwrap', () {
    test('returns data on success', () {
      expect(ApiEnvelope.unwrap(okBody({'a': 1})), {'a': 1});
    });

    test('throws the typed error on success: false', () {
      expect(
        () => ApiEnvelope.unwrap(errorBody('conflict'), statusCode: 409),
        throwsA(isA<ConflictException>()),
      );
    });

    test('throws on an unexpected shape', () {
      expect(
        () => ApiEnvelope.unwrap('text'),
        throwsA(isA<InternalErrorException>()),
      );
    });
  });
}
