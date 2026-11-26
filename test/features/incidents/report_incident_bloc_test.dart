import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/incidents/domain/repositories/incident_repository.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';

class _MockRepo extends Mock implements IncidentRepository {}

/// Hands out photos 1, 2, 3, … as prepared JPEG bytes.
class _FakePhotos implements PhotoService {
  int _n = 0;

  @override
  Future<PreparedPhoto?> pick(PhotoSource source) async =>
      PreparedPhoto(Uint8List.fromList([++_n]));
}

void main() {
  late _MockRepo repo;
  late DateTime now;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repo = _MockRepo();
    now = DateTime(2026, 11, 10, 12);
    when(
      () => repo.fileReport(
        note: any(named: 'note'),
        checkRef: any(named: 'checkRef'),
        retailUserId: any(named: 'retailUserId'),
      ),
    ).thenAnswer((_) async => const Success(1042));
  });

  ReportIncidentBloc build({String? checkRef}) => ReportIncidentBloc(
    fileReport: FileReport(repo),
    addPhoto: AddReportPhoto(repo),
    photos: _FakePhotos(),
    checkRef: checkRef,
    now: () => now,
  );

  void photoAnswers(List<Result<int>> answers) {
    final queue = [...answers];
    when(
      () => repo.addPhoto(any(), any(), contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => queue.removeAt(0));
  }

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 5));

  // TC-REP-001: Report from a result carries the reference.
  // TC-REP-004: Filed once.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'a report from a lookup result carries its ref as check_ref, and is '
    'filed once',
    build: () => build(checkRef: 'MA-2026-000123'),
    act: (bloc) async {
      bloc
        ..add(const ReportSubmitted('Seal is cut'))
        ..add(const ReportSubmitted('Seal is cut'));
      await settle();
    },
    verify: (bloc) {
      verify(
        () => repo.fileReport(
          note: 'Seal is cut',
          checkRef: 'MA-2026-000123',
        ),
      ).called(1);
      expect(bloc.state.reportId, 1042);
      expect(bloc.state.isFiled, isTrue);
    },
  );

  // Audit H2 (build guide step 7, FR-INC-05): a lost answer may mean the
  // report was filed; filing again could make a second report.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'TC-REP-050 a lost connection while filing never allows filing again',
    setUp: () => when(
      () => repo.fileReport(
        note: any(named: 'note'),
        checkRef: any(named: 'checkRef'),
        retailUserId: any(named: 'retailUserId'),
      ),
    ).thenAnswer((_) async => const Err(Failure(NetworkException()))),
    build: build,
    act: (bloc) async {
      bloc.add(const ReportSubmitted('Torn seal'));
      await settle();
      bloc.add(const ReportSubmitted('Torn seal'));
      await settle();
    },
    verify: (bloc) {
      expect(bloc.state.filing, FilingStatus.unconfirmed);
      expect(bloc.state.canEdit, isFalse);
      verify(
        () => repo.fileReport(
          note: any(named: 'note'),
          checkRef: any(named: 'checkRef'),
          retailUserId: any(named: 'retailUserId'),
        ),
      ).called(1);
    },
  );

  // TC-REP-005: Photos sent one at a time after filing.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'photos are sent one at a time after the report, in order',
    setUp: () => photoAnswers([const Success(1), const Success(2)]),
    build: build,
    act: (bloc) async {
      bloc
        ..add(const PhotoPickRequested(PhotoSource.gallery))
        ..add(const PhotoPickRequested(PhotoSource.gallery));
      await settle();
      bloc.add(const ReportSubmitted('Torn seal'));
      await settle();
    },
    verify: (bloc) {
      final sent = verify(
        () => repo.addPhoto(
          1042,
          captureAny(),
          contentType: 'image/jpeg',
        ),
      ).captured;
      expect(sent.map((b) => (b as Uint8List).single), [1, 2]);
      expect(bloc.state.photos.map((p) => p.number), [1, 2]);
    },
  );

  // TC-REP-006: Lost photo sent again, report not filed again.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'a photo lost on 503 is kept and sent again; the report is not filed '
    'again',
    setUp: () => photoAnswers([
      const Err(Failure(ServiceUnavailableException())),
      const Success(1),
    ]),
    build: build,
    act: (bloc) async {
      bloc.add(const PhotoPickRequested(PhotoSource.camera));
      await settle();
      bloc.add(const ReportSubmitted('Fake label'));
      await settle();
      expect(bloc.state.photos.single.canRetry, isTrue);
      bloc.add(PhotoRetried(bloc.state.photos.single.localId));
      await settle();
    },
    verify: (bloc) {
      expect(bloc.state.photos.single.status, PhotoStatus.sent);
      final sent = verify(
        () => repo.addPhoto(1042, captureAny(), contentType: 'image/jpeg'),
      ).captured;
      // The same file both times.
      expect(sent.map((b) => (b as Uint8List).single), [1, 1]);
      verify(
        () => repo.fileReport(
          note: any(named: 'note'),
          checkRef: any(named: 'checkRef'),
          retailUserId: any(named: 'retailUserId'),
        ),
      ).called(1);
    },
  );

  // TC-REP-007: Refused photo not offered again.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'a refused photo (400) is not offered again',
    setUp: () => photoAnswers([const Err(Failure(ValidationException()))]),
    build: build,
    act: (bloc) async {
      bloc.add(const PhotoPickRequested(PhotoSource.camera));
      await settle();
      bloc.add(const ReportSubmitted('Note'));
      await settle();
    },
    verify: (bloc) {
      expect(bloc.state.photos.single.status, PhotoStatus.failed);
      expect(bloc.state.photos.single.canRetry, isFalse);
    },
  );

  // TC-REP-008: At most 3 photos.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'at most 3 photos',
    build: build,
    act: (bloc) async {
      for (var i = 0; i < 4; i++) {
        bloc.add(const PhotoPickRequested(PhotoSource.gallery));
        await settle();
      }
    },
    verify: (bloc) => expect(bloc.state.photos, hasLength(3)),
  );

  // TC-REP-009: Nothing after one hour.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'nothing is sent again after the hour',
    setUp: () => photoAnswers([const Err(Failure(NetworkException()))]),
    build: build,
    act: (bloc) async {
      bloc.add(const PhotoPickRequested(PhotoSource.camera));
      await settle();
      bloc.add(const ReportSubmitted('Note'));
      await settle();
      now = now.add(const Duration(hours: 1, minutes: 1));
      bloc
        ..add(PhotoRetried(bloc.state.photos.single.localId))
        ..add(const PhotoPickRequested(PhotoSource.camera));
      await settle();
    },
    verify: (bloc) {
      expect(bloc.state.photos, hasLength(1));
      expect(bloc.state.photos.single.status, PhotoStatus.failed);
      verify(
        () =>
            repo.addPhoto(any(), any(), contentType: any(named: 'contentType')),
      ).called(1);
    },
  );

  // TC-REP-002: Note is required.
  blocTest<ReportIncidentBloc, ReportIncidentState>(
    'an empty note is not sent',
    build: build,
    act: (bloc) => bloc.add(const ReportSubmitted('   ')),
    verify: (_) => verifyNever(
      () => repo.fileReport(
        note: any(named: 'note'),
        checkRef: any(named: 'checkRef'),
        retailUserId: any(named: 'retailUserId'),
      ),
    ),
  );

  // What is gone is decided in the repository (TC-REP-075 … -077, P-25);
  // here, what the bloc does with it.
  group('TC-REP-058 a 404 on filing names what is gone', () {
    void answer404(IncidentReason? reason) =>
        when(
          () => repo.fileReport(
            note: any(named: 'note'),
            checkRef: any(named: 'checkRef'),
            retailUserId: any(named: 'retailUserId'),
          ),
        ).thenAnswer(
          (_) async => Err(Failure(NotFoundException(reason: reason))),
        );

    for (final (reason, check, retail, missing) in [
      (IncidentReason.checkGone, true, true, MissingLink.check),
      (IncidentReason.retailUserGone, true, true, MissingLink.retailUser),
      (IncidentReason.checkGone, true, false, MissingLink.check),
      (IncidentReason.retailUserGone, false, true, MissingLink.retailUser),
      (null, false, false, MissingLink.route),
      (null, true, true, MissingLink.route),
    ]) {
      test(
        '$reason, check $check, retail user $retail → $missing',
        () async {
          answer404(reason);
          final bloc = build(checkRef: check ? 'MA-2026-000123' : null);
          if (retail) {
            bloc.add(const RetailUserChosen((id: 'r1', name: 'Shop')));
          }
          bloc.add(const ReportSubmitted('Seal is cut'));
          await settle();
          expect(bloc.state.filing, FilingStatus.failed);
          expect(bloc.state.missing, missing);
          // A retail user that is gone is taken off; anything else stays.
          expect(
            bloc.state.retailUser,
            retail && missing != MissingLink.retailUser ? isNotNull : isNull,
          );
          expect(bloc.state.checkRef, check ? 'MA-2026-000123' : isNull);
          await bloc.close();
        },
      );
    }
  });
}
