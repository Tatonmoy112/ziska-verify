// Checks the app's own data layer against the backend's test server
// (docs/staging-integration-2026-11-22.md), one step at a time. Run by
// hand, never in CI (automated tests stay offline):
//
//   dart run tool/staging_check/staging_check.dart <step> [<code>]
//       --out <dir> [--state <file>]
//
// Steps: connect; login; verify <code>; session; profile; lookup; history;
// stack; scan; report.
//
// The address comes from config/staging.json. Every answer is saved in
// <dir> (the scratchpad, outside the repo) so it can be cleaned of passes
// and emails and kept as a test fixture. The test login comes from
// STAGING_EMAIL and STAGING_PASSWORD. The checker's phone ID, the code's
// challenge and the passes live in the --state file (the scratchpad too);
// `session` deletes the passes when it ends. Nothing secret is printed or
// written to the repo.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/bodiless_request_interceptor.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/history/data/mappers/check_mappers.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:ziska_verify/features/incidents/data/services/incident_api_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/profile/data/mappers/profile_mapper.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';
import 'package:ziska_verify/features/retail_users/data/repositories/retail_user_repository_impl.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

const _steps =
    'connect, login, verify <code>, session, profile, lookup, history, '
    'stack, scan, report, lengths';

Future<void> main(List<String> args) async {
  String? option(String name) {
    final i = args.indexOf(name);
    return i < 0 || i + 1 >= args.length ? null : args[i + 1];
  }

  final outPath = option('--out');
  if (args.isEmpty || outPath == null) {
    stderr.writeln(
      'Usage: staging_check <step> --out <dir> [--state <file>]'
      '\nSteps: $_steps.',
    );
    exitCode = 64;
    return;
  }
  // Bangladesh time, as the app's bootstrap loads it.
  tz_data.initializeTimeZones();
  final out = Directory(outPath)..createSync(recursive: true);
  final statePath = option('--state') ?? '${out.parent.path}/state.json';
  final check = StagingCheck(_config(), out, CheckState(File(statePath)));
  switch (args.first) {
    case 'connect':
      await check.connect();
    case 'login':
      await check.login();
    case 'verify' when args.length > 1 && !args[1].startsWith('--'):
      await check.verify(args[1]);
    case 'session':
      await check.session();
    case 'profile':
      await check.profile();
    case 'lookup':
      await check.lookup();
    case 'history':
      await check.history();
    case 'stack':
      await check.stack();
    case 'scan':
      await check.scan();
    case 'report':
      await check.report();
    case 'lengths':
      await check.lengths();
    default:
      stderr.writeln('Unknown step "${args.first}". Steps: $_steps.');
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

/// The checker's phone ID, the code's challenge and the passes, between
/// runs. Kept outside the repo; the passes are removed when a session ends.
class CheckState {
  CheckState(this.file);

  final File file;

  Map<String, dynamic> read() => file.existsSync()
      ? jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  void write(Map<String, dynamic> values) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(values));
  }

  String phoneId() {
    final values = read();
    final id =
        values['phone_id'] as String? ??
        SecurePhoneIdService.generate(Random.secure());
    write({...values, 'phone_id': id});
    return id;
  }
}

class StagingCheck {
  StagingCheck(this.config, this.out, this._state)
    : dio = Dio(DioFactory.options(config.apiRoot)) {
    // As the app sends them: a request without a body has no type.
    dio.interceptors.addAll([
      const BodilessRequestInterceptor(),
      _Recorder(out),
    ]);
    api = ApiClient(dio);
  }

  final AppConfig config;
  final Directory out;
  final CheckState _state;
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

  ({String email, String password})? _login() {
    final email = Platform.environment['STAGING_EMAIL'];
    final password = Platform.environment['STAGING_PASSWORD'];
    if (email == null || email.isEmpty || password == null) {
      _fail('the test login', 'set STAGING_EMAIL and STAGING_PASSWORD');
      return null;
    }
    return (email: email, password: password);
  }

  /// Keeps a logged-in answer's passes; says whether it is one.
  bool _keepPasses(String what, LoginResponseDto answer) {
    if (answer.status != 'logged_in' ||
        answer.accessToken == null ||
        answer.refreshToken == null) {
      _fail(what, 'status ${answer.status} without both passes');
      return false;
    }
    _state.write(
      {
        ..._state.read(),
        'access': answer.accessToken,
        'refresh': answer.refreshToken,
      }..remove('challenge'),
    );
    final change = answer.mustChangePassword ?? false;
    _pass(
      what,
      'logged_in, both passes, must_change_password: $change'
      '${answer.passwordChangeSkippable == null ? '' : ', skippable: '
                '${answer.passwordChangeSkippable}'}',
    );
    if (change) {
      stdout.writeln(
        '\nSTOP  The server asks for a new password. Ask the owner first.',
      );
    }
    return true;
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

  /// Step 2a: the login, read by the app's own login parser. A new phone
  /// gets a code by email (then `verify <code>`); a trusted one logs in.
  Future<void> login() async {
    final login = _login();
    if (login == null) return;
    final phoneId = _state.phoneId();
    try {
      final answer = await DioAuthApiService(api).login(
        email: login.email,
        password: login.password,
        phoneId: phoneId,
      );
      switch (answer.status) {
        case 'code_sent' when answer.challengeId != null:
          _state.write({..._state.read(), 'challenge': answer.challengeId});
          _pass('POST auth/login', 'code_sent with a challenge_id');
          stdout.writeln(
            '\nA 6-digit code was emailed (valid 5 minutes): '
            'run `verify <code>`.',
          );
        case 'logged_in':
          _keepPasses('POST auth/login (trusted phone)', answer);
        default:
          _fail('POST auth/login', 'status ${answer.status}');
      }
    } on AppException catch (e) {
      _fail('POST auth/login', '${e.statusCode} ${e.code} ${e.requestId}');
    } on Object catch (e) {
      _fail('POST auth/login', e);
    }
  }

