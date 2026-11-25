import 'dart:typed_data';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/domain/usecases/incident_usecases.dart';

sealed class ReportIncidentEvent {
  const ReportIncidentEvent();
}

/// One of the official's own checks, picked for the report (SRS UC-08).
final class CheckRefChosen extends ReportIncidentEvent {
  const CheckRefChosen(this.ref);
  final String ref;
}

final class CheckRefCleared extends ReportIncidentEvent {
  const CheckRefCleared();
}

final class RetailUserChosen extends ReportIncidentEvent {
  const RetailUserChosen(this.user);

  /// `null` clears the choice.
  final ({String id, String name})? user;
}

final class PhotoPickRequested extends ReportIncidentEvent {
  const PhotoPickRequested(this.source);
  final PhotoSource source;
}

final class PhotoRemoved extends ReportIncidentEvent {
  const PhotoRemoved(this.localId);
  final int localId;
}

/// Files the report once, then sends the photos.
final class ReportSubmitted extends ReportIncidentEvent {
  const ReportSubmitted(this.note);
  final String note;
}

/// Sends a failed photo again; safe, it is never counted twice.
final class PhotoRetried extends ReportIncidentEvent {
  const PhotoRetried(this.localId);
  final int localId;
}

final class _UploadRequested extends ReportIncidentEvent {
  const _UploadRequested();
}

enum PhotoStatus { waiting, sending, sent, failed }

class ReportPhoto {
  const ReportPhoto({
    required this.localId,
    required this.photo,
    this.status = PhotoStatus.waiting,
    this.number,
    this.failure,
    this.retryAt,
  });

  final int localId;
  final PreparedPhoto photo;
  final PhotoStatus status;

  /// The photo's number on the report (`n`), once sent.
  final int? number;
  final Failure? failure;

  /// After a `429`: not sent again before this time (guide section 1).
  final DateTime? retryAt;

  Uint8List get bytes => photo.bytes;

  /// A lost connection or a busy service: the same file may be sent again
  /// (final.md §13.5). Refused photos are not retried.
  bool get canRetry =>
      status == PhotoStatus.failed &&
      switch (failure?.exception) {
        NetworkException() ||
        ServiceUnavailableException() ||
        RateLimitedException() ||
        InternalErrorException() => true,
        _ => false,
      };

  ReportPhoto copyWith({
    PhotoStatus? status,
    int? number,
    Failure? Function()? failure,
    DateTime? Function()? retryAt,
  }) => ReportPhoto(
    localId: localId,
    photo: photo,
    status: status ?? this.status,
    number: number ?? this.number,
    retryAt: retryAt == null ? this.retryAt : retryAt(),
    failure: failure == null ? this.failure : failure(),
  );
}

/// [unconfirmed]: the connection dropped while filing, so the report may
/// have been filed; it is never filed again from this screen (build guide
/// step 7, SRS FR-INC-05).
enum FilingStatus { editing, filing, filed, failed, unconfirmed }

/// What a `404` on filing says is gone (app API guide §6.1): the linked
/// check, the linked retail user, or the route itself ("Not available").
enum MissingLink { check, retailUser, route }

class ReportIncidentState {
  const ReportIncidentState({
    this.checkRef,
    this.retailUser,
    this.photos = const [],
    this.filing = FilingStatus.editing,
    this.reportId,
    this.filedAt,
    this.failure,
    this.photoProblem,
    this.photoProblemCount = 0,
    this.samePhotoCount = 0,
    this.retryAt,
    this.missing,
  });

  final String? checkRef;
  final ({String id, String name})? retailUser;
  final List<ReportPhoto> photos;
  final FilingStatus filing;
  final int? reportId;
  final DateTime? filedAt;

  /// Why filing failed.
  final Failure? failure;

  /// Why the last photo could not be prepared, and a counter to show it.
  final PhotoProblem? photoProblem;
  final int photoProblemCount;

  /// Counts photos the server already had on this report (it answered an
  /// `n` another tile holds); each one is shown once.
  final int samePhotoCount;

  /// After a `404` on filing: what was not found.
  final MissingLink? missing;

  /// After a `429` on filing: no new filing before this time (final.md
  /// §13.5, §15).
  final DateTime? retryAt;

  bool get isFiled => filing == FilingStatus.filed;
  bool get canEdit =>
      filing == FilingStatus.editing || filing == FilingStatus.failed;

