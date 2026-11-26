import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/app/router/route_permissions.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/core/services/monitoring/firebase_crash_reporting_service.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/lookup_messages.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// TC-ARCH-083 … -085 (docs/test-cases/18-architecture.md): what only tests
/// used is gone, and the tests read what the app reads (production audit
/// P-48).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));
  const formats = InputFormats(
    serialMaxDigits: 19,
    qr: CodeFormat(length: 12, characters: 'ABC'),
  );

  group('TC-ARCH-083 normal: what the app reads', () {
    test('History is allowed by the history:own permission', () {
      final allowed = routePermissions[RoutePaths.history]!;
      expect(allowed({Permission.ownHistory}), isTrue);
      expect(allowed({Permission.lookup, Permission.report}), isFalse);
    });

    test('a refused QR is told as "not a product QR"', () {
      expect(
        refusedMessage(
          l10n,
          const RefusedInput(LookupWay.qr, InputProblem.wrongFormat),
          formats,
        ),
        l10n.notProductQr,
      );
      expect(
        refusedMessage(
          l10n,
          const RefusedInput(LookupWay.serial, InputProblem.wrongFormat),
          formats,
        ),
        isNot(l10n.notProductQr),
      );
    });
  });

  group('TC-ARCH-084 edge: crash reporting that cannot start', () {
    test('started twice, it stays silent and reports nothing', () async {
      final service = FirebaseCrashReportingService(
        const CrashTarget(
          projectId: 'example-project',
          senderId: '0',
          apiKey: 'not-a-key',
          appId: '1:0:android:0',
        ),
      );
      await expectLater(service.initialize(), completes);
      await expectLater(service.initialize(), completes);
      expect(() => service.log('a line'), returnsNormally);
      expect(
        () => service.recordError(StateError('x'), StackTrace.current),
        returnsNormally,
      );
    });
  });

  group('TC-ARCH-085 worst: nothing in the app names them', () {
    test('the members, the colour and the translation', () {
      final lib = {
        for (final f in Directory('lib').listSync(recursive: true))
          if (f is File &&
              (f.path.endsWith('.dart') || f.path.endsWith('.arb')))
            f.path.replaceAll(r'\', '/'): f.readAsStringSync(),
      };
      // Members by their own file: another class may hold one of the same
      // name (the scanner session's `canReadHistory` is used).
      const members = {
        'lib/features/profile/domain/entities/profile.dart':
            'get canReadHistory',
        'lib/features/authentication/presentation/bloc/request_access_cubit.dart':
            'bool get waiting',
        'lib/core/services/monitoring/firebase_crash_reporting_service.dart':
            'get attempts',
      };
      for (final MapEntry(key: path, value: name) in members.entries) {
        expect(lib[path], isNotNull, reason: path);
        expect(lib[path], isNot(contains(name)), reason: path);
      }
      expect(
        lib['lib/core/services/monitoring/firebase_crash_reporting_service.dart'],
        isNot(contains('bool get started')),
      );
      // Names no other code has, anywhere in the app.
      final hits = [
        for (final MapEntry(key: path, value: text) in lib.entries)
          for (final name in [
            'successOnDark',
            'RefusedInputKind',
            'checkedByLabel',
          ])
            if (text.contains(name)) '$path: $name',
      ];
      expect(hits, isEmpty);
    });
  });
}
