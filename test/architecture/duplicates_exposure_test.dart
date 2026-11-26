import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/app/di/locator.dart';
import 'package:ziska_verify/app/di/platform_services.dart';
import 'package:ziska_verify/app/di/register.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/monitoring/crash_reporting_service.dart';
import 'package:ziska_verify/features/history/domain/services/history_search.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';

import '../fakes/fake_logger_service.dart';
import '../fakes/fake_preferences_service.dart';
import '../fakes/scripted_adapter.dart';
import '../flow/harness.dart' show testConfig;

class _Verification extends Mock implements VerificationRepository {}

const _formats = InputFormats(
  serialMaxDigits: 19,
  qr: CodeFormat(length: 12, characters: 'ABC'),
);

/// TC-ARCH-089 … -091 (docs/test-cases/18-architecture.md): one way to make
/// a checked input, crash reporting reached only through the logger, and a
/// serial's limit kept inside History's search (production audit P-50).
void main() {
  setUpAll(() => registerFallbackValue(LookupWay.serial));

  group('TC-ARCH-089 normal: a lookup shows its value as sent', () {
    test('a serial with leading zeros, the way and the time', () async {
      final at = DateTime.utc(2026, 11, 26, 9);
      final repo = _Verification();
      final sent = <String>[];
      when(repo.getFormats).thenAnswer((_) async => const Success(_formats));
      when(() => repo.lookup(any(), any())).thenAnswer((i) async {
        sent.add(i.positionalArguments[1] as String);
        return const Success(
          LookupResult(ref: 'R', outcome: LookupOutcome.valid, reasons: []),
        );
      });
      final bloc = LookupBloc(
        getFormats: GetFormats(repo),
        lookupItem: LookupItem(repo),
        now: () => at,
      )..add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const LookupRequested(LookupWay.serial, '0001000001'));
      await Future<void>.delayed(Duration.zero);

      final checked = bloc.state.checked!;
      expect(checked.shown, sent.single);
      expect(checked.shown, startsWith('000'));
      expect(checked.way, LookupWay.serial);
      expect(checked.at, at);
      await bloc.close();
    });
  });

  group('TC-ARCH-090 edge: the core without crash reporting in it', () {
    test(
      'the logger handed in is registered; crash reporting is not',
      () async {
        await locator.reset();
        addTearDown(locator.reset);
        final logger = FakeLoggerService();
        registerCore(
          config: testConfig,
          logger: logger,
          platform: PlatformServices(preferences: FakePreferencesService()),
          httpAdapter: ScriptedAdapter(
            (_) async => ScriptedAnswer(200, okBody(null)),
          ),
        );
        expect(locator<LoggerService>(), same(logger));
        expect(locator.isRegistered<CrashReportingService>(), isFalse);
      },
    );

    test('History still takes 64 digits and refuses 65', () {
      expect(HistorySearch.read('1' * 64).serial, '1' * 64);
      expect(HistorySearch.read('1' * 65).status, SearchStatus.refused);
    });
  });

  group('TC-ARCH-091 worst: one way each, no more exposed than used', () {
    test('the sources', () {
      String read(String path) => File(path).readAsStringSync();
      final dart = [
        for (final dir in ['lib', 'test'])
          for (final f in Directory(dir).listSync(recursive: true))
            if (f is File &&
                f.path.endsWith('.dart') &&
                !f.path.endsWith('duplicates_exposure_test.dart'))
              f,
      ];
      expect(
        [
          for (final f in dart)
            if (f.readAsStringSync().contains('CheckedInput.of')) f.path,
        ],
        isEmpty,
      );
      expect(
        read('lib/app/di/register.dart'),
        isNot(contains('CrashReportingService')),
      );
      expect(
        read('lib/features/history/domain/services/history_search.dart'),
        isNot(contains('static const maxSerialLength')),
      );
    });
  });
}