  ReportIncidentState copyWith({
    String? Function()? checkRef,
    ({String id, String name})? Function()? retailUser,
    List<ReportPhoto>? photos,
    FilingStatus? filing,
    int? reportId,
    DateTime? filedAt,
    Failure? Function()? failure,
    PhotoProblem? photoProblem,
    int? photoProblemCount,
    int? samePhotoCount,
    DateTime? Function()? retryAt,
    MissingLink? Function()? missing,
  }) => ReportIncidentState(
    checkRef: checkRef == null ? this.checkRef : checkRef(),
    retailUser: retailUser == null ? this.retailUser : retailUser(),
    photos: photos ?? this.photos,
    filing: filing ?? this.filing,
    reportId: reportId ?? this.reportId,
    filedAt: filedAt ?? this.filedAt,
    failure: failure == null ? this.failure : failure(),
    photoProblem: photoProblem ?? this.photoProblem,
    photoProblemCount: photoProblemCount ?? this.photoProblemCount,
    samePhotoCount: samePhotoCount ?? this.samePhotoCount,
    retryAt: retryAt == null ? this.retryAt : retryAt(),
    missing: missing == null ? this.missing : missing(),
  );
}

/// Report incident (final.md §13.5). The report is filed once and
/// never filed again; photos are sent one at a time after it, within an
/// hour, at most 3.
class ReportIncidentBloc
    extends Bloc<ReportIncidentEvent, ReportIncidentState> {
  ReportIncidentBloc({
    required FileReport fileReport,
    required AddReportPhoto addPhoto,
    required PhotoService photos,
    String? checkRef,
    DateTime Function()? now,
  }) : _fileReport = fileReport,
       _addPhoto = addPhoto,
       _photos = photos,
       _now = now ?? clock.now,
       super(ReportIncidentState(checkRef: checkRef)) {
    on<CheckRefChosen>((e, emit) {
      if (state.canEdit) emit(state.copyWith(checkRef: () => e.ref));
    });
    on<CheckRefCleared>((_, emit) {
      if (state.canEdit) emit(state.copyWith(checkRef: () => null));
    });
    on<RetailUserChosen>((e, emit) {
      if (state.canEdit) emit(state.copyWith(retailUser: () => e.user));
    });
    on<PhotoPickRequested>(_onPick, transformer: droppable());
    on<PhotoRemoved>(_onRemove);
    on<ReportSubmitted>(_onSubmit, transformer: droppable());
    on<PhotoRetried>(_onRetry);
    // One upload at a time, in order (app API guide §6.2).
    on<_UploadRequested>(_onUpload, transformer: sequential());
  }

  final FileReport _fileReport;
  final AddReportPhoto _addPhoto;
  final PhotoService _photos;
  final DateTime Function() _now;
  int _nextId = 0;

  /// Photos may be added or sent again: before filing, or within the hour.
  bool get canAddPhoto =>
      state.photos.length < ReportRules.maxPhotos && _withinWindow;

  /// The hour for photos after filing is over (guide section 6.2).
  bool get photoHourOver => state.isFiled && !_withinWindow;

  bool get _withinWindow {
    final filedAt = state.filedAt;
    return filedAt == null ||
        _now().isBefore(filedAt.add(ReportRules.photoWindow));
  }

  Future<void> _onPick(
    PhotoPickRequested event,
    Emitter<ReportIncidentState> emit,
  ) async {
    if (!canAddPhoto) return;
    final PreparedPhoto? photo;
    try {
      photo = await _photos.pick(event.source);
    } on PhotoException catch (e) {
      emit(
        state.copyWith(
          photoProblem: e.problem,
          photoProblemCount: state.photoProblemCount + 1,
        ),
      );
      return;
    }
    if (photo == null || !canAddPhoto) return;
    emit(
      state.copyWith(
        photos: [
          ...state.photos,
          ReportPhoto(localId: _nextId++, photo: photo),
        ],
      ),
    );
    if (state.isFiled) _upload();
  }

  /// Sends the waiting photos, unless the screen is already closed: after
  /// an awaited answer the bloc may be gone (UI audit 2026-11-22, 8.1),
  /// and adding to a closed bloc throws.
  void _upload() {
    if (!isClosed) add(const _UploadRequested());
  }

  void _onRemove(PhotoRemoved event, Emitter<ReportIncidentState> emit) {
    // A photo already sent stays on the report.
    emit(
      state.copyWith(
        photos: [
          for (final p in state.photos)
            if (p.localId != event.localId ||
                p.status == PhotoStatus.sent ||
                p.status == PhotoStatus.sending)
              p,
        ],
      ),
    );
  }

  Future<void> _onSubmit(
    ReportSubmitted event,
    Emitter<ReportIncidentState> emit,
  ) async {
    // Filed once: never again, whatever happens to the photos.
    if (!state.canEdit || event.note.trim().isEmpty) return;
    final wait = state.retryAt;
    if (wait != null && _now().isBefore(wait)) return;
    emit(
      state.copyWith(
        filing: FilingStatus.filing,
        failure: () => null,
        missing: () => null,
      ),
    );
    final result = await _fileReport(
      note: event.note,
      checkRef: state.checkRef,
      retailUserId: state.retailUser?.id,
    );
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            filing: FilingStatus.filed,
            reportId: value,
            filedAt: _now(),
          ),
        );
        _upload();
      // Sent and lost: it may be filed. Never sent: filing again is safe.
      // Answered 2xx but unreadable: the server took it, so it may be
      // filed too (a 5xx stays failed: the guide allows filing again).
      case Err(:final failure)
          when (failure.exception is NetworkException &&
                  !(failure.exception as NetworkException).wasNotSent) ||
              _acceptedUnreadable(failure.exception):
        emit(
          state.copyWith(
            filing: FilingStatus.unconfirmed,
            failure: () => failure,
          ),
        );
      case Err(:final failure):
        final missing = failure.exception is NotFoundException
            ? _missing(failure.exception)
            : null;
        emit(
          state.copyWith(
            filing: FilingStatus.failed,
            failure: () => failure,
            retryAt: () => failure.exception is RateLimitedException
                ? failure.retryAtFrom(_now())
                : null,
            missing: () => missing,
            // A retail user that cannot be named any more is taken off, so
            // the picker is offered again.
            retailUser: missing == MissingLink.retailUser ? () => null : null,
          ),
        );
    }
  }

  /// What the repository found gone (P-25); else the route itself.
  static MissingLink _missing(AppException e) => switch (e.reason) {
    IncidentReason.checkGone => MissingLink.check,
    IncidentReason.retailUserGone => MissingLink.retailUser,
    _ => MissingLink.route,
  };

  /// A success status whose body could not be read.
  static bool _acceptedUnreadable(AppException e) {
    if (e is! InternalErrorException) return false;
    final status = e.statusCode;
    return e.reason == ApiAnswer.incidentId ||
        (status != null && status >= 200 && status < 300);
  }

  void _onRetry(PhotoRetried event, Emitter<ReportIncidentState> emit) {
    if (!state.isFiled || !_withinWindow) return;
    final target = state.photos.where((p) => p.localId == event.localId);
    if (target.isEmpty || !target.single.canRetry) return;
    final wait = target.single.retryAt;
    if (wait != null && _now().isBefore(wait)) return;
    emit(
      state.copyWith(
        photos: [
          for (final p in state.photos)
            p.localId == event.localId
                ? p.copyWith(
                    status: PhotoStatus.waiting,
                    failure: () => null,
                    retryAt: () => null,
                  )
                : p,
        ],
      ),
    );
    _upload();
  }

  Future<void> _onUpload(
    _UploadRequested event,
    Emitter<ReportIncidentState> emit,
  ) async {
    final reportId = state.reportId;
    if (reportId == null) return;
    while (true) {
      final next = state.photos
          .where((p) => p.status == PhotoStatus.waiting)
          .firstOrNull;
      if (next == null || !_withinWindow) return;
      _replace(emit, next.copyWith(status: PhotoStatus.sending));
      final result = await _addPhoto(
        reportId,
        next.bytes,
        contentType: next.photo.contentType,
      );
      final current = state.photos.firstWhere(
        (p) => p.localId == next.localId,
      );
      // The same file again answers the `n` it already has (guide section
      // 6.2): one photo, one tile.
      if (result case Success(:final value)
          when state.photos.any(
            (p) =>
                p.localId != next.localId &&
                p.status == PhotoStatus.sent &&
                p.number == value,
          )) {
        emit(
          state.copyWith(
            photos: [
              for (final p in state.photos)
                if (p.localId != next.localId) p,
            ],
            samePhotoCount: state.samePhotoCount + 1,
          ),
        );
        continue;
      }
      _replace(
        emit,
        switch (result) {
          Success(:final value) => current.copyWith(
            status: PhotoStatus.sent,
            number: value,
            failure: () => null,
          ),
          Err(:final failure) => current.copyWith(
            status: PhotoStatus.failed,
            failure: () => failure,
            // A 429 waits its Retry-After; without one, the photo can be
            // tapped again (guide section 1: never a number in the app).
            retryAt: () => failure.retryAtFrom(_now()),
          ),
        },
      );
      // Over the limit: the next photo would be refused too; stop here.
      if (result case Err(
        :final failure,
      ) when failure.exception is RateLimitedException) {
        return;
      }
    }
  }

  void _replace(Emitter<ReportIncidentState> emit, ReportPhoto photo) => emit(
    state.copyWith(
      photos: [
        for (final p in state.photos) p.localId == photo.localId ? photo : p,
      ],
    ),
  );
}
