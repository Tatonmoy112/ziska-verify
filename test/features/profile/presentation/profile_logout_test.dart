import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/profile/presentation/screens/profile_screen.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

const _loaded = ProfileState(
  status: ProfileStatus.loaded,
  profile: Profile(
    id: '1',
    name: 'Asha Rao',
    email: 'a@b.c',
    role: 'Inspector',
    permissions: {Permission.lookup},
    mustChangePassword: false,
  ),
);

Finder _inDialog(String text) => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.text(text),
);

/// TC-SESS-046 … -048 (docs/test-cases/02-session.md): Profile's logout
/// dialog, including a Profile that is gone when the dialog answers
/// (production audit P-20).
void main() {
  late _MockProfileCubit cubit;
  late int logouts;
  late ValueNotifier<bool> shown;

  setUp(() {
    cubit = _MockProfileCubit();
    when(() => cubit.state).thenReturn(_loaded);
    logouts = 0;
    shown = ValueNotifier(true);
  });
  tearDown(() => shown.dispose());

  /// Profile, which [shown] can take away while a dialog stays open, as
  /// the router does when the login ends.
  Future<void> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (context, isShown, _) => isShown
                ? ProfileScreen(
                    versionInfo: Future.value((version: '1.0.0', build: '1')),
                    onChooseLanguage: (_) async {},
                    onChangePassword: () {},
                    onContactSupport: ({email, phone}) async => true,
                    onLogout: () async => logouts++,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('profile.logout')));
    await tester.tap(find.byKey(const Key('profile.logout')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  testWidgets('TC-SESS-046 normal: confirmed, the logout runs once', (
    tester,
  ) async {
    await pump(tester);
    await openDialog(tester);
    await tester.tap(_inDialog('Log out'));
    await tester.pumpAndSettle();
    expect(logouts, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('TC-SESS-047 edge: cancelled or dismissed, nothing happens', (
    tester,
  ) async {
    await pump(tester);
    await openDialog(tester);
    await tester.tap(_inDialog('Cancel'));
    await tester.pumpAndSettle();
    await openDialog(tester);
    await tester.tapAt(const Offset(8, 8)); // outside the dialog
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(logouts, 0);
    expect(find.byKey(const Key('profile.logout')), findsOneWidget);
  });

  testWidgets(
    'TC-SESS-048 worst: Profile gone while the dialog is open, no error',
    (tester) async {
      await pump(tester);
      await openDialog(tester);
      // The login ends: the router takes Profile away; the dialog stays.
      shown.value = false;
      await tester.pump();
      expect(find.byType(ProfileScreen), findsNothing);
      await tester.tap(_inDialog('Log out'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(logouts, 0, reason: 'the login is already over');
    },
  );
}
