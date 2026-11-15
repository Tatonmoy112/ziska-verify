import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/splash_screen.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

const _loading = ProfileState(status: ProfileStatus.loading);
const _failed = ProfileState(
  status: ProfileStatus.failure,
  failure: Failure(
    InternalErrorException(statusCode: 500, requestId: 'req-42'),
  ),
);

const _logo = Key('splash.logo');
const _progress = Key('splash.progress');
const _error = Key('splash.error');
const _retry = Key('splash.retry');

void main() {
  late _MockProfileCubit cubit;

  setUp(() {
    cubit = _MockProfileCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    ProfileState state, {
    Size size = const Size(412, 915),
    double textScale = 1,
  }) async {
    when(() => cubit.state).thenReturn(state);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: const SplashScreen(),
        ),
      ),
    );
    // The progress indicator never settles, so pump a single frame.
    await tester.pump();
  }

  void expectCentred(WidgetTester tester, Key key) =>
      expectFinderCentred(tester, find.byKey(key));

  group('alignment', () {
    testWidgets('TC-UI-001 loading: logo, title and progress are centred', (
      tester,
    ) async {
      await pump(tester, _loading);

      expectCentred(tester, _logo);
      expectFinderCentred(tester, find.text('Track & Trace'));
      expectCentred(tester, _progress);
      expect(find.byKey(_retry), findsNothing);
    });

    testWidgets('TC-UI-002 failure: same centring, with the message, '
        'reference and retry', (tester) async {
      await pump(tester, _failed);

      expectCentred(tester, _logo);
      expectCentred(tester, _error);
      expectCentred(tester, _retry);
      expect(find.text('Reference: req-42'), findsOneWidget);
      expect(find.byKey(_progress), findsNothing);
    });

    testWidgets('TC-UI-003 the logo stays in the same place in both states', (
      tester,
    ) async {
      await pump(tester, _loading);
      final loadingX = tester.getCenter(find.byKey(_logo)).dx;
      await pump(tester, _failed);
      expect(tester.getCenter(find.byKey(_logo)).dx, loadingX);
    });
  });

  group('no overflow', () {
    const cases = <String, (Size, double)>{
      'small phone': (Size(320, 480), 1),
      'landscape phone': (Size(915, 412), 1),
      'largest font size': (Size(412, 915), 2),
      'small phone, largest font size': (Size(320, 568), 2),
    };

    for (final MapEntry(key: name, value: (size, scale)) in cases.entries) {
      for (final (label, state) in [
        ('loading', _loading),
        ('failure', _failed),
      ]) {
        testWidgets('TC-UI-004 $name, $label', (tester) async {
          await pump(tester, state, size: size, textScale: scale);
          expect(tester.takeException(), isNull);
          expectCentred(tester, _logo);
        });
      }
    }

    testWidgets('TC-UI-005 retry stays reachable by scrolling when the '
        'content does not fit', (tester) async {
      await pump(tester, _failed, size: const Size(320, 480), textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(_retry));
      await tester.pump();
      await tester.tap(find.byKey(_retry));
      verify(() => cubit.load()).called(1);
    });
  });

  testWidgets('TC-UI-006 tablet: content is no wider than maxContentWidth', (
    tester,
  ) async {
    await pump(tester, _failed, size: const Size(1280, 800));

    expect(
      tester.getSize(find.byKey(_retry)).width,
      lessThanOrEqualTo(SplashScreen.maxContentWidth),
    );
    expectCentred(tester, _retry);
  });

  testWidgets('TC-UI-005 retry reloads the profile', (tester) async {
    await pump(tester, _failed);
    await tester.tap(find.byKey(_retry));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('TC-UI-007 progress is announced to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, _loading);
    expect(find.bySemanticsLabel('Loading your profile…'), findsOneWidget);
    handle.dispose();
  });
}

void expectFinderCentred(WidgetTester tester, Finder finder) {
  final screenCentre = tester.view.physicalSize.width / 2;
  expect(
    tester.getCenter(finder).dx,
    moreOrLessEquals(screenCentre, epsilon: 0.5),
    reason: '$finder should be centred horizontally',
  );
}
