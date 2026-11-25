import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';
import 'package:ziska_verify/features/history/domain/services/history_search.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_read_filter.dart';

class _Incidents extends Mock implements IncidentRepository {}

class _Photos implements PhotoService {
  @override
  Future<PreparedPhoto?> pick(PhotoSource source) async =>
      PreparedPhoto(Uint8List(10));
}

const ({String name, String email, String password, int roleId}) _ok = (
  name: 'Rahim Store',
  email: 'person@example.com',
  password: 'abcd1234',
  roleId: 7,
);

/// TC-ARCH-056 … -058 (docs/test-cases/18-architecture.md): the rules the
/// screens used to decide themselves, each in one place a test can reach
/// (production audit P-38).
void main() {
  final start = DateTime.utc(2026, 11, 25, 9);

  group('TC-ARCH-056 normal: each rule where it can be tested', () {
    test('a new QR is taken; the same one, held back', () {
      withClock(Clock.fixed(start), () {
        final reads = QrReadFilter(window: const Duration(seconds: 3));
        expect(reads.accept('Q1'), isTrue);
        expect(reads.accept('Q1'), isFalse);
        expect(reads.accept('Q2'), isTrue);
        reads.forget();
        expect(reads.accept('Q2'), isTrue, reason: 'Scan again');
      });
    });

    test('the scanner session: the same QR until another one', () {
      final reads = QrReadFilter();
      expect(reads.isRepeat('Q1'), isFalse);
      reads.take('Q1');
      expect(reads.isRepeat('Q1'), isTrue);
      reads.take('Q2');
      expect(reads.isRepeat('Q1'), isFalse);
    });

    test('History tracks the serial the domain reads', () {
      expect(HistorySearch.read('1000001').serial, '1000001');
      expect(HistorySearch.read('MA-2026-000123').serial, isNull);
      expect(HistorySearch.read('').serial, isNull);
    });

    test('a Request access form is ready by the use case rule', () {
      expect(
        SubmitAccessRequest.formReady(
          name: _ok.name,
          email: _ok.email,
          password: _ok.password,
          roleId: _ok.roleId,
        ),
        isTrue,
      );
    });
  });

  group('TC-ARCH-057 edge: the limits', () {
    test('the same QR at 2.9 s and at 3.1 s; 5 s after its result', () {
      var now = start;
      withClock(Clock(() => now), () {
        final reads = QrReadFilter(
          window: const Duration(seconds: 3),
          afterResult: const Duration(seconds: 5),
        );
        expect(reads.accept('Q1'), isTrue);
        now = start.add(const Duration(milliseconds: 2900));
        expect(reads.accept('Q1'), isFalse);
        now = start.add(const Duration(milliseconds: 3100));
        expect(reads.accept('Q1'), isTrue);
        reads.resultClosed();
        now = now.add(const Duration(seconds: 4));
        expect(reads.accept('Q1'), isFalse, reason: 'after its result');
        now = now.add(const Duration(seconds: 2));
        expect(reads.accept('Q1'), isTrue);
      });
    });

    test('a serial of 64 digits, of Bangla digits; not 65', () {
      expect(HistorySearch.read('1' * 64).serial, '1' * 64);
      expect(HistorySearch.read('১০০০০০১').serial, '1000001');
      expect(HistorySearch.read('1' * 65).serial, isNull);
    });

    test('a name of 100 characters, not 101; no role', () {
      bool ready({String name = 'n', int? roleId = 7}) =>
          SubmitAccessRequest.formReady(
            name: name,
            email: _ok.email,
            password: _ok.password,
            roleId: roleId,
          );
      expect(ready(name: 'n' * 100), isTrue);
      expect(ready(name: 'n' * 101), isFalse);
      expect(ready(name: '   '), isFalse);
      expect(ready(roleId: null), isFalse);
    });
  });

  group('TC-ARCH-058 worst: what the screen shows follows the state', () {
    testWidgets('the photo hour ends while the page is open', (tester) async {
      final repo = _Incidents();
      when(
        () => repo.fileReport(
          note: any(named: 'note'),
          checkRef: any(named: 'checkRef'),
          retailUserId: any(named: 'retailUserId'),
        ),
      ).thenAnswer((_) async => const Success(1042));
      var now = start;
      final bloc = ReportIncidentBloc(
        fileReport: FileReport(repo),
        addPhoto: AddReportPhoto(repo),
        photos: _Photos(),
        now: () => now,
      )..add(const ReportSubmitted('Seal is cut'));
      await tester.pump();
      expect(bloc.state.isFiled, isTrue);
      expect(bloc.state.canAddPhoto, isTrue);
      expect(bloc.state.photoHourOver, isFalse);

      // No tap: the hour runs out by itself.
      now = start.add(const Duration(hours: 1));
      await tester.pump(const Duration(hours: 1));
      expect(bloc.state.photoHourOver, isTrue);
      expect(bloc.state.canAddPhoto, isFalse);
      // In a widget test, time moves only when pumped: the close is started,
      // not waited for (the hour's timer has fired, none is left).
      unawaited(bloc.close());
      await tester.pump();
    });

    test('no screen decides these rules itself', () {
      String read(String path) => File(path).readAsStringSync();
      const p = 'lib/features';
      expect(
        read('$p/verification/presentation/screens/verify_screen.dart'),
        isNot(matches(RegExp('_lastRaw|_lastAt|_backFromResult'))),
      );
      expect(
        read('$p/verification/presentation/bloc/scan_session_cubit.dart'),
        isNot(contains('_lastRaw')),
      );
      expect(
        read('$p/history/presentation/screens/history_screen.dart'),
        isNot(contains('RegExp(')),
      );
      expect(
        read('$p/verification/presentation/screens/serial_stack_screen.dart'),
        isNot(contains('ParseStack')),
      );
      final access = read(
        '$p/authentication/presentation/screens/request_access_screen.dart',
      );
      // The password's hints are shown as it is typed (display); whether
      // the form can be sent is the use case's.
      expect(access, contains('SubmitAccessRequest.formReady('));
      expect(access, isNot(contains('looksLikeEmail')));
      final report = read(
        '$p/incidents/presentation/screens/report_incident_screen.dart',
      );
      expect(report, isNot(contains('bloc.canAddPhoto')));
      expect(report, isNot(contains('bloc.photoHourOver')));
    });
  });
}
