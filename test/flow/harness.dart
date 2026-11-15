import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ziska_verify/app/app.dart';
import 'package:ziska_verify/app/bootstrap.dart';
import 'package:ziska_verify/app/config/app_config.dart';
import 'package:ziska_verify/core/services/device/app_info_service.dart';
import 'package:ziska_verify/core/services/device/phone_id_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/permission/permission_service.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/shared/design_system/components/chips/count_chip.dart';

import '../fakes/fake_logger_service.dart';
import '../fakes/fake_picture_images.dart';
import '../fakes/fake_secure_storage_service.dart';
import '../fakes/postman_examples.dart';
import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';

/// Answers one request; may throw a [DioException] to simulate no network,
/// or wait to simulate a slow server.
typedef Answer = FutureOr<ScriptedAnswer> Function(RequestOptions request);

/// A backend that answers every route with its Postman example
/// (`docs/protectb-api/`), like the Postman mock, unless a test overrides
/// the route.
class FakeBackend {
  FakeBackend({required this.profile});

  Map<String, dynamic> profile;

  /// Overrides by `"METHOD path"`, for example `"POST lookups"`.
  final Map<String, Answer> overrides = {};

  final List<RequestOptions> requests = [];

  List<RequestOptions> sent(String method, String path) => [
    for (final r in requests)
      if (r.method == method && r.path == path) r,
  ];

  static ScriptedAnswer example(
    int status,
    String request,
    String name, {
    Map<String, List<String>> headers = const {},
  }) => ScriptedAnswer(
    status,
    postmanExample(request: request, example: name),
    headers: headers,
  );

  Future<ScriptedAnswer> answer(RequestOptions r) async {
    requests.add(r);
    final key = '${r.method} ${r.path}';
    final override = overrides[key];
    if (override != null) return override(r);
    return switch (key) {
      'POST auth/login' => example(
        200,
        '1. Log in',
        '200 New phone: a code was emailed',
      ),
      'POST auth/verify-phone' => example(
        200,
        '2. Verify the phone with the emailed code',
        '200 Logged in, the phone is now trusted',
      ),
      'POST auth/resend-code' => example(
        200,
        '3. Send the code again',
        '200 A new code was emailed',
      ),
      'POST auth/refresh' => example(
        200,
        'Renew the passes',
        '200 Renewed: two new passes',
      ),
      'POST auth/logout' => example(
        200,
        'Log out (this phone)',
        '200 Logged out',
      ),
      'POST auth/password/forgot' => example(
        200,
        '1. Email a reset code',
        '200 Always the same answer',
      ),
      'POST auth/password/reset' => example(
        200,
        '2. Set a new password with the code',
        '200 Changed: log in again',
      ),
      'GET me' => ScriptedAnswer(200, okBody(profile)),
      'POST me/password' => example(
        200,
        'Change the password',
        '200 Changed: a new access pass',
      ),
      'GET formats' => example(200, 'Input formats', '200 The formats'),
      'POST lookups' => example(
        200,
        'Look up one item',
        '200 valid: genuine, first check',
      ),
      'POST lookups/bulk' => example(
        200,
        'Look up many items (bulk)',
        '200 Three items',
      ),
      'GET checks' =>
        r.queryParameters['cursor'] == null
            ? example(200, 'History of checks', '200 First page')
            : example(200, 'History of checks', '200 A later page'),
      'POST incidents' => example(201, 'File a report', '201 Filed'),
      'GET incidents' => example(200, 'My own reports', '200 The reports'),
      'GET retail-users' => example(
        200,
        'Pick a retail user',
        '200 The retail users',
      ),
      'GET retail-roles' => example(
        200,
        'Retail roles',
        '200 The retail roles',
      ),
      'POST retail-users' => example(
        201,
        'Add a retail user',
        '201 Added, mail sent',
      ),
      _ when key.startsWith('POST incidents/') => example(
        201,
        'Add a photo to the report',
        '201 Uploaded as photo 1',
      ),
      _ when key.startsWith('POST retail-users/') => example(
        200,
        'Email a new first password',
        '200 Emailed',
      ),
      _ => throw StateError('No fake answer for $key'),
    };
  }
}

/// No connection: the request never reaches a server.
Answer offline() =>
    (r) => throw DioException(
      requestOptions: r,
      type: DioExceptionType.connectionError,
    );

