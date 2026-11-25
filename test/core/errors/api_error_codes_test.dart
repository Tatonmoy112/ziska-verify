import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/api_error_codes.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';

/// The `error.code` values of the app API guide §1's table.
Set<String> guideCodes() {
  final lines = File(
    'docs/protectb-api/app-api-guide.md',
  ).readAsLinesSync();
  final start = lines.indexWhere((l) => l.startsWith('| HTTP | `code` |'));
  expect(start, isNot(-1), reason: "the guide's error table");
  final codes = <String>{};
  for (final line in lines.skip(start + 2)) {
    if (!line.startsWith('|')) break;
    final cell = line.split('|')[2];
    codes.addAll(
      RegExp('`([a-z_]+)`').allMatches(cell).map((m) => m.group(1)!),
    );
  }
  return codes;
}

AppException map(String? code, int status) => ErrorMapper.fromResponse(
  statusCode: status,
  body: {
    'success': false,
    'message': 'm',
    'error': {'code': code, 'message': 'm', 'request_id': 'r'},
  },
);

/// TC-ERR-052 … -054 (docs/test-cases/10-errors-network.md): the API's
/// error codes are written once, in `ApiErrorCodes`, and equal the guide's
/// (production audit P-23).
void main() {
  group("TC-ERR-052 normal: ApiErrorCodes is the guide's list", () {
    test('the same 15 codes both ways', () {
      final guide = guideCodes();
      expect(guide, hasLength(15));
      expect(ApiErrorCodes.all.difference(guide), isEmpty, reason: 'extra');
      expect(guide.difference(ApiErrorCodes.all), isEmpty, reason: 'missing');
    });

    test('each code is its exception', () {
      final expected = <String, (int, Type)>{
        ApiErrorCodes.validationFailed: (400, ValidationException),
        ApiErrorCodes.tokenExpired: (401, TokenExpiredException),
        ApiErrorCodes.unauthenticated: (401, UnauthenticatedException),
        ApiErrorCodes.passwordChangeRequired: (
          403,
          PasswordChangeRequiredException,
        ),
        ApiErrorCodes.policyDenied: (403, PolicyDeniedException),
        ApiErrorCodes.forbidden: (403, ForbiddenException),
        ApiErrorCodes.notFound: (404, NotFoundException),
        ApiErrorCodes.conflict: (409, ConflictException),
        ApiErrorCodes.sessionFull: (409, ScanSessionException),
        ApiErrorCodes.sessionEnded: (409, ScanSessionException),
        ApiErrorCodes.sessionNotYours: (409, ScanSessionException),
        ApiErrorCodes.rateLimited: (429, RateLimitedException),
        ApiErrorCodes.appPreparing: (503, AppPreparingException),
        ApiErrorCodes.serviceUnavailable: (503, ServiceUnavailableException),
        ApiErrorCodes.internalError: (500, InternalErrorException),
      };
      expect(expected.keys.toSet(), ApiErrorCodes.all);
      for (final MapEntry(key: code, value: (status, type))
          in expected.entries) {
        final e = map(code, status);
        expect(e.runtimeType, type, reason: code);
        expect(e.code, code);
      }
    });
  });

  group('TC-ERR-053 edge: a code the app does not know', () {
    test('is decided by status, never by a look-alike', () {
      expect(map('TOKEN_EXPIRED', 401), isNot(isA<TokenExpiredException>()));
      expect(map('token_expired ', 401), isNot(isA<TokenExpiredException>()));
      expect(map('slow_down', 429), isA<RateLimitedException>());
      expect(map('maintenance', 503), isA<ServiceUnavailableException>());
      expect(map('teapot', 418), isA<InternalErrorException>());
      expect(ApiErrorCodes.all, isNot(contains('TOKEN_EXPIRED')));
    });
  });

  group('TC-ERR-054 worst: no code is written by hand in lib/', () {
    // A result value that happens to share a code's spelling: a check's
    // result (guide §5) and a lookup's outcome (guide §4.1), not an error.
    const results = {
      'features/history/domain/entities/check.dart': {'not_found'},
      // Written once in the enum since P-32, not in the mapper.
      'features/verification/domain/entities/lookup.dart': {'not_found'},
      'core/network/demo/postman_mock_routing.dart': {'not_found'},
    };

    test('every error code is read from ApiErrorCodes', () {
      final quoted = RegExp(
        "['\"](${ApiErrorCodes.all.join('|')})['\"]",
      );
      final found = <String>[];
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        final path = file.path.replaceAll(r'\', '/').substring(4);
        if (!path.endsWith('.dart') ||
            path.endsWith('.g.dart') ||
            path.endsWith('.freezed.dart') ||
            path.startsWith('l10n/generated/') ||
            path == 'core/errors/api_error_codes.dart') {
          continue;
        }
        final lines = file.readAsLinesSync();
        for (final (i, line) in lines.indexed) {
          for (final m in quoted.allMatches(line)) {
            if (results[path]?.contains(m.group(1)) ?? false) continue;
            found.add('$path:${i + 1} ${m.group(1)}');
          }
        }
      }
      expect(found, isEmpty);
    });
  });
}
