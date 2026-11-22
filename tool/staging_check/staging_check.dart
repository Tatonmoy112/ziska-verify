// Checks the app's own data layer against the backend's test server
// (docs/staging-integration-2026-11-22.md), one step at a time. Run by
// hand, never in CI (automated tests stay offline):
//
//   dart run tool/staging_check/staging_check.dart <step> [<code>]
//       --out <dir> [--state <file>]
//
// Steps: connect; login; verify <code>; session; profile; lookup; history;
// stack.
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

import 'package:dio/dio.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_envelope.dart';
import 'package:ziska_verify/core/network/bodiless_request_interceptor.dart';
import 'package:ziska_verify/core/network/error_mapper.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/utils/display_time.dart';
import 'package:ziska_verify/features/authentication/data/models/auth_dtos.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/data/services/auth_api_service.dart';
import 'package:ziska_verify/features/history/data/mappers/check_mappers.dart';
import 'package:ziska_verify/features/history/data/services/history_api_service.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/profile/data/mappers/profile_mapper.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/data/services/verification_api_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

const _steps =
    'connect, login, verify <code>, session, profile, lookup, history, '
    'stack';

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
