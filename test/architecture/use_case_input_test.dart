import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';

class _Auth extends Mock implements AuthRepository {}

class _Incidents extends Mock implements IncidentRepository {}

const _email = 'person@example.com';
const _password = 'abcd1234';

/// TC-ARCH-044 … -046 (docs/test-cases/18-architecture.md): a use case
/// validates its input before the repository; a screen may check first
/// only to say so (production audit P-33).
void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));

  late _Auth auth;
  late _Incidents incidents;
  setUp(() {
    auth = _Auth();
    incidents = _Incidents();
    when(
      () => auth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Success(CodeSent('c')));
    when(
      () => auth.verifyCode(any()),
    ).thenAnswer(
      (_) async => const Success(LoggedIn(mustChangePassword: false)),
    );
    when(
      () => auth.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => auth.requestPasswordReset(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => auth.resetPassword(
        email: any(named: 'email'),
        code: any(named: 'code'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => incidents.fileReport(
        note: any(named: 'note'),
        checkRef: any(named: 'checkRef'),
        retailUserId: any(named: 'retailUserId'),
      ),
    ).thenAnswer((_) async => const Success(1));
    when(
      () => incidents.addPhoto(
        any(),
        any(),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => const Success(1));
  });

  group('TC-ARCH-044 normal: valid input reaches the repository once', () {
    test('login, code, password change, reset', () async {
      await Login(auth)(email: ' $_email ', password: _password);
      verify(() => auth.login(email: _email, password: _password)).called(1);
      await VerifyCode(auth)(' 123456 ');
      verify(() => auth.verifyCode('123456')).called(1);
      await ChangePassword(auth)(oldPassword: 'old', newPassword: _password);
      verify(
        () => auth.changePassword(oldPassword: 'old', newPassword: _password),
      ).called(1);
      await RequestPasswordReset(auth)(_email);
      verify(() => auth.requestPasswordReset(_email)).called(1);
      await ResetPassword(auth)(
        email: _email,
        code: '123456',
        newPassword: _password,
      );
      verify(
        () => auth.resetPassword(
          email: _email,
          code: '123456',
          newPassword: _password,
        ),
      ).called(1);
    });

    test('a report and a photo', () async {
      await FileReport(incidents)(note: '  Seal is cut  ', checkRef: 'MA-1');
      verify(
        () => incidents.fileReport(note: 'Seal is cut', checkRef: 'MA-1'),
      ).called(1);
      final photo = Uint8List(10);
      await AddReportPhoto(incidents)(1042, photo, contentType: 'image/jpeg');
      verify(
        () => incidents.addPhoto(1042, photo, contentType: 'image/jpeg'),
      ).called(1);
    });
  });

  group('TC-ARCH-045 edge: input exactly at a limit is taken', () {
    test('a note of 1,000 characters, emoji counted as one', () async {
      final note = '🙂${'n' * 999}'; // 1,000 code points, 1,001 units
      expect(
        await FileReport(incidents)(note: ' $note\n'),
        isA<Success<int>>(),
      );
      verify(() => incidents.fileReport(note: note)).called(1);
    });

    test('the code in Bangla digits', () async {
      await VerifyCode(auth)('১২৩৪৫৬');
      verify(() => auth.verifyCode('123456')).called(1);
    });

    test('a photo of exactly 1 MB, and a PNG', () async {
      final mb = Uint8List(PreparedPhoto.maxBytes);
      expect(
        await AddReportPhoto(incidents)(1, mb, contentType: 'image/jpeg'),
        isA<Success<int>>(),
      );
      expect(
        await AddReportPhoto(incidents)(1, mb, contentType: 'image/png'),
        isA<Success<int>>(),
      );
    });

    test('the photo hour: in it at 59:59, over at 1:00:00', () {
      final filed = DateTime.utc(2026, 11, 25, 9);
      expect(
        ReportRules.withinPhotoWindow(
          filed,
          filed.add(const Duration(minutes: 59, seconds: 59)),
        ),
        isTrue,
      );
      expect(
        ReportRules.withinPhotoWindow(
          filed,
          filed.add(ReportRules.photoWindow),
        ),
        isFalse,
      );
      expect(ReportRules.withinPhotoWindow(null, filed), isTrue);
    });
  });

  group('TC-ARCH-046 worst: invalid input never reaches the repository', () {
    Future<void> refused(Future<Result<Object?>> Function() call) async {
      final result = await call();
      expect(result, isA<Err<Object?>>());
      expect(
        (result as Err).failure.exception,
        isA<ValidationException>(),
      );
    }

    test('login', () async {
      for (final email in ['', 'person', '@example.com', 'a@', 'a b@c.d']) {
        await refused(() => Login(auth)(email: email, password: _password));
      }
      await refused(() => Login(auth)(email: _email, password: ''));
      verifyNever(
        () => auth.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('the code', () async {
      for (final code in ['', '12345', '1234567', '12a456', '12 456']) {
        await refused(() => VerifyCode(auth)(code));
      }
      verifyNever(() => auth.verifyCode(any()));
    });

    test('the passwords', () async {
      await refused(
        () => ChangePassword(auth)(oldPassword: '', newPassword: _password),
      );
      for (final weak in ['short1', 'abcdefgh', '12345678']) {
        await refused(
          () => ChangePassword(auth)(oldPassword: 'old', newPassword: weak),
        );
        await refused(
          () => ResetPassword(auth)(
            email: _email,
            code: '123456',
            newPassword: weak,
          ),
        );
      }
      await refused(() => RequestPasswordReset(auth)('nobody'));
      await refused(
        () => ResetPassword(auth)(
          email: _email,
          code: '12345',
          newPassword: _password,
        ),
      );
      verifyNever(
        () => auth.changePassword(
          oldPassword: any(named: 'oldPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
      verifyNever(() => auth.requestPasswordReset(any()));
      verifyNever(
        () => auth.resetPassword(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('a report and a photo', () async {
      for (final note in [
        '',
        '   ',
        '\n',
        'n' * (ReportRules.noteMaxLength + 1),
      ]) {
        await refused(() => FileReport(incidents)(note: note));
      }
      verifyNever(
        () => incidents.fileReport(
          note: any(named: 'note'),
          checkRef: any(named: 'checkRef'),
          retailUserId: any(named: 'retailUserId'),
        ),
      );
      for (final (id, bytes, type) in [
        (1, Uint8List(0), 'image/jpeg'),
        (1, Uint8List(PreparedPhoto.maxBytes + 1), 'image/jpeg'),
        (1, Uint8List(10), 'image/gif'),
        (0, Uint8List(10), 'image/jpeg'),
      ]) {
        await refused(
          () => AddReportPhoto(incidents)(id, bytes, contentType: type),
        );
      }
      verifyNever(
        () => incidents.addPhoto(
          any(),
          any(),
          contentType: any(named: 'contentType'),
        ),
      );
    });
  });
}
