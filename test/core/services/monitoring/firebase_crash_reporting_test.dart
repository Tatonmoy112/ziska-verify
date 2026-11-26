import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/monitoring/firebase_crash_reporting_service.dart';

/// TC-SEC-033 (docs/test-cases/11-security.md): when Firebase cannot start
/// (no network, a wrong key, here no platform at all), crash reporting
/// stays silent and the app goes on (production audit P-10).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const target = CrashTarget(
    projectId: 'ziska-track-trace',
    senderId: '123456789012',
    apiKey: 'AIzaSy-android-key-for-tests',
    appId: '1:123456789012:android:abc123',
  );

  test('a failed start never throws, and nothing after it does', () async {
    final service = FirebaseCrashReportingService(target);
    await expectLater(service.initialize(), completes);
    expect(() => service.log('a line'), returnsNormally);
    expect(
      () => service.recordError(StateError('x'), StackTrace.current),
      returnsNormally,
    );
  });

  test('starting twice is harmless', () async {
    final service = FirebaseCrashReportingService(target);
    await service.initialize();
    await expectLater(service.initialize(), completes);
    expect(() => service.log('a line'), returnsNormally);
  });
}