/// No answer in time.
Answer timedOut() =>
    (r) => throw DioException(
      requestOptions: r,
      type: DioExceptionType.receiveTimeout,
    );

/// An error envelope (app API guide §1), with `Retry-After` when given.
ScriptedAnswer apiError(
  int status,
  String code, {
  int? retryAfter,
  String requestId = 'req-1',
  String? message,
}) => ScriptedAnswer(
  status,
  {
    ...errorBody(code, requestId: requestId),
    if (message != null)
      'error': {'code': code, 'message': message, 'request_id': requestId},
  },
  headers: {
    if (retryAfter != null) 'retry-after': ['$retryAfter'],
  },
);

/// A success envelope around [data].
ScriptedAnswer ok(Object? data, {int status = 200}) =>
    ScriptedAnswer(status, okBody(data));

/// Answers like [answer], after [delay]: a slow server.
Answer slow(Answer answer, [Duration delay = const Duration(seconds: 2)]) =>
    (r) async {
      await Future<void>.delayed(delay);
      return answer(r);
    };

/// The same answer every time.
Answer always(ScriptedAnswer a) =>
    (_) => a;

class FakeLauncher implements LauncherService {
  final emails = <({String to, String subject, String body})>[];
  final calls = <String>[];

  @override
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  }) async {
    emails.add((to: to, subject: subject, body: body));
    return true;
  }

  @override
  Future<bool> call(String phone) async {
    calls.add(phone);
    return true;
  }
}

/// A camera stand-in: tests "show" a QR code with [scan].
class FakeScanner implements ScannerService {
  FakeScannerSession? session;

  /// The camera fails with this problem (access denied, say) when set.
  ScannerProblem? problem;

  void scan(String raw) => session?.onCode?.call(raw);

  @override
  ScannerSession createSession() =>
      session = FakeScannerSession(problem: problem);
}

class FakeScannerSession implements ScannerSession {
  FakeScannerSession({this.problem});

  final ScannerProblem? problem;
  void Function(String raw)? onCode;

  @override
  Widget preview({
    required void Function(String raw) onCode,
    required Widget Function(BuildContext context, ScannerProblem problem)
    errorBuilder,
  }) {
    this.onCode = onCode;
    if (problem case final problem?) {
      return Builder(builder: (context) => errorBuilder(context, problem));
    }
    return const ColoredBox(
      key: Key('fake.camera'),
      color: Colors.black,
      child: SizedBox.expand(),
    );
  }

  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}

  /// How many times the torch was switched.
  int torchToggles = 0;

  @override
  Future<void> toggleTorch() async => torchToggles++;
  @override
  Future<void> dispose() async {}
}

/// A 1×1 PNG, so photo thumbnails decode in tests.
final Uint8List onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNoaGj4'
  'DwAFhAKAjM1mJgAAAABJRU5ErkJggg==',
);

class FakePhotos implements PhotoService {
  int picked = 0;

  /// The next pick fails with this problem.
  PhotoProblem? problem;

  /// The next pick is cancelled by the official.
  bool cancel = false;

  @override
  Future<PreparedPhoto?> pick(PhotoSource source) async {
    picked++;
    if (cancel) return null;
    if (problem != null) throw PhotoException(problem!);
    return PreparedPhoto(Uint8List.fromList(onePixelPng));
  }
}

class _FakeAppInfo implements AppInfoService {
  @override
  Future<({String build, String version})> versionInfo() async =>
      (version: '0.1.0', build: '1');
}

class _FakePermission implements PermissionService {
  @override
  Future<bool> openSettings() async => true;
}

/// A running app under test.
class FlowApp {
  FlowApp({
    required this.tester,
    required this.backend,
    required this.storage,
    required this.launcher,
    required this.scanner,
    required this.photos,
    required this.pictures,
    required this.logger,
  });

  final WidgetTester tester;
  final FakeBackend backend;
  final FakeSecureStorageService storage;
  final FakeLauncher launcher;
  final FakeScanner scanner;
  final FakePhotos photos;
  final FakePictureImages pictures;
  final FakeLoggerService logger;

  /// Whether the [FilledButton] inside [key] can be pressed.
  bool enabled(Key key) =>
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(key),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed !=
      null;

  /// The text now in the field with [key].
  String fieldText(Key key) =>
      tester.widget<TextField>(find.byKey(key)).controller!.text;

