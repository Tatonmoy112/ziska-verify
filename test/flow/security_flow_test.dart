import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/roles.dart';
import '../fakes/scripted_adapter.dart';
import 'harness.dart';

/// Flow tests: security (docs/test-cases/11-security.md, TC-SEC-007 and
/// later).
void main() {
  /// A whole session: login with a code, a hidden-code lookup, a password
  /// change, a retail user added. Returns the secrets typed or received.
  Future<({FlowApp app, Set<String> secrets})> wholeSession(
    WidgetTester tester,
  ) async {
    final app = await startApp(
      tester,
      profile: Roles.supervisor,
      loggedIn: false,
    );
    await app.tapText('Request access');
    await fillAccessForm(app);
    await app.tap(find.byKey(const Key('access.sendCode')));
    await app.enter(const Key('access.code'), '123456');
    await app.tap(find.byKey(const Key('access.submit')));
    await app.tapText('Back to login');
    await app.enter(const Key('login.email'), 'official@example.com');
    await app.enter(const Key('login.password'), 'login-secret-1');
    await app.tap(find.byKey(const Key('login.submit')));
    await app.enter(const Key('verify.code'), '864213');
    await app.tap(find.byKey(const Key('verify.submit')));

    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await app.tap(tab('Profile'));
    await app.tapText('Change password');
    await app.enter(const Key('change.old'), 'login-secret-1');
    await app.enter(const Key('change.new'), 'new-secret-22');
    await app.enter(const Key('change.repeat'), 'new-secret-22');
    await app.tap(find.byKey(const Key('change.submit')));

    return (
      app: app,
      secrets: {
        'login-secret-1',
        '864213',
        '1000001',
        'new-secret-22',
        'chosen-pass-1',
        // The passes and the phone ID.
        ...app.storage.values.values,
      },
    );
  }

  String everything(Object? value) => switch (value) {
    null => '',
    String() => value,
    _ => jsonEncode(value),
  };

  testWidgets('TC-SEC-007 no secret in the logs of a whole session; '
      'TC-SEC-018 HTTPS to the configured host only', (tester) async {
    final (:app, :secrets) = await wholeSession(tester);
    final log = app.logger.lines.join('\n');
    expect(log, isNotEmpty);
    for (final secret in secrets.where((s) => s.length >= 6)) {
      expect(log, isNot(contains(secret)), reason: 'logged: $secret');
    }
    for (final r in app.backend.requests) {
      expect(r.uri.scheme, 'https');
      expect(r.uri.host, testConfig.baseUrl.replaceFirst('https://', ''));
    }
  });

  testWidgets('TC-SEC-009 only the phone ID and the passes are stored', (
    tester,
  ) async {
    final (:app, secrets: _) = await wholeSession(tester);
    expect(
      app.storage.values.keys.toSet(),
      {SecureKeys.phoneId, SecureKeys.accessToken, SecureKeys.refreshToken},
    );
    // Plain storage holds preferences only: one file uses
    // shared_preferences, and it writes the language and nothing else.
    final users = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            file.readAsStringSync().contains('package:shared_preferences/'))
          file.uri.pathSegments.last,
    ];
    expect(users, ['preferences_service.dart']);
    final writes = RegExp(r'\.set\w*\(').allMatches(
      File(
        'lib/core/services/storage/preferences_service.dart',
      ).readAsStringSync(),
    );
    expect(writes.map((m) => m.group(0)), ['.setString(']);
    expect(app.preferences.language, isNull);
  });

  testWidgets('TC-SEC-020 passes only where they belong; TC-SEC-021 the '
      'phone ID only on login and code', (tester) async {
    final (:app, secrets: _) = await wholeSession(tester);
    final phoneId = app.storage.values[SecureKeys.phoneId]!;
    final passes = <String>{
      for (final r in app.backend.requests)
        if ((r.headers['Authorization'] as String?)?.startsWith('Bearer ') ??
            false)
          (r.headers['Authorization'] as String).substring(7),
    };
    for (final r in app.backend.requests) {
      final query = r.uri.query;
      final body = everything(r.data);
      for (final pass in passes) {
        expect(query, isNot(contains(pass)), reason: r.path);
        expect(body, isNot(contains(pass)), reason: r.path);
      }
      final phoneIdAllowed =
          r.path == 'auth/login' || r.path == 'auth/verify-phone';
      if (!phoneIdAllowed) {
        expect(body, isNot(contains(phoneId)), reason: r.path);
      }
      expect(query, isNot(contains(phoneId)), reason: r.path);
      expect(
        r.headers.values.map(everything).join(),
        isNot(contains(phoneId)),
      );
    }
  });

  testWidgets('TC-SEC-013 every password field is hidden at first', (
    tester,
  ) async {
    bool hidden(Key key) =>
        tester.widget<TextField>(find.byKey(key)).obscureText;

    var app = await startApp(tester, loggedIn: false);
    expect(hidden(const Key('login.password')), isTrue);

    await app.tapText('Forgot password?');
    await app.enter(const Key('forgot.email'), 'official@example.com');
    await app.tap(find.byKey(const Key('forgot.submit')));
    expect(hidden(const Key('reset.new')), isTrue);
    expect(hidden(const Key('reset.repeat')), isTrue);

    app = await startApp(tester, profile: Roles.supervisor);
    await app.tap(tab('Profile'));
    await app.tapText('Change password');
    for (final key in ['change.old', 'change.new', 'change.repeat']) {
      expect(hidden(Key(key)), isTrue, reason: key);
    }

    app = await startApp(tester, loggedIn: false);
    await app.tapText('Request access');
    expect(hidden(const Key('access.password')), isTrue);
  });

  test('TC-SEC-015 only mailto: and tel: links can be opened', () {
    final users = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      if (text.contains('launchUrl') || text.contains('url_launcher')) {
        users.add(file.uri.pathSegments.last);
      }
    }
    expect(users, ['launcher_service.dart']);
    final launcher = File(
      'lib/core/services/launcher/launcher_service.dart',
    ).readAsStringSync();
    final schemes = RegExp(
      r"scheme: '(\w+)'",
    ).allMatches(launcher).map((m) => m.group(1)).toSet();
    expect(schemes, {'mailto', 'tel'});
  });

  testWidgets('TC-SEC-019 a cookie from the server is never sent back', (
    tester,
  ) async {
    final app = await startApp(
      tester,
      overrides: {
        'GET formats': (_) => ScriptedAnswer(
          200,
          FakeBackend.example(200, 'Input formats', '200 The formats').body,
          headers: {
            'set-cookie': ['sid=abc123; Path=/; HttpOnly'],
          },
        ),
      },
    );
    await app.enter(const Key('verify.input'), '1000001');
    await app.tap(find.byKey(const Key('verify.submit')));
    for (final r in app.backend.requests) {
      expect(
        r.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('cookie')),
        reason: r.path,
      );
    }
  });

  test('TC-SEC-023 test builds never point at a live client', () {
    Map<String, dynamic> read(String flavor) =>
        jsonDecode(File('config/$flavor.json').readAsStringSync())
            as Map<String, dynamic>;
    final live = read('live');
    for (final flavor in ['mock', 'staging']) {
      final config = read(flavor);
      expect(config['API_BASE_URL'], isNot(live['API_BASE_URL']));
      expect(config['CLIENT_SLUG'], isNot(live['CLIENT_SLUG']));
      expect((config['API_BASE_URL'] as String).startsWith('https://'), isTrue);
    }
  });
}
