import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:ziska_verify/features/authentication/presentation/screens/login_screen.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => LoginBloc(Login(repo)),
          child: const LoginScreen(),
        ),
      ),
    );
  }

  Future<void> submit(WidgetTester tester, String email) async {
    await tester.enterText(find.byKey(const Key('login.email')), email);
    await tester.enterText(find.byKey(const Key('login.password')), 'secret');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
  }

  // TC-AUTH-011: Same message for wrong password and unknown email.
  // TC-ERR-002: Reference on every error.
  testWidgets('a wrong password and an unknown email show the same message '
      'with the reference', (tester) async {
    when(
      () => repo.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Err<LoginOutcome>(
        Failure(UnauthenticatedException(statusCode: 401, requestId: 'r-9')),
      ),
    );
    await pump(tester);

    await submit(tester, 'known@example.com');
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.text('Reference: r-9'), findsOneWidget);

    await submit(tester, 'unknown@example.com');
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });

  // TC-AUTH-001: Email is checked before sending.
  testWidgets('nothing is sent without a valid email', (tester) async {
    await pump(tester);
    await submit(tester, 'not-an-email');
    expect(find.text('Enter a valid email address'), findsOneWidget);
    verifyNever(
      () => repo.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });
}
