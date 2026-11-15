import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/retail_users/data/repositories/retail_user_repository_impl.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user_admin.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';
import 'package:ziska_verify/features/retail_users/presentation/bloc/retail_user_admin_cubits.dart';
import 'package:ziska_verify/features/retail_users/presentation/screens/add_retail_user_screen.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

import '../../fakes/postman_examples.dart';
import '../../fakes/scripted_adapter.dart';

class _MockRepo extends Mock implements RetailUserRepository {}

void main() {
  group('contract (app API guide §7, final.md Section 13.6)', () {
    late ScriptedAdapter adapter;
    late RetailUserRepositoryImpl repo;
    late ScriptedAnswer next;

    setUp(() {
      adapter = ScriptedAdapter((_) async => next);
      final dio = Dio(
        DioFactory.options('https://api.example.test/v1/clients/x/'),
      )..httpClientAdapter = adapter;
      repo = RetailUserRepositoryImpl(
        DioRetailUserApiService(ApiClient(dio)),
      );
    });

    ScriptedAnswer example(int status, String request, String name) =>
        ScriptedAnswer(
          status,
          postmanExample(request: request, example: name),
        );

    test('retail roles: the data is the list itself', () async {
      next = example(200, 'Retail roles', '200 The retail roles');
      final roles =
          (await repo.retailRoles() as Success<List<RetailRole>>).value;
      expect(roles.single.id, 7);
      expect(roles.single.name, 'Retail seller');
    });

    test('retail roles: none marked yet', () async {
      next = example(200, 'Retail roles', '200 None marked yet');
      final roles =
          (await repo.retailRoles() as Success<List<RetailRole>>).value;
      expect(roles, isEmpty);
    });

    test('add sends role_id as a number and send_email', () async {
      next = example(201, 'Add a retail user', '201 Added, mail sent');
      final result = await repo.add(
        name: 'Rahim Store',
        email: 'rahim.store@gmail.com',
        roleId: 7,
        password: '1234567890',
        sendEmail: true,
      );
      expect(adapter.requests.single.path, 'retail-users');
      expect(adapter.requests.single.data, {
        'name': 'Rahim Store',
        'email': 'rahim.store@gmail.com',
        'role_id': 7,
        'password': '1234567890',
        'send_email': true,
      });
      expect(
        (result as Success<AddedRetailUser>).value.emailOutcome,
        EmailOutcome.sent,
      );
    });

    test('email_sent false: the account exists, the mail failed', () async {
      next = example(
        201,
        'Add a retail user',
        '201 Added, but the mail failed',
      );
      final result = await repo.add(
        name: 'R',
        email: 'r@x.co',
        roleId: 7,
        password: 'p',
        sendEmail: true,
      );
      expect(
        (result as Success<AddedRetailUser>).value.emailOutcome,
        EmailOutcome.failed,
      );
    });

    test('email_sent null: not sent, as asked', () async {
      next = ScriptedAnswer(
        201,
        okBody({
          'id': '9d2e',
          'name': 'R',
          'email': 'r@x.co',
          'email_sent': null,
        }),
      );
      final result = await repo.add(
        name: 'R',
        email: 'r@x.co',
        roleId: 7,
        password: 'p',
        sendEmail: false,
      );
      expect(
        (adapter.requests.single.data as Map<String, Object?>)['send_email'],
        isFalse,
      );
      expect(
        (result as Success<AddedRetailUser>).value.emailOutcome,
        EmailOutcome.notRequested,
      );
    });

    test('409: the email is already used', () async {
      next = example(
        409,
        'Add a retail user',
        '409 An official with this email already exists.',
      );
      final result = await repo.add(
        name: 'R',
        email: 'r@x.co',
        roleId: 7,
        password: 'p',
        sendEmail: true,
      );
      expect(
        (result as Err<AddedRetailUser>).failure.exception,
        isA<ConflictException>(),
      );
    });

    test('email a new first password: no body', () async {
      next = example(200, 'Email a new first password', '200 Emailed');
      final result = await repo.emailNewFirstPassword('9d2e-1');
      expect(result, isA<Success<void>>());
      expect(adapter.requests.single.path, 'retail-users/9d2e-1/password');
      expect(adapter.requests.single.data, isNull);
    });
  });

  group('AddRetailUserCubit', () {
    late _MockRepo repo;

    setUp(() {
      repo = _MockRepo();
      when(repo.retailRoles).thenAnswer(
        (_) async => const Success([RetailRole(id: 7, name: 'Retail seller')]),
      );
    });

    AddRetailUserCubit build() => AddRetailUserCubit(
      getRoles: GetRetailRoles(repo),
      addRetailUser: AddRetailUser(repo),
    );

    void answer(EmailOutcome outcome) =>
        when(
          () => repo.add(
            name: any(named: 'name'),
            email: any(named: 'email'),
            roleId: any(named: 'roleId'),
            password: any(named: 'password'),
            sendEmail: any(named: 'sendEmail'),
          ),
        ).thenAnswer(
          (_) async => Success(
            AddedRetailUser(
              id: '1',
              name: 'R',
              email: 'r@x.co',
              emailOutcome: outcome,
            ),
          ),
        );

    Future<AddRetailUserState> submit(
      AddRetailUserCubit cubit, {
      required bool sendEmail,
    }) async {
      await cubit.loadRoles();
      await cubit.submit(
        name: ' R ',
        email: ' r@x.co ',
        roleId: 7,
        password: 'first-pass',
        sendEmail: sendEmail,
      );
      return cubit.state;
    }

    test('sent by email: the password is not shown again', () async {
      answer(EmailOutcome.sent);
      final state = await submit(build(), sendEmail: true);
      expect(state.status, AddStatus.done);
      expect(state.passwordToShow, isNull);
      verify(
        () => repo.add(
          name: 'R',
          email: 'r@x.co',
          roleId: 7,
          password: 'first-pass',
          sendEmail: true,
        ),
      ).called(1);
    });

    test('not emailed: the typed password is shown once more', () async {
      answer(EmailOutcome.notRequested);
      final state = await submit(build(), sendEmail: false);
      expect(state.passwordToShow, 'first-pass');
    });

    test('mail failed: the typed password is shown once more', () async {
      answer(EmailOutcome.failed);
      final state = await submit(build(), sendEmail: true);
      expect(state.passwordToShow, 'first-pass');
    });

    test('add another forgets the password', () async {
      answer(EmailOutcome.notRequested);
      final cubit = build();
      await submit(cubit, sendEmail: false);
      cubit.addAnother();
      expect(cubit.state.passwordToShow, isNull);
      expect(cubit.state.status, AddStatus.editing);
    });
  });

  group('AddRetailUserScreen', () {
    Future<void> pump(WidgetTester tester, AddRetailUserCubit cubit) =>
        tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider.value(
              value: cubit,
              child: const AddRetailUserScreen(),
            ),
          ),
        );

    testWidgets('"Email the login details" is on by default; off says to '
        'give the password yourself', (tester) async {
      final repo = _MockRepo();
      when(repo.retailRoles).thenAnswer(
        (_) async => const Success([RetailRole(id: 7, name: 'Retail seller')]),
      );
      final cubit = AddRetailUserCubit(
        getRoles: GetRetailRoles(repo),
        addRetailUser: AddRetailUser(repo),
      );
      addTearDown(cubit.close);
      await cubit.loadRoles();
      await pump(tester, cubit);
      await tester.pumpAndSettle();

      final toggle = find.byKey(const Key('addRetail.sendEmail'));
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(
        find.text('Give the password to the retail user yourself.'),
        findsNothing,
      );

      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(
        find.text('Give the password to the retail user yourself.'),
        findsOneWidget,
      );
    });

    testWidgets('no retail role yet: nothing can be added', (tester) async {
      final repo = _MockRepo();
      when(repo.retailRoles).thenAnswer((_) async => const Success([]));
      final cubit = AddRetailUserCubit(
        getRoles: GetRetailRoles(repo),
        addRetailUser: AddRetailUser(repo),
      );
      addTearDown(cubit.close);
      await cubit.loadRoles();
      await pump(tester, cubit);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('addRetail.submit')), findsNothing);
      expect(
        find.textContaining('no retail user can be added'),
        findsOneWidget,
      );
    });
  });
}
