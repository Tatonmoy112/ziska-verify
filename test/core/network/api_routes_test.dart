import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_routes.dart';

import '../../fakes/scripted_adapter.dart';

/// TC-ARCH-026 … -028 (docs/test-cases/18-architecture.md): every route of
/// the app is in `ApiRoutes`, and `ApiRoutes` is exactly the backend's
/// routes (the Postman collection, app API guide §3 … §7; production audit
/// P-17).
void main() {
  /// The routes of the backend's collection, as `METHOD path`, with path
  /// variables written `{id}`.
  Set<String> collectionRoutes() {
    final collection =
        jsonDecode(
              File(
                'docs/protectb-api/ProtectB-mobile-app.postman_collection.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final routes = <String>{};
    void walk(List<dynamic> items) {
      for (final item in items.cast<Map<String, dynamic>>()) {
        if (item['item'] is List) {
          walk(item['item'] as List);
          continue;
        }
        final request = item['request'] as Map<String, dynamic>;
        final url = request['url'] as Map<String, dynamic>;
        final path = (url['path'] as List)
            .skip(3) // v1, clients, {{slug}}
            .map((p) => '$p'.startsWith('{{') ? '{id}' : '$p')
            .join('/');
        routes.add('${request['method']} $path');
      }
    }

    walk(collection['item'] as List);
    return routes;
  }

  String name(ApiRoute r) => '${r.method.name.toUpperCase()} ${r.template}';

  group("TC-ARCH-026 normal: ApiRoutes is the backend's list", () {
    test("every route of the backend is the app's, and no other", () {
      final backend = collectionRoutes();
      final app = ApiRoutes.all.map(name).toSet();
      expect(backend, hasLength(23));
      expect(
        app.difference(backend),
        isEmpty,
        reason: 'routes the backend does not have',
      );
      expect(
        backend.difference(app),
        isEmpty,
        reason: 'routes of the backend missing from ApiRoutes',
      );
      expect(ApiRoutes.all, hasLength(app.length), reason: 'listed twice');
    });

    test('a route without a variable is its own path', () {
      expect(ApiRoutes.login.path, 'auth/login');
      expect(ApiRoutes.login.method, ApiMethod.post);
      expect(ApiRoutes.me.path, 'me');
      expect(ApiRoutes.me.method, ApiMethod.get);
    });
  });

  group('TC-ARCH-027 edge: an ID in a path is encoded once', () {
    test('a session ID', () {
      expect(
        ApiRoutes.session('7f3c2a10-5b1e').path,
        'lookups/sessions/7f3c2a10-5b1e',
      );
      expect(ApiRoutes.session('a b/c%').path, 'lookups/sessions/a%20b%2Fc%25');
      expect(ApiRoutes.endSession('a/b').path, 'lookups/sessions/a%2Fb/end');
      expect(ApiRoutes.session('আ').path, 'lookups/sessions/%E0%A6%86');
    });

    test('a report number', () {
      expect(ApiRoutes.reportPhotos(1042).path, 'incidents/1042/photos');
    });

    test('the template stays as the contract writes it', () {
      expect(ApiRoutes.session('x').template, 'lookups/sessions/{id}');
      expect(ApiRoutes.endSession('x').template, 'lookups/sessions/{id}/end');
      expect(ApiRoutes.reportPhotos(1).template, 'incidents/{id}/photos');
    });
  });

  group('TC-ARCH-028 worst: a wrong route never leaves the phone', () {
    late List<RequestOptions> sent;
    late ApiClient api;
    setUp(() {
      sent = [];
      final dio = Dio(DioFactory.options('https://api.example.test/'))
        ..httpClientAdapter = ScriptedAdapter((r) async {
          sent.add(r);
          return ScriptedAnswer(200, okBody(null));
        });
      api = ApiClient(dio);
    });

    test('a POST route asked for with GET, and the reverse', () async {
      await expectLater(api.get(ApiRoutes.login), throwsArgumentError);
      await expectLater(api.post(ApiRoutes.me), throwsArgumentError);
      await expectLater(
        api.postBytes(ApiRoutes.checks, Uint8List(1), contentType: 'x/y'),
        throwsArgumentError,
      );
      expect(sent, isEmpty);
    });

    test('an empty ID', () {
      expect(() => ApiRoutes.session(''), throwsArgumentError);
      expect(() => ApiRoutes.endSession('  '), throwsArgumentError);
      expect(() => ApiRoutes.reportPhotos(0), throwsArgumentError);
    });

    test('every ApiRoute written in ApiRoutes is in its list', () {
      final source = File(
        'lib/core/network/api_routes.dart',
      ).readAsStringSync();
      final declared = RegExp(
        r'^  static (?:const|ApiRoute) (\w+)',
        multiLine: true,
      ).allMatches(source).map((m) => m.group(1)).toSet();
      final listed = RegExp(
        r'static final List<ApiRoute> all = \[([^\]]*)\]',
      ).firstMatch(source)!.group(1)!;
      for (final route in declared) {
        expect(listed, contains(route), reason: '$route is not in all');
      }
      expect(declared, hasLength(ApiRoutes.all.length));
    });
  });
}
