import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/api_error_codes.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/core/utils/waits_until.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/services/prepare_input.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_read_filter.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

part 'scan_session_cubit.freezed.dart';

typedef LoadRecoveredScans =
    Future<Result<RecoveredScans>> Function(String id, String? cursor);

/// A scan answered in this run, kept so its row opens the full result.
class ScanAnswer {
  const ScanAnswer(this.result, this.checked);
  final LookupResult result;
  final CheckedInput checked;
}

/// Where a scanner session is (production audit P-36): one at a time.
enum SessionPhase {
  /// Reading the formats and any saved session.
  starting,

  /// The start failed: Try again, or a wait to count down.
  startFailed,

  /// Taking reads.
  scanning,

  /// Finish was pressed: no new read is taken, and those already read are
  /// still sent and answered.
  finishing,

  /// Ended with Finish: its summary shows every row.
  done,

  /// Left before Finish (the screen closed, the login ended): nothing more
  /// is taken.
  closed,
}

/// What an answer says beside its result; at most one, until the next.
enum ScanNotice {
  /// The same QR again in this session.
  repeat,

  /// The session was full or had ended (`409 session_full`,
  /// `session_ended`): a new one started by itself and the scan went in it
  /// (guide section 4.3). The list starts again, and the screen says why
  /// until the next scan (UI audit 2026-11-22, 5.2).
  renewed,

  /// The session was another official's (`409 session_not_yours`): a new
  /// one started; the screen says so once (guide section 4.3).
  restarted,
}

@freezed
abstract class ScanSessionState with _$ScanSessionState {
  const factory ScanSessionState({
    @Default(SessionPhase.starting) SessionPhase phase,
    String? id,
    InputFormats? formats,
    SessionTotals? totals,
    LookupResult? latest,
    CheckedInput? checked,
    ScanNotice? notice,

    /// A resumed session's scans could not be read: Try again reloads them
    /// (guide section 4.6); scanning goes on meanwhile.
    @Default(false) bool rowsFailed,

    /// A saved session was taken up again; without its totals (no
    /// `history:own`) the counters wait for the next scan's answer instead
    /// of showing zeros.
    @Default(false) bool resumed,

    /// Reads waiting behind the one being checked.
    @Default(0) int pending,

    /// Reads let go when a scan failed: they were not checked and must be
    /// scanned again (guide section 4.6: nothing is queued for later).
    @Default(0) int notChecked,

    /// Goes up with every answered scan, so each answer is announced, even
    /// two equal ones in a row.
    @Default(0) int answered,

    /// After a `429` on loading those scans: not asked again before this.
    DateTime? rowsRetryAt,

    /// This run's answers by `ref`, so a row opens its result.
    @Default(<String, ScanAnswer>{}) Map<String, ScanAnswer> answers,
    @Default(false) bool busy,
    @Default(false) bool paused,
    @Default(false) bool loadingMore,
    @Default(<RecoveredScan>[]) List<RecoveredScan> rows,
    String? nextCursor,
    Failure? failure,
    DateTime? retryAt,
  }) = _ScanSessionState;

  const ScanSessionState._();

  bool get finishing => phase == SessionPhase.finishing;
  bool get done => phase == SessionPhase.done;
  bool get repeat => notice == ScanNotice.repeat;
  bool get renewed => notice == ScanNotice.renewed;
  bool get restarted => notice == ScanNotice.restarted;

  /// A new scan's notices: a repeat is this answer's only, the others stay
  /// until the next answer says otherwise.
  ScanNotice? get _sending => repeat ? null : notice;
}