  /// Step 2b: the emailed code, read by the app's own login parser.
  Future<void> verify(String code) async {
    final challenge = _state.read()['challenge'] as String?;
    if (challenge == null) {
      _fail('POST auth/verify-phone', 'no challenge: run `login` first');
      return;
    }
    try {
      final answer = await DioAuthApiService(api).verifyPhone(
        challengeId: challenge,
        code: code,
        phoneId: _state.phoneId(),
      );
      _keepPasses('POST auth/verify-phone', answer);
    } on AppException catch (e) {
      _fail(
        'POST auth/verify-phone',
        '${e.statusCode} ${e.code} ${e.requestId}',
      );
    } on Object catch (e) {
      _fail('POST auth/verify-phone', e);
    }
  }

  /// Step 2c: the logged-in session. The profile and a route that needs
  /// the pass; a renewal (two new passes); the used refresh pass sent again
  /// (the guide: that ends the login); a log-out; and a new login on the
  /// now trusted phone, with no code. The passes are deleted at the end.
  Future<void> session() async {
    var values = _state.read();
    var access = values['access'] as String?;
    var refresh = values['refresh'] as String?;
    if (access == null || refresh == null) {
      _fail('the session', 'no passes: run `login` (and `verify`) first');
      return;
    }
    void useAccess(String pass) =>
        dio.options.headers['Authorization'] = 'Bearer $pass';
    useAccess(access);

    try {
      final me = await DioProfileApiService(api).getMe();
      _pass(
        'GET me',
        'role "${me.role}", ${me.permissions.length} permissions '
            '(${me.permissions.join(', ')}), must_change_password: '
            '${me.mustChangePassword}',
      );
    } on Object catch (e) {
      _fail('GET me', e);
    }

    try {
      await api.get('formats');
      _pass('GET formats with the pass', '200');
    } on Object catch (e) {
      _fail('GET formats with the pass', e);
    }

    // Renewal, as the app's session service does it.
    final used = refresh;
    try {
      final data = await _refresh(refresh);
      final nextAccess = data['access_token'];
      final nextRefresh = data['refresh_token'];
      if (nextAccess is! String || nextRefresh is! String) {
        _fail('POST auth/refresh', 'without both passes');
      } else if (nextRefresh == used || nextAccess == access) {
        _fail('POST auth/refresh', 'a pass was not replaced');
      } else {
        access = nextAccess;
        refresh = nextRefresh;
        _state.write({..._state.read(), 'access': access, 'refresh': refresh});
        useAccess(access);
        _pass('POST auth/refresh', 'two new passes');
      }
    } on Object catch (e) {
      _fail('POST auth/refresh', e);
    }

    try {
      await api.get('me');
      _pass('GET me with the new pass', '200');
    } on Object catch (e) {
      _fail('GET me with the new pass', e);
    }

    try {
      await DioAuthApiService(api).logout();
      _pass('POST auth/logout', '200');
    } on Object catch (e) {
      _fail('POST auth/logout', e);
    }

    try {
      await api.get('me');
      _fail('GET me after logout', 'answered 200');
    } on UnauthenticatedException catch (e) {
      _pass('GET me after logout', '401 ${e.code}');
    } on Object catch (e) {
      _fail('GET me after logout', e);
    }

    // The refresh pass used before the renewal, sent again: refused.
    try {
      await _refresh(used);
      _fail('POST auth/refresh with a used pass', 'answered 200');
    } on UnauthenticatedException catch (e) {
      _pass('POST auth/refresh with a used pass', '401 ${e.code}');
    } on Object catch (e) {
      _fail('POST auth/refresh with a used pass', e);
    }
    dio.options.headers.remove('Authorization');

    // The phone is trusted now: a new login needs no code.
    final login = _login();
    if (login != null) {
      try {
        final answer = await DioAuthApiService(api).login(
          email: login.email,
          password: login.password,
          phoneId: _state.phoneId(),
        );
        if (answer.status == 'logged_in' &&
            _keepPasses('POST auth/login on the trusted phone', answer)) {
          useAccess(answer.accessToken!);
          await DioAuthApiService(api).logout();
          _pass('POST auth/logout (again)', '200');
        } else if (answer.status != 'logged_in') {
          _fail(
            'POST auth/login on the trusted phone',
            'status ${answer.status}: a code again',
          );
        }
      } on Object catch (e) {
        _fail('POST auth/login on the trusted phone', e);
      }
    }

    // Only the phone ID stays.
    values = _state.read()
      ..remove('access')
      ..remove('refresh')
      ..remove('challenge');
    _state.write(values);
  }

  /// Logs in on the trusted phone (no code) for a read-only step; `null`
  /// when that is not possible.
  Future<bool> _logInTrusted() async {
    final login = _login();
    if (login == null) return false;
    try {
      final answer = await DioAuthApiService(api).login(
        email: login.email,
        password: login.password,
        phoneId: _state.phoneId(),
      );
      if (answer.status != 'logged_in' || answer.accessToken == null) {
        _fail('login on the trusted phone', 'status ${answer.status}');
        return false;
      }
      dio.options.headers['Authorization'] = 'Bearer ${answer.accessToken}';
      return true;
    } on Object catch (e) {
      _fail('login on the trusted phone', e);
      return false;
    }
  }

