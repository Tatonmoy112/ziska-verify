// Checks the app's own data layer against the backend's test server
// (docs/staging-integration-2026-11-22.md), one step at a time. Run by
// hand, never in CI (automated tests stay offline):
//
//   dart run tool/staging_check/staging_check.dart <step> --out <dir>
//
// The address comes from config/staging.json. Every answer is saved in
// <dir> (the scratchpad, outside the repo) so it can be cleaned of
// passes and emails and kept as a test fixture. Later steps read the test
// login from STAGING_EMAIL and STAGING_PASSWORD; nothing secret is ever
// written to the repo or printed.
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || !args.contains('--out')) {
    stderr.writeln('Usage: staging_check <step> --out <dir>');
    exitCode = 64;
    return;
  }
  final step = args.first;
  final out = Directory(args[args.indexOf('--out') + 1])
    ..createSync(recursive: true);
  final check = StagingCheck(_config(), out);
  switch (step) {
    case 'connect':
      await check.connect();
    default:
      stderr.writeln('Unknown step "$step". Steps: connect.');
      exitCode = 64;
      return;
  }
  stdout.writeln(
    '\n${check.passed} passed, ${check.failed} failed. Answers in ${out.path}',
  );
  if (check.failed > 0) exitCode = 1;
}

/// The staging build's own configuration, checked by the app's own rules.
AppConfig _config() {
  final values =
      jsonDecode(File('config/staging.json').readAsStringSync())
          as Map<String, dynamic>;
  return AppConfig.fromValues(
    flavorName: values['FLAVOR'] as String,
    baseUrl: values['API_BASE_URL'] as String,
    clientSlug: values['CLIENT_SLUG'] as String,
    officeEmail: values['OFFICE_EMAIL'] as String? ?? '',
    officePhone: values['OFFICE_PHONE'] as String? ?? '',
  );
}

class StagingCheck {
  StagingCheck(this.config, this.out)
    : dio = Dio(DioFactory.options(config.apiRoot)) {
    dio.interceptors.add(_Recorder(out));
    api = ApiClient(dio);
  }

  final AppConfig config;
  final Directory out;
  final Dio dio;
  late final ApiClient api;
  int passed = 0;
  int failed = 0;

  void _pass(String what, String detail) {
    passed++;
    stdout.writeln('PASS  $what  $detail');
  }

  void _fail(String what, Object detail) {
    failed++;
    stdout.writeln('FAIL  $what  $detail');
  }

  /// Step 1: the address, the envelope, and an error answer.
  Future<void> connect() async {
    stdout.writeln('Server: ${config.apiRoot}\n');

    // A public route, read by the app's own Sign up service and parser.
    try {
      final roles = await AccessRequestApiService(api).roles();
      if (roles.isEmpty) {
        _fail('GET roles/requestable', 'no role');
      } else {
        _pass(
          'GET roles/requestable',
          roles.map((r) => '${r.id} ${r.name}').join(', '),
        );
      }
    } on Object catch (e) {
      _fail('GET roles/requestable', e);
    }

    // A route that needs a login, asked without one: the app must read
    // the error as "not logged in" and keep its reference.
    try {
      await api.get('formats', skipAuth: true);
      _fail('GET formats without a login', 'answered 200');
    } on UnauthenticatedException catch (e) {
      if (e.requestId == null || e.requestId!.isEmpty) {
        _fail('GET formats without a login', '401 without a request_id');
      } else {
        _pass('GET formats without a login', '401 ${e.code} ${e.requestId}');
      }
    } on Object catch (e) {
      _fail('GET formats without a login', e);
    }

    // An unknown route: a 404 the app reads as "not available".
    try {
      await api.get('no-such-route', skipAuth: true);
      _fail('GET an unknown route', 'answered 200');
    } on AppException catch (e) {
      _pass(
        'GET an unknown route',
        '${e.statusCode} ${e.runtimeType} ${e.code ?? '-'}',
      );
    }
  }
}

/// Saves every answer (status, the headers that matter, the body) as
/// numbered files, for fixtures.
class _Recorder extends Interceptor {
  _Recorder(this.out);

  final Directory out;
  int _n = 0;

  void _save(Response<Object?> r) {
    final name =
        '${(++_n).toString().padLeft(2, '0')}-${r.requestOptions.method}-'
        '${r.requestOptions.path.replaceAll('/', '_')}.json';
    File('${out.path}/$name').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'method': r.requestOptions.method,
        'path': r.requestOptions.path,
        'status': r.statusCode,
        'headers': {
          for (final h in const ['content-type', 'retry-after'])
            if (r.headers.value(h) != null) h: r.headers.value(h),
        },
        'body': r.data,
      }),
    );
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _save(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) _save(response);
    handler.next(err);
  }
}