class ScanSessionCubit extends Cubit<ScanSessionState> {
  ScanSessionCubit({
    required GetFormats getFormats,
    required GetSession getSession,
    required ScanItem scan,
    required EndSession endSession,
    required ActiveScanStore store,
    required Stream<SessionState> authStates,
    LoadRecoveredScans? loadChecks,
  }) : _getFormats = getFormats,
       _getSession = getSession,
       _scan = scan,
       _endSession = endSession,
       _store = store,
       _loadChecks = loadChecks,
       super(const ScanSessionState()) {
    _auth = authStates.listen((s) {
      if (s is SessionUnauthenticated) unawaited(finish());
    });
  }
  final GetFormats _getFormats;
  final GetSession _getSession;
  final ScanItem _scan;
  final EndSession _endSession;
  final ActiveScanStore _store;
  final LoadRecoveredScans? _loadChecks;

  /// The official may read their history (`history:own`): a session's
  /// products can be found in History, then Sessions.
  bool get canReadHistory => _loadChecks != null;
  late final StreamSubscription<SessionState> _auth;
  Future<void> _storageTask = Future<void>.value();

  /// Sends the next read once the spacing or a 429's wait has passed.
  Timer? _pace;

  /// Reads waiting to be sent, in the order the camera read them.
  final _line = <_Read>[];

  /// The read being checked (or waiting out a 429).
  _Read? _inFlight;
  DateTime? _lastSentAt;

  /// At most two scans a second (guide section 4.3: 120 requests a minute).
  static const scanSpacing = Duration(milliseconds: 500);
  bool _ended = false;
  bool _starting = false;

  /// Completed when nothing is being checked and no read waits (Finish).
  Completer<void>? _idle;
  int _generation = 0;

  /// The same QR is one read until another is read (guide §4.3).
  final _reads = QrReadFilter();
  Future<void> _persist(Future<void> Function() action) {
    final next = _storageTask.then((_) => action());
    _storageTask = next.catchError((Object _) {});
    return next;
  }

  bool _active(int generation) =>
      !isClosed && !_ended && generation == _generation;
  Future<void> start() async {
    if (_starting || _ended) return;
    final wait = state.retryAt;
    if (state.id == null && waitsUntil(wait)) {
      return;
    }
    _starting = true;
    final generation = ++_generation;
    emit(state.copyWith(phase: SessionPhase.starting, failure: null));
    try {
      final formats = await _getFormats();
      if (!_active(generation)) return;
      if (formats case Err(:final failure)) {
        emit(
          state.copyWith(
            phase: SessionPhase.startFailed,
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
          ),
        );
        return;
      }
      emit(state.copyWith(formats: (formats as Success<InputFormats>).value));
      var id = await _store.read();
      if (!_active(generation)) return;
      SessionTotals? totals;
      RecoveredScans? checks;
      if (id != null && _loadChecks != null) {
        final saved = await _getSession(id);
        if (!_active(generation)) return;
        switch (saved) {
          case Success(:final value):
            if (value.status == ScanStatus.open &&
                value.kind == SessionKind.qr) {
              totals = value.totals;
              final loaded = await _loadChecks(id, null);
              if (!_active(generation)) return;
              if (loaded case Success(:final value)) checks = value;
              if (loaded case Err(:final failure)) {
                emit(
                  state.copyWith(
                    id: id,
                    totals: totals,
                    // The session goes on; only its scans wait.
                    phase: SessionPhase.scanning,
                    failure: failure,
                    rowsFailed: true,
                    rowsRetryAt: failure.retryAtFrom(clock.now()),
                  ),
                );
                return;
              }
            } else {
              id = null;
            }
          case Err(:final failure):
            if (failure.exception is NotFoundException) {
              id = null;
            } else {
              emit(
                state.copyWith(
                  phase: SessionPhase.startFailed,
                  failure: failure,
                ),
              );
              return;
            }
        }
      }
      final resumed = id != null;
      id ??= ActiveScanStore.newId();
      await _persist(() => _store.save(id!));
      if (!_active(generation)) return;
      emit(
        state.copyWith(
          id: id,
          totals: totals,
          resumed: resumed,
          phase: SessionPhase.scanning,
          rows: checks?.items ?? [],
          nextCursor: checks?.nextCursor,
        ),
      );
    } on Object {
      if (_active(generation)) {
        emit(
          state.copyWith(
            phase: SessionPhase.startFailed,
            failure: const Failure(
              InternalErrorException(reason: VerificationReason.scanStorage),
            ),
          ),
        );
      }
    } finally {
      _starting = false;
    }
  }

