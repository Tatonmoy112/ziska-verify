import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';

/// [CrashReportingService] on Firebase Crashlytics, for the Firebase app of
/// [_target] (production audit P-10). If Firebase cannot start (no
/// network, a wrong key, no platform), it stays silent: crash reporting
/// never stops the app.
class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService(this._target);

  final CrashTarget _target;
  FirebaseCrashlytics? _crashlytics;

  /// A start is tried once, however often it is asked.
  bool _tried = false;

  @override
  Future<void> initialize() async {
    if (_tried) return;
    _tried = true;
    try {
      // The default Firebase app: Crashlytics reports for it only.
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: _target.apiKey,
          appId: _target.appId,
          messagingSenderId: _target.senderId,
          projectId: _target.projectId,
        ),
      );
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      _crashlytics = crashlytics;
    } on Object {
      // Silent by design: nothing to report to, and nothing else to do.
      _crashlytics = null;
    }
  }

  @override
  void log(String message) {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    unawaited(crashlytics.log(message).catchError((Object _) {}));
  }

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    unawaited(
      crashlytics
          .recordError(error, stackTrace, reason: reason)
          .catchError((Object _) {}),
    );
  }
}