  Future<void> _logOut() async {
    try {
      await DioAuthApiService(api).logout();
    } on Object catch (e) {
      _fail('POST auth/logout', e);
    }
    dio.options.headers.remove('Authorization');
  }

  /// Step 3: the profile, read by the app's own parser and mapper, and one
  /// route for each permission it lists (read only).
  Future<void> profile() async {
    if (!await _logInTrusted()) return;
    var permissions = const <String>{};
    try {
      final me = (await DioProfileApiService(api).getMe()).toEntity();
      permissions = me.permissions;
      final organisation = me.organisation ?? 'none';
      _pass(
        'GET me',
        'role "${me.role}"; organisation "$organisation"; '
            'support ${me.supportEmail ?? '-'} / ${me.supportPhone ?? '-'}; '
            'pending change: ${me.passwordChangePending}',
      );
      _pass('the permissions', me.permissions.join(', '));
    } on Object catch (e) {
      _fail('GET me', e);
    }

    // What each permission opens in the app, and a read-only route of it.
    final routes = <String, (String, Map<String, Object?>)>{
      'item:lookup': ('formats', {}),
      'history:own': ('checks', {'limit': 1}),
      'item:bulk_lookup': ('lookups/sessions', {'limit': 1}),
      'incident:report': ('incidents', {'limit': 1}),
    };
    for (final MapEntry(key: permission, value: (path, query))
        in routes.entries) {
      final granted = permissions.contains(permission);
      try {
        await api.get(path, query: query);
        if (granted) {
          _pass('GET $path ($permission)', '200');
        } else {
          _fail('GET $path ($permission)', '200 without the permission');
        }
      } on ForbiddenException catch (e) {
        if (granted) {
          _fail('GET $path ($permission)', '403 ${e.code} with it');
        } else {
          _pass('GET $path ($permission)', '403 without it');
        }
      } on Object catch (e) {
        _fail('GET $path ($permission)', e);
      }
    }
    if (permissions.contains('incident:report')) {
      try {
        await api.get('retail-users', query: {'search': 'a', 'limit': 1});
        _pass('GET retail-users (incident:report)', '200');
      } on Object catch (e) {
        _fail('GET retail-users (incident:report)', e);
      }
    }
    await _logOut();
  }

  /// Step 4: single checks. Each input is prepared by the app's own rules
  /// (the server's formats), sent, and read by the app's own parser and
  /// mapper. Every check sent is recorded in the account's history. Two
  /// requests the app never sends show the server's 400.
  Future<void> lookup() async {
    if (!await _logInTrusted()) return;
    final service = DioVerificationApiService(api);
    final InputFormats formats;
    try {
      formats = (await service.getFormats()).toEntity();
      _pass(
        'GET formats',
        'serial up to ${formats.serialMaxDigits} digits; QR '
            '${formats.qr.length} of "${formats.qr.characters}"',
      );
    } on Object catch (e) {
      _fail('GET formats', e);
      await _logOut();
      return;
    }

    final tries = <(LookupWay, String)>[
      for (final serial in [
        '1000001',
        '1000002',
        '1000003',
        '1000004',
        '1',
        '1234567890',
        '0000000000000000001',
      ])
        (LookupWay.serial, serial),
      (LookupWay.qr, 'https://www.ziskaverify.com/q/Q8F2KD91XA7M'),
      (LookupWay.qr, 'https://www.ziskaverify.com/q/K7M2PX4Q9AB1'),
    ];
    final found = <String, List<String>>{};
    for (final (way, raw) in tries) {
      final prepared = const PrepareInput()(way, raw, formats);
      if (prepared is! ReadyInput) {
        _fail('prepare ${way.wire} $raw', 'refused by the app');
        continue;
      }
      final what = 'POST lookups ${way.wire} ${prepared.value}';
      try {
        final result = (await service.lookup(
          way: way.wire,
          value: prepared.value,
        )).toEntity();
        final item = result.item;
        final count = result.count;
        final picture = item?.product.pictureUrl;
        final detail = [
          result.outcome.name,
          if (result.reasons.isNotEmpty)
            'reasons ${result.reasons.map((r) => r.name).join('+')}',
          'ref ${result.ref}',
          if (count != null)
            'check ${count.thisCheck}, last ${count.lastAt ?? '-'}',
          if (item != null) 'item ${item.serial} "${item.product.name}"',
          if (item != null) 'batch ${item.batch.number}',
          if (item != null)
            'picture ${picture == null ? 'none' : Uri.parse(picture).host}',
        ].join('; ');
        if (result.outcome == LookupOutcome.unknown) {
          _fail(what, 'a result the app does not know: $detail');
        } else {
          _pass(what, detail);
          (found[result.outcome.name] ??= []).add(prepared.value);
        }
        if (picture != null) await _picture(picture);
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code} ${e.requestId}');
      } on Object catch (e) {
        _fail(what, e);
      }
    }