  /// A QR read by the camera. A read that comes while another is being
  /// checked waits in line; the line is sent in the order read, one at a
  /// time, [scanSpacing] apart, so no read is dropped (guide section 4.3).
  /// Completes when this read has been answered or let go.
  Future<void> scan(String raw) {
    final formats = state.formats;
    if (_ended ||
        state.phase != SessionPhase.scanning ||
        state.paused ||
        formats == null ||
        state.id == null) {
      return Future<void>.value();
    }
    if (_reads.isRepeat(raw)) return Future<void>.value();
    final prepared = const PrepareInput()(LookupWay.qr, raw, formats);
    if (prepared is! ReadyInput) {
      emit(
        state.copyWith(
          failure: const Failure(
            ValidationException(reason: VerificationReason.scanInput),
          ),
        ),
      );
      return Future<void>.value();
    }
    _reads.take(raw);
    final value = prepared.value;
    if (_inFlight?.value == value || _line.any((r) => r.value == value)) {
      return Future<void>.value();
    }
    final read = _Read(value);
    _line.add(read);
    emit(state.copyWith(pending: _waiting));
    _pump();
    return read.done.future;
  }

  /// Reads in line, the one held back by a 429 included.
  int get _waiting => _line.length;

  /// Sends the next read when nothing is being checked, the spacing has
  /// passed and no 429 wait runs; otherwise comes back when it may.
  void _pump() {
    if (_inFlight == null && _line.isEmpty) _signalIdle();
    if (_inFlight != null ||
        _line.isEmpty ||
        _ended ||
        isClosed ||
        state.paused) {
      return;
    }
    final now = clock.now();
    DateTime? notBefore;
    final wait = state.retryAt;
    if (waitsUntil(wait, now: now)) notBefore = wait;
    final last = _lastSentAt;
    if (last != null) {
      final next = last.add(scanSpacing);
      if (now.isBefore(next) &&
          (notBefore == null || next.isAfter(notBefore))) {
        notBefore = next;
      }
    }
    if (notBefore != null) {
      _pace?.cancel();
      _pace = Timer(notBefore.difference(now), _pump);
      return;
    }
    unawaited(_send(_line.removeAt(0)));
  }