  Future<void> tap(Finder finder) async {
    // A floating message can cover the button for a few seconds; a person
    // waits it out, the test dismisses it.
    final messengers = find.byType(ScaffoldMessenger);
    if (messengers.evaluate().isNotEmpty) {
      tester.state<ScaffoldMessengerState>(messengers.first).clearSnackBars();
      await tester.pumpAndSettle();
    }
    await _build(finder);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    // Still covered (by the tab bar, say): centre it, as a person would
    // scroll it into plain view.
    if (finder.hitTestable().evaluate().isEmpty) {
      unawaited(
        Scrollable.ensureVisible(tester.element(finder), alignment: 0.5),
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// A lazy list builds only what is near the screen (a large font pushes
  /// a button further down): scroll the screen's list until it exists.
  Future<void> _build(Finder finder) async {
    // `.last` and `.first` throw on nothing found (tryEvaluate too).
    bool missing() {
      try {
        return finder.evaluate().isEmpty;
        // ignore: avoid_catching_errors, the finder signals "none" this way.
      } on StateError {
        return true;
      }
    }

    if (!missing()) return;
    // Every list on screen, innermost first; one in another tab is skipped.
    final lists = find.byType(Scrollable).hitTestable().evaluate().toList();
    for (final list in lists.reversed) {
      final target = find.byElementPredicate((e) => identical(e, list));
      for (var i = 0; i < 20 && missing(); i++) {
        try {
          await tester.drag(target, const Offset(0, -300), warnIfMissed: false);
        } on Object {
          break;
        }
        await tester.pumpAndSettle();
      }
      if (!missing()) return;
    }
  }

  Future<void> tapText(String text) => tap(find.text(text).last);

  Future<void> enter(Key key, String text) async {
    final field = find.byKey(key);
    await _build(field);
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  /// Waits for a debounce (search) and the answer.
  Future<void> settleAfter(Duration duration) async {
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }
}

const testConfig = AppConfig(
  flavor: AppFlavor.mock,
  baseUrl: 'https://api.example.test',
  clientSlug: 'ziska',
  officeEmail: 'office@example.com',
  officePhone: '+8800000000000',
);

bool _timezonesLoaded = false;

/// Starts the real app (router, screens, BLoCs, wiring) on [FakeBackend].
/// [loggedIn] starts with stored passes, as after an earlier login.
Future<FlowApp> startApp(
  WidgetTester tester, {
  Map<String, dynamic>? profile,
  bool loggedIn = true,
  FakeSecureStorageService? storage,
  Map<String, Answer> overrides = const {},
}) async {
  if (!_timezonesLoaded) {
    tz_data.initializeTimeZones();
    _timezonesLoaded = true;
  }
  // A phone-sized screen (390 × 844).
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // As with the phone's "Remove animations": endless decoration (the
  // scanner's scan line) holds still, so every pumpAndSettle can settle.
  // TC-UI-174 checks the line moves when animations are on.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final locator = GetIt.instance;
  await locator.reset();
  locator.allowReassignment = true;

  final backend = FakeBackend(profile: profile ?? Roles.fieldInspector);
  backend.overrides.addAll(overrides);
  final store = storage ?? FakeSecureStorageService();
  if (loggedIn && storage == null) {
    store.values[SecureKeys.accessToken] = 'access-1';
    store.values[SecureKeys.refreshToken] = 'refresh-1';
  }
  final launcher = FakeLauncher();
  final scanner = FakeScanner();
  final photos = FakePhotos();
  final pictures = FakePictureImages();
  final logger = FakeLoggerService();

  registerCore(
    config: testConfig,
    crash: const NoOpCrashReportingService(),
    logger: logger,
    storage: store,
    httpAdapter: ScriptedAdapter(backend.answer),
  );
  registerFeatures();
  locator
    ..registerSingleton<LauncherService>(launcher)
    ..registerSingleton<ScannerService>(scanner)
    ..registerSingleton<PhotoService>(photos)
    ..registerSingleton<PictureImages>(pictures)
    ..registerSingleton<AppInfoService>(_FakeAppInfo())
    ..registerSingleton<PermissionService>(_FakePermission());

  await locator<PhoneIdService>().getOrCreate();
  await locator<SessionService>().restore();
  // The test product picture, decoded once in real time (no network).
  await tester.runAsync(FakePictureImages.prepare);

  // A copy to the clipboard succeeds, as on a phone.
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => call.method == 'Clipboard.getData'
        ? <String, dynamic>{'text': ''}
        : null,
  );

  // A new key: a second start in one test is a new app, not an update.
  await tester.pumpWidget(App(key: UniqueKey(), locator: locator));
  await tester.pumpAndSettle();

  return FlowApp(
    tester: tester,
    backend: backend,
    storage: store,
    launcher: launcher,
    scanner: scanner,
    photos: photos,
    pictures: pictures,
    logger: logger,
  );
}

/// Logs in up to the code screen.
Future<void> logInToCode(FlowApp app, {String password = 'secret-pass'}) async {
  await app.enter(const Key('login.email'), 'official@example.com');
  await app.enter(const Key('login.password'), password);
  await app.tap(find.byKey(const Key('login.submit')));
}

/// The `logged_in` answer of a login or a code, with or without a forced
/// password change.
ScriptedAnswer loggedIn({bool mustChange = false}) => ok({
  'status': 'logged_in',
  'access_token': 'access-new',
  'access_expires_in': 900,
  'refresh_token': 'refresh-new',
  'refresh_expires_in': 2592000,
  'must_change_password': mustChange,
});

/// Logs in through the screens: email, password, emailed code.
Future<void> logInWithCode(FlowApp app) async {
  await app.enter(const Key('login.email'), 'official@example.com');
  await app.enter(const Key('login.password'), 'secret-pass');
  await app.tap(find.byKey(const Key('login.submit')));
  await app.enter(const Key('verify.code'), '123456');
  await app.tap(find.byKey(const Key('verify.submit')));
}

/// A tab of the bottom bar.
Finder tab(String label) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text(label),
);

const tiles = {
  'bulk': Key('verify.tool.bulk'),
  'report': Key('verify.tool.report'),
  'myReports': Key('verify.tool.myReports'),
  'retailUsers': Key('verify.tool.retailUsers'),
};

/// Checks the tabs, the lookup form, and the MORE tiles of a role.
Future<void> expectRole(
  WidgetTester tester, {
  required bool history,
  required bool lookupForm,
  required Set<String> tileNames,
  bool noFeatures = false,
}) async {
  expect(tab('Verify'), findsOneWidget);
  expect(tab('Profile'), findsOneWidget);
  expect(tab('History'), history ? findsOneWidget : findsNothing);
  expect(
    find.byKey(const Key('verify.input')),
    lookupForm ? findsOneWidget : findsNothing,
  );
  // The MORE tiles are below the fold: scroll to the end first.
  final list = find.byType(Scrollable);
  if (list.evaluate().isNotEmpty) {
    await tester.drag(list.first, const Offset(0, -3000));
    await tester.pumpAndSettle();
  }
  for (final MapEntry(:key, :value) in tiles.entries) {
    expect(
      find.byKey(value),
      tileNames.contains(key) ? findsOneWidget : findsNothing,
      reason: key,
    );
  }
  expect(
    find.text('No features yet'),
    noFeatures ? findsOneWidget : findsNothing,
  );
}

/// The count on History's result chip [result] (`all`, `valid`, `warning`,
/// `not_found`, `unassigned`); `null` while unknown.
int? historyChipCount(WidgetTester tester, String result) =>
    tester.widget<CountChip>(find.byKey(Key('history.chip.$result'))).count;

/// History's chips count the fake backend's totals: 120 checks, 80 valid,
/// 30 warning, 9 not found, 1 not in a batch.
void expectHistoryChipCounts(WidgetTester tester) {
  expect(historyChipCount(tester, 'all'), 120);
  expect(historyChipCount(tester, 'valid'), 80);
  expect(historyChipCount(tester, 'warning'), 30);
  expect(historyChipCount(tester, 'not_found'), 9);
  expect(historyChipCount(tester, 'unassigned'), 1);
}

/// History shows the tracking log of [serial]: the item card with the
/// serial, then the numbered log (final.md Section 13.4.1).
void expectTrackingLog(String serial) {
  final card = find.byKey(const Key('history.itemCard'));
  expect(card, findsOneWidget);
  expect(
    find.descendant(of: card, matching: find.text(serial)),
    findsOneWidget,
  );
  expect(find.byKey(const Key('history.trackingLog')), findsOneWidget);
  expect(find.byKey(const Key('checkTile.number')), findsWidgets);
}
