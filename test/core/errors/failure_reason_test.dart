import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';

import '../../fakes/fake_session_service.dart';

class _Api extends Mock implements VerificationApiService {}

final _options = RequestOptions(path: 'me');

AppException _dio(DioExceptionType type) =>
    ErrorMapper.fromDio(DioException(requestOptions: _options, type: type));

AppException _answer(int status, String? code, String message) =>
    ErrorMapper.fromResponse(
      statusCode: status,
      body: {
        'success': false,
        'message': message,
        'error': {'code': code, 'message': message, 'request_id': 'r'},
      },
    );

/// TC-ERR-055 … -057 (docs/test-cases/10-errors-network.md): the app's own
/// reasons are typed (`reason`, `wasNotSent`); `message` is only the
/// server's text, and never decides anything (production audit P-24).
void main() {
  group('TC-ERR-055 normal: each reason is typed where it is made', () {
    test('"not sent" is a field, set only when nothing left the phone', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.badCertificate,
      ]) {
        final e = _dio(type) as NetworkException;
        expect(e.wasNotSent, isTrue, reason: '$type');
        expect(e.message, isNull);
      }
      for (final type in [
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect((_dio(type) as NetworkException).wasNotSent, isFalse);
      }
    });

    test('an unreadable answer and a page without the envelope', () async {
      final parsed = await guard<int>(() async => throw TypeError());
      expect(
        (parsed as Err).failure.exception.reason,
        CoreReason.answerShape,
      );
      expect(
        () => ApiEnvelope.unwrap('<html>', statusCode: 200),
        throwsA(
          isA<InternalErrorException>().having(
            (e) => e.reason,
            'reason',
            CoreReason.notEnvelope,
          ),
        ),
      );
    });

    test('the reason is in the log line, the server text is not', () {
      const e = InternalErrorException(
        statusCode: 200,
        reason: CoreReason.answerShape,
        message: 'Some server text',
      );
      expect('$e', contains('answerShape'));
      expect('$e', isNot(contains('Some server text')));
    });
  });

  group('TC-ERR-056 edge: a server text equal to an old reason', () {
    test('means nothing', () {
      for (final text in [
        'verification_shape',
        'incident_id_shape',
        'serial_stack_mismatch',
        'not_sent',
      ]) {
        final e = _answer(500, 'internal_error', text);
        expect(e.message, text, reason: 'kept as the server wrote it');
        expect(e.reason, isNull);
      }
      expect(_answer(400, 'validation_failed', 'serial_input').reason, isNull);
      expect(const NetworkException(message: 'not_sent').wasNotSent, isFalse);
    });

    test(
      "a stack's 500 reading 'verification_shape' is not a recorded stack",
      () async {
        final api = _Api();
        when(() => api.serials(any())).thenThrow(
          const InternalErrorException(
            statusCode: 500,
            code: 'internal_error',
            message: 'verification_shape',
          ),
        );
        final repo = VerificationRepositoryImpl(api, FakeSessionService());
        addTearDown(repo.dispose);
        final result = await repo.serials(['12345678']);
        final e = (result as Err).failure.exception;
        expect(e.statusCode, 500, reason: 'the server error as it came');
        expect(e.reason, isNot(VerificationReason.serialStackMismatch));
      },
    );
  });

  group('TC-ERR-057 worst: no decision or reason rides on message', () {
    // The app, and the staging tool that does what the app does.
    final sources = [Directory('lib'), Directory('tool')]
        .expand((d) => d.listSync(recursive: true))
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              !f.path.endsWith('.g.dart') &&
              !f.path.endsWith('.freezed.dart') &&
              !f.path.replaceAll(r'\', '/').contains('l10n/generated/'),
        )
        .toList();

    test('no message is compared with a text', () {
      final compared = RegExp(r"""message\s*[!=]=\s*['"]""");
      final multiline = RegExp(r'message\s*[!=]=\s*$', multiLine: true);
      for (final file in sources) {
        final source = file.readAsStringSync();
        expect(source, isNot(matches(compared)), reason: file.path);
        expect(source, isNot(matches(multiline)), reason: file.path);
      }
    });

    test('no exception is made with an app-written message', () {
      final written = RegExp(r"""message:\s*['"][a-z_]+['"]""");
      for (final file in sources) {
        expect(
          file.readAsStringSync(),
          isNot(matches(written)),
          reason: file.path,
        );
      }
    });
  });
}