  Future<void> _send(_Read read) async {
    _inFlight = read;
    _lastSentAt = clock.now();
    final sent = read.value;
    final generation = _generation;
    emit(
      state.copyWith(
        busy: true,
        notice: state._sending,
        failure: null,
        retryAt: null,
        notChecked: 0,
        pending: _waiting,
      ),
    );
    var result = await _scan(sent, sessionId: state.id!);
    // Whether this scan went into a new session because the last one was
    // full or had ended.
    var rolledOver = false;
    if (!_active(generation)) return _drop(read);
    if (result case Err(
      failure: Failure(exception: ScanSessionException(:final code)),
    )) {
      final id = ActiveScanStore.newId();
      try {
        await _persist(() => _store.save(id));
      } on Object {
        if (_active(generation)) {
          emit(
            state.copyWith(
              busy: false,
              failure: const Failure(
                InternalErrorException(reason: VerificationReason.scanStorage),
              ),
            ),
          );
        }
        _letGoAll(read);
        return;
      }
      if (!_active(generation)) return _drop(read);
      emit(
        state.copyWith(
          id: id,
          rows: [],
          answers: const {},
          nextCursor: null,
          latest: null,
          checked: null,
          totals: null,
          resumed: false,
        ),
      );
      if (code == ApiErrorCodes.sessionNotYours) {
        _reads.forget();
        emit(state.copyWith(busy: false, notice: ScanNotice.restarted));
        read.letGo();
        _inFlight = null;
        _pump();
        return;
      }
      rolledOver = true;
      emit(state.copyWith(notice: ScanNotice.renewed));
      result = await _scan(sent, sessionId: id);
      if (!_active(generation)) return _drop(read);
    }
    switch (result) {
      case Success(:final value):
        final row = RecoveredScan(
          ref: value.result.ref,
          outcome: value.result.outcome,
          serial: value.result.item?.serial,
          product: value.result.item?.product.name,
        );
        _inFlight = null;
        final checked = CheckedInput(
          way: LookupWay.qr,
          shown: sent,
          at: clock.now(),
        );
        emit(
          state.copyWith(
            busy: false,
            latest: value.result,
            checked: checked,
            answers: state.answers.containsKey(row.ref)
                ? state.answers
                : {
                    ...state.answers,
                    row.ref: ScanAnswer(value.result, checked),
                  },
            // A roll-over says why the list starts again; a new session
            // has no repeat to tell.
            notice: rolledOver
                ? ScanNotice.renewed
                : value.repeat
                ? ScanNotice.repeat
                : null,
            totals: value.session,
            answered: state.answered + 1,
            pending: _waiting,
            rows: value.repeat
                ? state.rows
                : [row, ...state.rows.where((r) => r.ref != row.ref)],
          ),
        );
        read.letGo();
        _pump();
      case Err(:final failure):
        _reads.forget();
        final retryAt = failure.retryAtFrom(clock.now());
        _inFlight = null;
        if (retryAt != null) {
          // A 429 with its wait: this read goes first again once the wait
          // ends, and the line waits behind it (guide section 4.3).
          _line.insert(0, read);
        }
        final dropped = retryAt != null ? 0 : _line.length;
        if (retryAt == null) _letGoAll(null);
        // The previous product's card goes: it is not this scan's result.
        emit(
          state.copyWith(
            busy: false,
            failure: failure,
            retryAt: retryAt,
            latest: null,
            checked: null,
            notice: state._sending,
            notChecked: dropped,
            pending: _waiting,
          ),
        );
        read.letGo();
        _pump();
    }
  }

  /// An answer that came too late for this session: the read is let go.
  void _drop(_Read read) {
    read.letGo();
    if (identical(_inFlight, read)) _inFlight = null;
  }

  /// Lets every waiting read go (and [current]); none is sent later.
  void _letGoAll(_Read? current) {
    _pace?.cancel();
    for (final r in _line) {
      r.letGo();
    }
    _line.clear();
    current?.letGo();
    if (identical(_inFlight, current)) _inFlight = null;
    if (_inFlight == null) _signalIdle();
  }

  void _signalIdle() {
    final idle = _idle;
    _idle = null;
    if (idle != null && !idle.isCompleted) idle.complete();
  }

  /// Finish: no new read is taken; those already read are still sent and
  /// answered (a 429's wait included), then the session ends without
  /// waiting for the server (guide section 4.4). The rows, the totals and
  /// the answers stay for the summary.
  Future<void> complete() async {
    if (_ended || state.phase != SessionPhase.scanning || state.id == null) {
      return;
    }
    emit(state.copyWith(phase: SessionPhase.finishing, paused: false));
    if (_inFlight != null || _line.isNotEmpty) {
      final idle = _idle ??= Completer<void>();
      _pump();
      await idle.future;
    }
    if (_ended || isClosed) return;
    _ended = true;
    ++_generation;
    _pace?.cancel();
    final id = state.id!;
    emit(
      state.copyWith(phase: SessionPhase.done, busy: false, pending: 0),
    );
    unawaited(_endSession(id));
    try {
      await _persist(_store.clear);
    } on Object {
      // The summary still shows; the server closes an idle session itself.
    }
  }

  /// Scan more after a summary: a new session from an empty screen.
  Future<void> restart() async {
    if (!state.done || isClosed) return;
    _ended = false;
    _reads.forget();
    _lastSentAt = null;
    ++_generation;
    emit(const ScanSessionState());
    await start();
  }

  /// The camera stops (a result opened, the app in the background): the
  /// line waits and goes on at [resume].
  void pause() {
    _pace?.cancel();
    if (!isClosed) emit(state.copyWith(paused: true));
  }