    // What the app never sends: the server's own refusal.
    for (final (way, value, why) in [
      ('serial', '12AB', 'letters in a serial'),
      ('hidden_code', 'ABC123', 'the removed hidden-code way'),
    ]) {
      try {
        await service.lookup(way: way, value: value);
        _fail('POST lookups $why', 'answered 200');
      } on ValidationException catch (e) {
        _pass('POST lookups $why', '400 ${e.code}');
      } on Object catch (e) {
        _fail('POST lookups $why', e);
      }
    }
    stdout.writeln('\nFound by result: $found');
    await _logOut();
  }

  /// A product picture as the app loads it: HTTPS, no pass.
  Future<void> _picture(String url) async {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https') {
      _fail('the picture', 'not https: $url');
      return;
    }
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      _pass(
        'the picture ${uri.host}',
        '${response.statusCode} ${response.headers.value('content-type')} '
            '${response.data?.length ?? 0} bytes',
      );
    } on Object catch (e) {
      _fail('the picture ${uri.host}', e);
    }
  }

  /// Step 5: History and the sessions list (read only), through the app's
  /// own query builder, parser and mapper.
  Future<void> history() async {
    if (!await _logInTrusted()) return;
    final service = DioHistoryApiService(api);
    final verification = DioVerificationApiService(api);
    String? name;
    try {
      name = (await DioProfileApiService(api).getMe()).toEntity().name;
    } on Object catch (e) {
      _fail('GET me', e);
    }

    Future<CheckPage?> page(
      String what,
      CheckQuery query, {
      int limit = PageRequest.defaultLimit,
      String? cursor,
    }) async {
      try {
        return (await service.getChecks(
          query,
          PageRequest(limit: limit, cursor: cursor),
        )).toEntity();
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code} ${e.requestId}');
      } on Object catch (e) {
        _fail(what, e);
      }
      return null;
    }

    // The first page, as the app asks for it.
    final first = await page('GET checks', const CheckQuery());
    if (first == null) return _logOut();
    final totals = first.totals;
    final items = first.page.items;
    if (totals == null) {
      _fail('GET checks', 'no totals on the first page');
    } else {
      final sum =
          totals.valid + totals.warning + totals.notFound + totals.unassigned;
      final ok = sum == totals.total;
      (ok ? _pass : _fail)(
        'GET checks: totals',
        'total ${totals.total} = valid ${totals.valid} + warning '
            '${totals.warning} + not found ${totals.notFound} + not in a '
            'batch ${totals.unassigned}${ok ? '' : ' (they do not add up)'}',
      );
    }
    final newest = items.isEmpty ? null : items.first;
    _pass(
      'GET checks: rows',
      '${items.length} on the first page; newest ${newest?.ref} '
          '${newest?.result.name} at ${newest?.at.toUtc()}; next '
          '${first.page.nextCursor ?? 'none'}',
    );
    final sorted = [
      for (var i = 1; i < items.length; i++)
        !items[i].at.isAfter(items[i - 1].at),
    ].every((x) => x);
    (sorted ? _pass : _fail)('GET checks: order', 'newest first');
    final others = items.where((c) => c.official != name).length;
    (others == 0 ? _pass : _fail)(
      'GET checks: own only',
      others == 0 ? "every row is the official's" : '$others rows of others',
    );

    // Paging, 5 at a time: every row once, in order, until no cursor.
    final seen = <String>[];
    String? cursor;
    var pages = 0;
    do {
      final next = await page(
        'GET checks (page ${pages + 1} of 5)',
        const CheckQuery(),
        limit: 5,
        cursor: cursor,
      );
      if (next == null) break;
      pages++;
      if (pages > 1 && next.totals != null) {
        _fail('GET checks: page $pages', 'totals on a later page');
      }
      seen.addAll(next.page.items.map((c) => c.ref));
      cursor = next.page.nextCursor;
    } while (cursor != null && pages < 20);
    final unique = seen.toSet().length == seen.length;
    final all = totals == null || seen.length == totals.total;
    (unique && all ? _pass : _fail)(
      'GET checks: paging by 5',
      '$pages pages, ${seen.length} rows, '
          '${unique ? 'none twice' : 'some twice'}; '
          '${all ? 'all of them' : 'total ${totals.total}'}',
    );

    // Each filter: its rows match it, and the totals agree.
    for (final result in CheckResult.values.where(
      (r) => r != CheckResult.unknown,
    )) {
      final filtered = await page(
        'GET checks result=${result.wire}',
        CheckQuery(result: result),
      );
      if (filtered == null) continue;
      final wrong = filtered.page.items.where((c) => c.result != result);
      (wrong.isEmpty ? _pass : _fail)(
        'GET checks result=${result.wire}',
        '${filtered.page.items.length} rows'
            '${wrong.isEmpty ? '' : ', ${wrong.length} of another result'}',
      );
    }
    for (final way in [CheckWay.serial, CheckWay.qr]) {
      final filtered = await page(
        'GET checks way=${way.wire}',
        CheckQuery(way: way),
      );
      if (filtered == null) continue;
      final wrong = filtered.page.items.where((c) => c.way != way);
      (wrong.isEmpty ? _pass : _fail)(
        'GET checks way=${way.wire}',
        '${filtered.page.items.length} rows'
            '${wrong.isEmpty ? '' : ', ${wrong.length} of another way'}',
      );
    }

    // Today in Bangladesh, as the app's date picker gives it.
    final dhaka = DisplayTime.inZone(DateTime.now());
    final today = DateTime(dhaka.year, dhaka.month, dhaka.day);
    final todays = await page(
      'GET checks from=to=today',
      CheckQuery(from: today, to: today),
    );
    if (todays != null) {
      _pass(
        'GET checks from=to=${today.toIso8601String().substring(0, 10)}',
        "${todays.page.items.length} rows (all of today's)",
      );
    }

    // Searches: a serial, a reference, the serial with leading zeros.
    for (final search in ['1', ?newest?.ref, '0000000000000000001']) {
      final found = await page(
        'GET checks search=$search',
        CheckQuery(search: search),
      );
      if (found != null) {
        final rows = found.page.items
            .take(6)
            .map((c) => '${c.serial ?? '-'}/${c.ref}')
            .join(', ');
        _pass(
          'GET checks search=$search',
          '${found.page.items.length} rows: $rows',
        );
      }
    }

    // The sessions list, as the app's Sessions view asks for it.
    try {
      final sessions = await verification.sessions(
        const SessionQuery(),
        const PageRequest(),
      );
      _pass(
        'GET lookups/sessions',
        '${sessions.sessions.length} sessions; next '
            '${sessions.nextCursor ?? 'none'}',
      );
    } on Object catch (e) {
      _fail('GET lookups/sessions', e);
    }
    await _logOut();
  }

  /// Step 6: serial stacks. Each stack goes as the app sends it and is
  /// read as its repository reads it: rows in the order sent, each with the
  /// serial as sent. Every serial is a recorded check.
  Future<void> stack() async {
    if (!await _logInTrusted()) return;
    final service = DioVerificationApiService(api);

    /// Sends [serials]; checks the rows against what was sent, as the
    /// app's repository does; returns the stack's session ID.
    Future<String?> send(String what, List<String> serials) async {
      try {
        // As the app's repository sends them: each item once (B5).
        final expected = distinctSerials(serials);
        final data = await service.serials(expected);
        final dto = SerialStackDto.fromJson(data);
        final sent = dto.items.map((i) => i.serial).toList();
        final raw = (data['items'] as List).cast<Map<String, dynamic>>();
        String outcome(int i) =>
            LookupResultDto.fromJson(raw[i]).toEntity().outcome.name;
        final rows = [
          for (final (i, item) in dto.items.indexed)
            '${item.serial}: ${outcome(i)}',
        ].join(', ');
        final matches =
            sent.length == expected.length &&
            dto.session.scanned == expected.length &&
            [
              for (var i = 0; i < sent.length; i++) sent[i] == expected[i],
            ].every((x) => x);
        (matches ? _pass : _fail)(
          what,
          'session ${dto.session.id.substring(0, 8)}… kind '
          '${data['session'] is Map ? (data['session'] as Map)['kind'] : '?'}, '
          'scanned ${dto.session.scanned}; $rows'
          '${matches ? '' : ' (the rows do not match what was sent: '
                    'the app would show "recorded, cannot be shown")'}',
        );
        return dto.session.id;
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code} ${e.requestId}');
      } on Object catch (e) {
        _fail(what, e);
      }
      return null;
    }

    final id = await send('POST lookups/serials [1, 1000001, 1234567890]', [
      '1',
      '1000001',
      '1234567890',
    ]);
    await send(
      'POST lookups/serials [001, 1] (leading zeros; the app sends 001 once)',
      ['001', '1'],
    );

    // What the app never sends: a repeat, 51 serials, letters.
    try {
      final data = await service.serials(['1000002', '1000002']);
      final items = data['items'] as List;
      (items.length == 1 ? _pass : _fail)(
        'POST lookups/serials a repeat (sent raw)',
        '${items.length} row(s): a repeat is checked once',
      );
    } on Object catch (e) {
      _fail('POST lookups/serials a repeat (sent raw)', e);
    }
    for (final (what, serials) in [
      ('51 serials', [for (var i = 1; i <= 51; i++) '${2000000 + i}']),
      ('a serial with letters', ['12AB']),
    ]) {
      try {
        final data = await service.serials(serials);
        _fail(
          'POST lookups/serials $what (sent raw)',
          '200 (${(data['items'] as List).length} rows): the guide says 400',
        );
      } on ValidationException catch (e) {
        _pass('POST lookups/serials $what (sent raw)', '400 ${e.code}');
      } on Object catch (e) {
        _fail('POST lookups/serials $what (sent raw)', e);
      }
    }

    // The stack as the app reads it back: a session, and its checks.
    if (id != null) {
      try {
        final summary = (await service.session(id)).toEntity();
        _pass(
          'GET lookups/sessions/{stack}',
          'kind ${summary.kind.name}, ${summary.status.name}, scanned '
              '${summary.totals.scanned}',
        );
      } on Object catch (e) {
        _fail('GET lookups/sessions/{stack}', e);
      }
      try {
        final checks = (await DioHistoryApiService(api).getChecks(
          CheckQuery(sessionId: id),
          const PageRequest(),
        )).toEntity();
        final inSession = checks.page.items.every((c) => c.sessionId == id);
        (checks.page.items.length == 3 && inSession ? _pass : _fail)(
          'GET checks?session_id={stack}',
          '${checks.page.items.length} checks'
              '${inSession ? ', all of this stack' : ', some of another'}',
        );
      } on Object catch (e) {
        _fail('GET checks?session_id={stack}', e);
      }
    }
    try {
      final sessions = await service.sessions(
        const SessionQuery(),
        const PageRequest(),
      );
      final list = sessions.sessions
          .map((x) => '${x.kind}/${x.status}/${x.scanned}')
          .join(', ');
      _pass(
        'GET lookups/sessions',
        '${sessions.sessions.length} sessions: $list',
      );
    } on Object catch (e) {
      _fail('GET lookups/sessions', e);
    }
    await _logOut();
  }

  /// Step 7: a scanner session. Each scan goes as the app's scanner sends
  /// it (`way: qr` with the session's UUID) and is read as its repository
  /// reads it: the answer's session must be the one sent.
  Future<void> scan() async {
    if (!await _logInTrusted()) return;
    final service = DioVerificationApiService(api);
    final InputFormats formats;
    try {
      formats = (await service.getFormats()).toEntity();
    } on Object catch (e) {
      _fail('GET formats', e);
      await _logOut();
      return;
    }

    /// A scan as the repository reads it; `null` when it failed.
    Future<(LookupResult, bool, SessionTotals)?> send(
      String what,
      String raw,
      String id,
    ) async {
      final prepared = const PrepareInput()(LookupWay.qr, raw, formats);
      if (prepared is! ReadyInput) {
        _fail(what, 'refused by the app');
        return null;
      }
      try {
        final data = await service.scan(prepared.value, id);
        final dto = ScanResultDto.fromJson(data);
        final result = LookupResultDto.fromJson(data).toEntity();
        final totals = dto.session.toEntity();
        final detail =
            '${result.outcome.name}, ref ${result.ref}, repeat ${dto.repeat}; '
            'session scanned ${totals.scanned} (valid ${totals.valid}, '
            'warning ${totals.warning}, not found ${totals.notFound}, '
            'unassigned ${totals.unassigned}), left ${totals.left}';
        if (dto.session.id != id) {
          _fail(what, 'another session in the answer: $detail');
          return null;
        }
        if (result.outcome == LookupOutcome.unknown) {
          _fail(what, 'a result the app does not know: $detail');
          return null;
        }
        _pass(what, detail);
        return (result, dto.repeat, totals);
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code} ${e.requestId}');
      } on Object catch (e) {
        _fail(what, e);
      }
      return null;
    }

    // A pass or a fail by [ok], as the checks below read best.
    // ignore: avoid_positional_boolean_parameters
    void expect(String what, bool ok, String detail) =>
        (ok ? _pass : _fail)(what, detail);

    const a = 'https://www.ziskaverify.com/q/Q8F2KD91XA7M';
    const b = 'https://www.ziskaverify.com/q/K7M2PX4Q9AB1';
    final id = ActiveScanStore.newId();
    stdout.writeln('Session ${id.substring(0, 8)}…');

    // The first scan starts the session; a second item; the first again.
    final first = await send('scan 1: QR A starts the session', a, id);
    final second = await send('scan 2: QR B', b, id);
    final again = await send('scan 3: QR A again (a repeat)', a, id);
    if (first != null && second != null && again != null) {
      expect(
        'the counter',
        first.$3.scanned == 1 && second.$3.scanned == 2,
        'scanned ${first.$3.scanned}, then ${second.$3.scanned}',
      );
      expect(
        'left',
        first.$3.left != null && second.$3.left == first.$3.left! - 1,
        '${first.$3.left}, then ${second.$3.left} (5,000 in all)',
      );
      expect(
        'the repeat',
        again.$2 &&
            !first.$2 &&
            again.$1.ref == first.$1.ref &&
            again.$1.outcome == first.$1.outcome &&
            again.$3.scanned == 2,
        'repeat ${again.$2}, ref ${again.$1.ref == first.$1.ref ? 'the '
                  "first scan's" : 'a new one'}, scanned ${again.$3.scanned}',
      );
    }

    // The session read back, as after a crash (guide section 4.6).
    try {
      final summary = (await service.session(id)).toEntity();
      expect(
        'GET lookups/sessions/{id} (open)',
        summary.kind == SessionKind.qr &&
            summary.status == ScanStatus.open &&
            summary.totals.scanned == 2,
        'kind ${summary.kind.name}, ${summary.status.name}, scanned '
            '${summary.totals.scanned}',
      );
    } on Object catch (e) {
      _fail('GET lookups/sessions/{id} (open)', e);
    }
    try {
      final checks = (await DioHistoryApiService(api).getChecks(
        CheckQuery(sessionId: id),
        const PageRequest(limit: 100),
      )).toEntity();
      final rows = checks.page.items;
      expect(
        'GET checks?session_id={id}',
        rows.length == 2 && rows.every((c) => c.sessionId == id),
        '${rows.length} checks: '
            '${rows.map((c) => '${c.way?.wire}/${c.result.name}').join(', ')}',
      );
    } on Object catch (e) {
      _fail('GET checks?session_id={id}', e);
    }

    // End, twice: the same answer.
    for (final what in ['POST lookups/sessions/{id}/end', '... again']) {
      try {
        await service.endSession(id);
        _pass(what, '200');
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code} ${e.requestId}');
      }
    }
    try {
      final summary = (await service.session(id)).toEntity();
      expect(
        'GET lookups/sessions/{id} (ended)',
        summary.status == ScanStatus.ended && summary.totals.scanned == 2,
        '${summary.status.name}, scanned ${summary.totals.scanned}',
      );
    } on Object catch (e) {
      _fail('GET lookups/sessions/{id} (ended)', e);
    }

    // A scan in the ended session: the app starts a new one and sends the
    // scan again in it.
    try {
      await service.scan('Q8F2KD91XA7M', id);
      _fail('scan in the ended session', '200: the guide says 409');
    } on ScanSessionException catch (e) {
      expect(
        'scan in the ended session',
        e.statusCode == 409 && e.code == 'session_ended',
        '${e.statusCode} ${e.code}',
      );
    } on Object catch (e) {
      _fail('scan in the ended session', e);
    }
    final next = ActiveScanStore.newId();
    final rolled = await send('the same scan in a new session', a, next);
    if (rolled != null) {
      expect(
        'counted again in the new session',
        !rolled.$2 && rolled.$3.scanned == 1,
        'repeat ${rolled.$2}, scanned ${rolled.$3.scanned}',
      );
    }
    try {
      await service.endSession(next);
    } on Object catch (e) {
      _fail('end the new session', e);
    }

    // What the app never sends, and sessions that are not there.
    final unknown = ActiveScanStore.newId();
    for (final (what, body) in [
      (
        'a serial in a session (sent raw)',
        {'way': 'serial', 'value': '1', 'session_id': next},
      ),
      (
        'a session ID that is not a UUID (sent raw)',
        {'way': 'qr', 'value': 'Q8F2KD91XA7M', 'session_id': 'not-a-uuid'},
      ),
    ]) {
      try {
        await api.post('lookups', body: body);
        _fail('POST lookups $what', '200: the guide says 400');
      } on ValidationException catch (e) {
        _pass('POST lookups $what', '400 ${e.code}');
      } on Object catch (e) {
        _fail('POST lookups $what', e);
      }
    }
    for (final (what, call) in [
      ('GET lookups/sessions/{unknown}', () => service.session(unknown)),
      (
        'POST lookups/sessions/{unknown}/end',
        () => service.endSession(unknown),
      ),
    ]) {
      try {
        await call();
        _fail(what, '200: the guide says 404');
      } on NotFoundException catch (e) {
        _pass(what, '404 ${e.code}');
      } on Object catch (e) {
        _fail(what, e);
      }
    }
    await _logOut();
  }

  /// Step 8: reports, photos and retail users. One report is filed, about
  /// one of this official's checks, with three photos; everything else the
  /// server refuses without filing.
  Future<void> report() async {
    if (!await _logInTrusted()) return;
    final service = DioIncidentApiService(api);
    final reports = IncidentRepositoryImpl(service);

    // A pass or a fail by [ok].
    // ignore: avoid_positional_boolean_parameters
    void expect(String what, bool ok, String detail) =>
        (ok ? _pass : _fail)(what, detail);

    /// Expects [call] to be refused with [T]; says how.
    Future<void> refused<T extends AppException>(
      String what,
      Future<Object?> Function() call,
    ) async {
      try {
        await call();
        _fail(what, 'accepted: the guide says it is refused');
      } on AppException catch (e) {
        expect(
          what,
          e is T,
          '${e.statusCode} ${e.code}: "${e.message}"',
        );
      } on Object catch (e) {
        _fail(what, e);
      }
    }

    Future<List<Report>?> mine(String what, [String? cursor]) async {
      final page = await reports.myReports(PageRequest(cursor: cursor));
      switch (page) {
        case Success(:final value):
          return value.items;
        case Err(:final failure):
          _fail(what, failure.exception);
          return null;
      }
    }

    final before = await mine('GET incidents (before)');
    if (before == null) return _logOut();
    _pass('GET incidents (before)', '${before.length} reports');

    // One of this official's own checks, for the report to point to.
    String? ref;
    try {
      final checks = (await DioHistoryApiService(
        api,
      ).getChecks(const CheckQuery(), const PageRequest(limit: 1))).toEntity();
      ref = checks.page.items.firstOrNull?.ref;
      _pass('an own check to link', ref ?? 'none');
    } on Object catch (e) {
      _fail('an own check to link', e);
    }

    // What the server refuses, filing nothing.
    final tooLong = 'x' * (ReportRules.noteMaxLength + 1);
    for (final (what, body) in <(String, Map<String, Object?>)>[
      ('a note of spaces only', {'note': '   '}),
      ('a note of 1,001 characters', {'note': tooLong}),
    ]) {
      await refused<ValidationException>(
        'POST incidents $what',
        () => service.fileReport(body),
      );
    }
    await refused<NotFoundException>(
      'POST incidents with an unknown check',
      () => service.fileReport({
        'note': 'Test: unknown check',
        'check_ref': 'MA-2000-999999',
      }),
    );
    await refused<NotFoundException>(
      'POST incidents with an unknown retail user',
      () => service.fileReport({
        'note': 'Test: unknown retail user',
        'retail_user_id': ActiveScanStore.newId(),
      }),
    );

    // The report: a note of exactly 1,000 characters, sent with spaces and
    // a line break around it; the server removes them before counting.
    const line =
        'Test report from the mobile app integration check (step 8): '
        'label print blurred, seal cut. ';
    final note = (line * 20).substring(0, ReportRules.noteMaxLength - 1);
    final full = '$note.';
    final int id;
    try {
      id = await service.fileReport({
        'note': '  $full\n',
        'check_ref': ?ref,
      });
      _pass(
        'POST incidents (1,000 characters, spaces around)',
        '201, report $id',
      );
    } on AppException catch (e) {
      _fail(
        'POST incidents (1,000 characters, spaces around)',
        '${e.statusCode} ${e.code}: "${e.message}"',
      );
      return _logOut();
    }

    // Photos as the app prepares them: JPEG at quality 85, at most 2048 px.
    final big = img.Image(width: 2048, height: 1536);
    for (final p in big) {
      p
        ..r = (p.x * 255 ~/ 2047)
        ..g = (p.y * 255 ~/ 1535)
        ..b = ((p.x ^ p.y) & 0xff);
    }
    final jpeg = img.encodeJpg(big, quality: 85);
    final png = img.encodePng(img.Image(width: 64, height: 64));
    final small = img.encodeJpg(
      img.Image(width: 640, height: 480),
      quality: 85,
    );
    stdout.writeln(
      'Photos: JPEG 2048×1536 ${jpeg.length} bytes; PNG ${png.length}; '
      'JPEG 640×480 ${small.length}',
    );

    Future<int?> photo(
      String what,
      List<int> bytes, [
      String type = 'image/jpeg',
    ]) async {
      try {
        final n = await service.addPhoto(id, Uint8List.fromList(bytes), type);
        _pass(what, '201, n $n');
        return n;
      } on AppException catch (e) {
        _fail(what, '${e.statusCode} ${e.code}: "${e.message}"');
      } on Object catch (e) {
        _fail(what, e);
      }
      return null;
    }

    final first = await photo('photo 1: JPEG 2048 px', jpeg);
    final again = await photo('photo 1 sent again', jpeg);
    expect(
      'the same photo again',
      first != null && again == first,
      'n $first, then $again: not counted twice',
    );

    // What the server refuses before or after reading the photo.
    for (final (what, bytes, type) in [
      ('text sent as a JPEG', utf8.encode('not a photo'), 'image/jpeg'),
      ('an empty photo', <int>[], 'image/jpeg'),
      ('over 1 MB', List<int>.filled(1024 * 1024 + 1, 0xff), 'image/jpeg'),
      ('a WebP type', jpeg, 'image/webp'),
    ]) {
      await refused<ValidationException>(
        'POST photos: $what',
        () => service.addPhoto(id, Uint8List.fromList(bytes), type),
      );
    }
    await refused<NotFoundException>(
      'POST photos to an unknown report',
      () =>
          service.addPhoto(999999999, Uint8List.fromList(small), 'image/jpeg'),
    );

    await photo('photo 2: PNG', png, 'image/png');
    await photo('photo 3: JPEG 640 px', small);
    // A new photo: the same file again would answer its n once more.
    final fourth = img.encodeJpg(img.Image(width: 320, height: 240));
    await refused<ConflictException>(
      'POST photos: a 4th',
      () => service.addPhoto(id, Uint8List.fromList(fourth), 'image/jpeg'),
    );

    // The report as My reports reads it.
    final after = await mine('GET incidents (after)');
    if (after != null) {
      final filed = after.firstOrNull;
      expect(
        'GET incidents: one report more',
        after.length == before.length + 1 || after.length == 50,
        '${before.length}, then ${after.length}',
      );
      expect(
        'GET incidents: the new report first',
        filed != null &&
            filed.id == id &&
            filed.note == full &&
            filed.photos == 3 &&
            filed.checkRef == ref &&
            filed.retailUserName == null,
        filed == null
            ? 'none'
            : 'id ${filed.id}, note ${filed.note.runes.length} characters'
                  '${filed.note == full ? ' (trimmed)' : ' (not as sent)'}, '
                  'photos ${filed.photos}, check ${filed.checkRef}, '
                  'retail user ${filed.retailUserName}, at ${filed.at}',
      );
    }
    final one = await reports.myReports(const PageRequest(limit: 1));
    if (one case Success(:final value)) {
      final cursor = value.nextCursor;
      _pass('GET incidents?limit=1', 'next_cursor ${cursor ?? 'none'}');
      if (cursor != null) {
        final next = await mine('GET incidents?cursor=…', cursor);
        if (next != null) {
          expect(
            'GET incidents, the next page',
            next.every((r) => r.id != value.items.single.id),
            '${next.length} reports, none of page 1',
          );
        }
      }
    }
    await refused<ValidationException>(
      'GET incidents with another parameter',
      () => api.get('incidents', query: {'sort': 'old'}),
    );

    // The retail-user picker, as the app searches.
    final search = SearchRetailUsers(
      RetailUserRepositoryImpl(DioRetailUserApiService(api)),
    );
    for (final typed in [null, 'a', 'a' * 99 + '🙂', '  rahim  ']) {
      final shown = typed == null
          ? 'none'
          : typed.runes.length > 20
          ? '${typed.substring(0, 8)}… (${typed.runes.length} characters)'
          : '"$typed"';
      final what = 'GET retail-users search $shown';
      final found = await search(typed, const PageRequest());
      switch (found) {
        case Success(:final value):
          final names = value.items.map((u) => u.name).join(', ');
          _pass(
            what,
            '${value.items.length} retail users'
            '${value.items.isEmpty ? '' : ': $names'}',
          );
        case Err(:final failure):
          _fail(what, failure.exception);
      }
    }
    await refused<ValidationException>(
      'GET retail-users search of 101 characters (sent raw)',
      () => api.get('retail-users', query: {'search': 'a' * 101}),
    );
    await _logOut();
  }

  /// How the server counts "characters" in a limit: a search of 100 that
  /// differs in code points, UTF-16 units and UTF-8 bytes. Files nothing.
  Future<void> lengths() async {
    if (!await _logInTrusted()) return;
    for (final (what, text) in [
      ('100 letters', 'a' * 100),
      ('98 letters and an emoji', '${'a' * 98}🙂'),
      ('99 letters and an emoji', '${'a' * 99}🙂'),
      ('100 é', 'é' * 100),
      ('50 emoji', '🙂' * 50),
    ]) {
      final counts =
          '${text.runes.length} code points, ${text.length} UTF-16 units, '
          '${utf8.encode(text).length} bytes';
      try {
        await api.get('retail-users', query: {'search': text});
        stdout.writeln('INFO  search: $what ($counts)  200');
      } on AppException catch (e) {
        stdout.writeln('INFO  search: $what ($counts)  ${e.statusCode}');
      }
    }
    // A note of 1,000 code points that is 1,001 UTF-16 units. Refused if
    // the server counts units; filed (a report) if it counts code points.
    final note = '🙂${'n' * 999}';
    try {
      final id = await DioIncidentApiService(api).fileReport({'note': note});
      stdout.writeln(
        'INFO  note: 1,000 code points, 1,001 UTF-16 units  201 (report $id)',
      );
    } on AppException catch (e) {
      stdout.writeln(
        'INFO  note: 1,000 code points, 1,001 UTF-16 units  ${e.statusCode}',
      );
    }
    await _logOut();
  }

  /// `auth/refresh` as the app's session service sends it: no pass in the
  /// header, the envelope read by the app's own rules.
  Future<Map<String, dynamic>> _refresh(String refresh) async {
    try {
      final response = await dio.post<Object?>(
        'auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(headers: {'Authorization': null}),
      );
      final data = ApiEnvelope.unwrap(response.data);
      if (data is! Map<String, dynamic>) {
        throw const InternalErrorException(message: 'renewal_shape');
      }
      return data;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
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
