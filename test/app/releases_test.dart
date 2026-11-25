import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/app/di/platform_services.dart';
import 'package:ziska_verify/app/di/register.dart';
import 'package:ziska_verify/app/router/app_router.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/features/profile/domain/repositories/profile_repository.dart';
import 'package:ziska_verify/features/profile/domain/usecases/get_profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';

import '../fakes/fake_logger_service.dart';
import '../fakes/fake_secure_storage_service.dart';
import '../fakes/fake_session_service.dart';
import '../flow/harness.dart' show testConfig;

/// A transport that records being closed.
class _Transport implements HttpClientAdapter {
  int closes = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => throw UnimplementedError();

  @override
  void close({bool force = false}) => closes++;
}

class _Profiles extends Mock implements ProfileRepository {}

/// TC-ARCH-047 … -049 (docs/test-cases/18-architecture.md): what the app
/// opens is released when it closes, so nothing is left listening or open
/// (production audit P-34).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locator = GetIt.instance;
  late _Transport transport;
  late FakeSessionService session;

  /// The app's own registrations. With [fakeSession], a session whose
  /// stream outlives the reset, so only the owners' own release ends their
  /// listeners.
  Future<void> register({bool fakeSession = true}) async {
    await locator.reset();
    transport = _Transport();
    session = FakeSessionService();
    registerCore(
      config: testConfig,
      crash: const NoOpCrashReportingService(),
      logger: FakeLoggerService(),
      platform: PlatformServices(storage: FakeSecureStorageService()),
      httpAdapter: transport,
    );
    registerFeatures();
    if (!fakeSession) return;
    // Swapped out in the open: the real session is released, then the
    // fake is registered (no registration is replaced, P-35).
    await locator.unregister<SessionService>();
    locator.registerSingleton<SessionService>(session);
  }

  tearDown(locator.reset);

  group('TC-ARCH-047 normal: the app releases what it opened', () {
    test('the verification repository stops listening', () async {
      await register();
      locator<VerificationRepository>();
      expect(session.hasListeners, isTrue);
      await locator.reset();
      expect(session.hasListeners, isFalse);
    });

    test('both network clients are closed', () async {
      // The real session, which owns the renewal client.
      await register(fakeSession: false);
      locator<ApiClient>();
      await locator.reset();
      expect(transport.closes, 2, reason: 'the API and the renewal client');
    });
  });

  group('TC-ARCH-048 edge: releasing is safe', () {
    test('twice', () async {
      final dio = Dio()..httpClientAdapter = (transport = _Transport());
      ApiClient(dio)
        ..close()
        ..close();
      expect(transport.closes, greaterThanOrEqualTo(1));
    });

    test('a repository never used is not made to be released', () async {
      await register();
      await locator.reset();
      expect(session.hasListeners, isFalse);
    });
  });

  // A plain test in real time: the router needs the binding, not a widget
  // tree, and the reset waits on real closing.
  test(
    'TC-ARCH-049 worst: routers built and released leave no listener',
    () async {
      await register();
      for (var i = 0; i < 5; i++) {
        final profile = ProfileCubit(GetProfile(_Profiles()), session);
        final router = buildRouter(locator: locator, profileCubit: profile);
        expect(session.hasListeners, isTrue);
        router
          ..dispose()
          ..dispose(); // twice: harmless
        await profile.close();
      }
      expect(session.hasListeners, isFalse);
    },
  );
}