  void resume() {
    _reads.forget();
    if (isClosed) return;
    emit(state.copyWith(paused: false));
    _pump();
  }

  // The session's rows are paged here: they are not a `PagedLoader` list
  // (final.md §10; production audit P-45). A `PagedLoader` list belongs
  // to the server alone: a query and its pages, each answer replacing or
  // extending it. These rows are written by this cubit too: each answered
  // scan goes first, a later page adds only the rows not shown yet (one
  // row per `ref`), and the first page comes with the session's resume.
  // The rules every list keeps are kept here: one page at a time, answers
  // for an older run dropped, nothing sent during a `429` wait
  // (`rowsRetryAt`), and scanning goes on meanwhile.

  /// Reads a resumed session's scans again, from the first page. A scan
  /// answered while it is on its way stays first: the page may have been
  /// read before the scan was recorded.
  Future<void> reloadRows() async {
    final id = state.id;
    if (_ended ||
        state.loadingMore ||
        _rowsWaiting ||
        id == null ||
        _loadChecks == null) {
      return;
    }
    final generation = _generation;
    emit(state.copyWith(loadingMore: true));
    final result = await _loadChecks(id, null);
    if (!_active(generation)) return;
    switch (result) {
      case Success(:final value):
        final onPage = {for (final r in value.items) r.ref};
        final scanned = state.rows.where(
          (r) => state.answers.containsKey(r.ref) && !onPage.contains(r.ref),
        );
        emit(
          state.copyWith(
            loadingMore: false,
            rowsFailed: false,
            failure: null,
            rows: [...scanned, ...value.items],
            nextCursor: value.nextCursor,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            loadingMore: false,
            failure: failure,
            rowsRetryAt: failure.retryAtFrom(clock.now()),
          ),
        );
    }
  }

  bool get _rowsWaiting => waitsUntil(state.rowsRetryAt);

  /// The next page of the session's scans: while scanning, and on the
  /// summary, which shows every product (final.md §13.2;
  /// UI audit 2026-11-22, 5.3).
  /// Reading an ended session's checks is read only.
  Future<void> more() async {
    final cursor = state.nextCursor;
    final id = state.id;
    if ((_ended && !state.done) ||
        state.loadingMore ||
        _rowsWaiting ||
        cursor == null ||
        id == null ||
        _loadChecks == null) {
      return;
    }
    final generation = _generation;
    emit(state.copyWith(loadingMore: true));
    final result = await _loadChecks(id, cursor);
    // Dropped once the screen closed or Scan more began.
    if (isClosed || generation != _generation || (_ended && !state.done)) {
      return;
    }
    switch (result) {
      case Success(:final value):
        final refs = state.rows.map((r) => r.ref).toSet();
        emit(
          state.copyWith(
            loadingMore: false,
            failure: null,
            rows: [...state.rows, ...value.items.where((r) => refs.add(r.ref))],
            nextCursor: value.nextCursor,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            loadingMore: false,
            failure: failure,
            rowsRetryAt: failure.retryAtFrom(clock.now()),
          ),
        );
    }
  }

  Future<void> finish() async {
    if (_ended) return;
    _ended = true;
    ++_generation;
    _letGoAll(_inFlight);
    final id = state.id;
    if (!isClosed) emit(const ScanSessionState(phase: SessionPhase.closed));
    if (id != null) unawaited(_endSession(id));
    try {
      await _persist(_store.clear);
    } on Object {
      // Never retain results or block leaving the screen on storage failure.
      // A surviving UUID remains isolated to this official.
      // The server expires an idle session.
    }
  }

  @override
  Future<void> close() async {
    await finish();
    await _auth.cancel();
    return super.close();
  }
}

/// One QR read, waiting to be sent or being checked.
class _Read {
  _Read(this.value);
  final String value;
  final done = Completer<void>();

  void letGo() {
    if (!done.isCompleted) done.complete();
  }
}
