import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/locale/locale_cubit.dart';

import '../../fakes/fake_logger_service.dart';
import '../../fakes/fake_preferences_service.dart';

/// The app language (final.md §16; TC-PROF-019, -023, -030).
void main() {
  late FakePreferencesService preferences;
  late FakeLoggerService logger;

  setUp(() {
    preferences = FakePreferencesService();
    logger = FakeLoggerService();
  });

  group('stored', () {
    test('English when nothing was chosen', () async {
      expect(
        await LocaleCubit.stored(preferences, logger),
        LocaleCubit.english,
      );
    });

    test('the stored choice', () async {
      preferences.language = 'bn';
      expect(
        await LocaleCubit.stored(preferences, logger),
        LocaleCubit.bangla,
      );
    });

    test('English for a language the app does not have', () async {
      preferences.language = 'fr';
      expect(
        await LocaleCubit.stored(preferences, logger),
        LocaleCubit.english,
      );
    });

    test('English when the store cannot be read', () async {
      preferences.failure = Exception('unreadable');
      expect(
        await LocaleCubit.stored(preferences, logger),
        LocaleCubit.english,
      );
    });
  });

  group('choose', () {
    blocTest<LocaleCubit, Locale>(
      'applies and keeps Bangla',
      build: () => LocaleCubit(preferences, logger),
      act: (c) => c.choose(LocaleCubit.bangla),
      expect: () => [LocaleCubit.bangla],
      verify: (_) => expect(preferences.language, 'bn'),
    );

    blocTest<LocaleCubit, Locale>(
      'the current language changes nothing',
      build: () => LocaleCubit(preferences, logger),
      act: (c) => c.choose(LocaleCubit.english),
      expect: () => <Locale>[],
      verify: (_) => expect(preferences.language, isNull),
    );

    blocTest<LocaleCubit, Locale>(
      'a language the app does not have is ignored',
      build: () => LocaleCubit(preferences, logger),
      act: (c) => c.choose(const Locale('fr')),
      expect: () => <Locale>[],
    );

    blocTest<LocaleCubit, Locale>(
      'a failed save still switches for this run',
      build: () {
        preferences.failure = Exception('full');
        return LocaleCubit(preferences, logger);
      },
      act: (c) => c.choose(LocaleCubit.bangla),
      expect: () => [LocaleCubit.bangla],
    );
  });
}
