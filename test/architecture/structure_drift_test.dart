import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/di/locator.dart';
import 'package:ziska_verify/app/di/platform_services.dart';
import 'package:ziska_verify/app/di/register.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/route_permissions.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';
import 'package:ziska_verify/core/services/monitoring/no_op_crash_reporting_service.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

import '../fakes/fake_logger_service.dart';
import '../fakes/fake_preferences_service.dart';
import '../fakes/fake_secure_storage_service.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart' show testConfig;
import 'layer_rules.dart';

/// TC-ARCH-068 … -070 (docs/test-cases/18-architecture.md): one name and
/// one place for each kind of thing (production audit P-43).
void main() {
  final lib = readLib('lib');

  /// The files of [dir] (relative to `lib/`), generated parts left out.
  List<String> filesIn(String dir) =>
      lib.keys.where((f) => f.startsWith(dir) && !isGenerated(f)).toList();

  group('TC-ARCH-068 normal: one name and one owner each', () {
    test('use cases, DTOs and mappers are named by their area', () {
      for (final MapEntry(key: folder, value: suffix) in {
        '/domain/usecases/': '_usecases.dart',
        '/data/models/': '_dtos.dart',
        '/data/mappers/': '_mappers.dart',
      }.entries) {
        final files = lib.keys.where(
          (f) => f.startsWith('features/') && f.contains(folder),
        );
        expect(files, isNotEmpty, reason: folder);
        for (final f in files.where((f) => !isGenerated(f))) {
          expect(f, endsWith(suffix), reason: f);
        }
      }
    });

    test("an official's stored scan, by one recipe", () async {
      final storage = FakeSecureStorageService();
      final stores = ActiveScanStores(
        storage,
        client: 'ziska',
        logger: FakeLoggerService(),
      );
      final id = ActiveScanStore.newId();
      await stores.of('official-1').save(id);
      expect(
        await ActiveScanStore(
          storage,
          client: 'ziska',
          official: 'official-1',
        ).read(),
        id,
      );
      expect(await stores.of('official-2').read(), isNull);
      await stores.clear('official-1');
      expect(await stores.of('official-1').read(), isNull);
    });

    test(
      'the language is read before the app; the app owns its cubits',
      () async {
        await locator.reset();
        addTearDown(locator.reset);
        final preferences = FakePreferencesService();
        registerCore(
          config: testConfig,
          crash: const NoOpCrashReportingService(),
          logger: FakeLoggerService(),
          platform: PlatformServices(preferences: preferences),
          httpAdapter: ScriptedAdapter(
            (_) async => ScriptedAnswer(200, okBody(null)),
          ),
        );
        expect(await readLanguage(), isA<Locale>());
        expect(locator.isRegistered<LocaleCubit>(), isFalse);
      },
    );
  });

  group('TC-ARCH-069 edge: the paths a permission guards', () {
    test('every guarded path is a route path, and the list is fixed', () {
      final paths = {
        RoutePaths.history,
        RoutePaths.lookupResult,
        RoutePaths.scannerMode,
        RoutePaths.serialStack,
        RoutePaths.sessions,
        RoutePaths.myReports,
        RoutePaths.reportIncident,
      };
      expect(routePermissions.keys.toSet(), paths);
      expect(RoutePaths.sessionChecks, '${RoutePaths.sessions}/:id');
      expect(
        () => routePermissions[RoutePaths.home] = (_) => true,
        throwsUnsupportedError,
      );
    });

    test('a result needs either lookup permission; History its own', () {
      final result = routePermissions[RoutePaths.lookupResult]!;
      expect(result({Permission.lookup}), isTrue);
      expect(result({Permission.bulkLookup}), isTrue);
      expect(result({Permission.report}), isFalse);
      expect(routePermissions[RoutePaths.sessions]!({}), isFalse);
    });

    test(
      'a stored scan that cannot be cleared is logged, not thrown',
      () async {
        final logger = FakeLoggerService();
        final stores = ActiveScanStores(
          _BrokenStorage(),
          client: 'ziska',
          logger: logger,
        );
        await stores.clear('official-1');
        expect(logger.lines, hasLength(1));
        // The official's ID is not written into the log (final.md §12).
        expect(logger.lines.single, isNot(contains('official-1')));
      },
    );
  });

  group('TC-ARCH-070 worst: no drift left', () {
    test('an interface file in core holds no implementation of it', () {
      final iface = RegExp(r'^abstract interface class (\w+)', multiLine: true);
      for (final f in filesIn('core/services/')) {
        for (final m in iface.allMatches(lib[f]!)) {
          expect(
            lib[f],
            isNot(contains('implements ${m.group(1)}')),
            reason: f,
          );
          expect(f, endsWith('_service.dart'), reason: f);
        }
      }
      final logger = lib['core/services/logging/logger_service.dart']!;
      expect(logger, isNot(contains('class LogRedactor')));
      expect(logger, isNot(contains('class ReportedError')));
    });

    test('no route path written outside RoutePaths', () {
      final literal = RegExp("""['"]/[a-z]""");
      for (final f in filesIn('app/')) {
        if (f == 'app/router/route_paths.dart') continue;
        final code = lib[f]!.replaceAll(RegExp(r'//[^\n]*'), '');
        expect(literal.hasMatch(code), isFalse, reason: f);
      }
    });

    test('each piece once, typed, and logged', () {
      Iterable<String> using(Pattern p) => lib.entries
          .where((e) => !isGenerated(e.key) && e.value.contains(p))
          .map((e) => e.key);
      expect(using('ActiveScanStore('), [
        'core/services/scanner/active_scan_store.dart',
      ]);
      expect(using('registerSingleton<LocaleCubit>'), isEmpty);
      // A failure to clear the stored scan is logged (ActiveScanStores).
      expect(lib['app/app.dart'], isNot(contains('catchError')));
      expect(
        lib['core/services/session/session_state.dart'],
        contains('final AppException error;'),
      );
      expect(lib['app/shell/main_shell.dart'], isNot(contains('four tabs')));
    });

    test('a widget part is a widget, not a method; build makes nothing', () {
      final method = RegExp(
        r'^\s+Widget\??\s+(?!build\(|Function\()\w+\(',
        multiLine: true,
      );
      for (final f in [
        ...filesIn('features/'),
        ...filesIn('shared/'),
        ...filesIn('app/'),
      ]) {
        if (!f.contains('presentation/') &&
            !f.startsWith('shared/') &&
            !f.startsWith('app/')) {
          continue;
        }
        expect(
          method.allMatches(lib[f]!).map((m) => m.group(0)!.trim()),
          isEmpty,
          reason: f,
        );
      }
      final verify =
          lib['features/verification/presentation/screens/verify_screen.dart']!;
      final build = verify.substring(verify.indexOf('Widget build('));
      expect(build, isNot(contains('createSession()')));
    });

    test('the renamed files are gone', () {
      for (final f in [
        'features/history/domain/usecases/get_checks.dart',
        'features/profile/domain/usecases/get_profile.dart',
        'features/retail_users/domain/usecases/search_retail_users.dart',
        'features/history/data/models/checks_page_dto.dart',
        'features/profile/data/models/profile_dto.dart',
        'features/profile/data/mappers/profile_mapper.dart',
        'core/services/picture/picture_images.dart',
      ]) {
        expect(File('lib/$f').existsSync(), isFalse, reason: f);
      }
    });
  });
}

/// Storage that fails every call, as a locked keychain does.
class _BrokenStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<Never>.error(const FileSystemException('locked'));
}
