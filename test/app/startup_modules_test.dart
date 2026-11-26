import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/di/locator.dart';
import 'package:ziska_verify/app/di/platform_services.dart';
import 'package:ziska_verify/app/di/register.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/core/services/picture/picture_image_service.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/core/services/storage/preferences_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../fakes/fake_logger_service.dart';
import '../fakes/fake_picture_image_service.dart';
import '../fakes/fake_preferences_service.dart';
import '../fakes/fake_secure_storage_service.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart'
    show
        FakeConnectivityService,
        FakeLauncher,
        FakePhotos,
        FakeScanner,
        testConfig;

/// TC-ARCH-050 … -052 (docs/test-cases/18-architecture.md): the app
/// starts from small modules, and a test hands its fakes in instead of
/// overwriting registrations (production audit P-35).
void main() {
  tearDown(locator.reset);

  void register(PlatformServices platform) => registerCore(
    config: testConfig,
    logger: FakeLoggerService(),
    platform: platform,
    httpAdapter: ScriptedAdapter(
      (_) async => ScriptedAnswer(200, okBody(null)),
    ),
  );

  group('TC-ARCH-050 normal: the fakes handed in are the ones used', () {
    test('every platform service', () async {
      await locator.reset();
      final storage = FakeSecureStorageService();
      final launcher = FakeLauncher();
      final scanner = FakeScanner();
      final photos = FakePhotos();
      final pictures = FakePictureImageService();
      final connectivity = FakeConnectivityService();
      final preferences = FakePreferencesService();
      register(
        PlatformServices(
          storage: storage,
          launcher: launcher,
          scanner: scanner,
          photos: photos,
          pictures: pictures,
          connectivity: connectivity,
          preferences: preferences,
        ),
      );
      registerFeatures();
      expect(locator<SecureStorageService>(), same(storage));
      expect(locator<LauncherService>(), same(launcher));
      expect(locator<ScannerService>(), same(scanner));
      expect(locator<PhotoService>(), same(photos));
      expect(locator<PictureImageService>(), same(pictures));
      expect(locator<ConnectivityService>(), same(connectivity));
      expect(locator<PreferencesService>(), same(preferences));
    });
  });

  group('TC-ARCH-051 edge: a single fake', () {
    test('that one is used; the others are the real ones', () async {
      await locator.reset();
      final launcher = FakeLauncher();
      register(PlatformServices(launcher: launcher));
      expect(locator<LauncherService>(), same(launcher));
      // Not made: a real plugin is not started by a test.
      expect(locator.isRegistered<ScannerService>(), isTrue);
      expect(locator.isRegistered<PhotoService>(), isTrue);
    });
  });

  group('TC-ARCH-052 worst', () {
    test('registering twice fails, never silently replaces', () async {
      await locator.reset();
      register(const PlatformServices());
      expect(() => register(const PlatformServices()), throwsA(anything));
    });

    test('no test or app code replaces a registration', () {
      final found = [
        for (final dir in ['lib', 'test'])
          for (final file in Directory(dir).listSync(recursive: true))
            if (file is File &&
                file.path.endsWith('.dart') &&
                !file.path.endsWith('startup_modules_test.dart') &&
                file.readAsStringSync().contains('allowReassignment = true'))
              file.path,
      ];
      expect(found, isEmpty);
    });

    test('bootstrap only puts the steps in order', () {
      final source = File('lib/app/bootstrap.dart').readAsStringSync();
      for (final job in [
        'Dio(',
        'registerSingleton',
        'registerLazySingleton',
        'registerFactory',
        'FlutterError.onError',
        'PlatformDispatcher.instance.onError',
      ]) {
        expect(source, isNot(contains(job)), reason: job);
      }
    });
  });
}
