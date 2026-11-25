import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

part 'session_summary_cubit.freezed.dart';

enum SessionSummaryStatus { loading, ready, failed }

@freezed
abstract class SessionSummaryState with _$SessionSummaryState {
  const factory SessionSummaryState({
    @Default(SessionSummaryStatus.loading) SessionSummaryStatus status,
    ScanSessionSummary? session,
    Failure? failure,

    /// After a `429`: Try again sends nothing before this (guide §1).
    DateTime? retryAt,
  }) = _SessionSummaryState;

  const SessionSummaryState._();

  bool get isWaiting => retryAt != null && clock.now().isBefore(retryAt!);
}

/// One session's summary, above its checks (`GET lookups/sessions/{id}`,
/// app API guide §4.5): loaded by a cubit, so a `429` counts down like
/// every other load (production audit P-39).
class SessionSummaryCubit extends Cubit<SessionSummaryState> {
  SessionSummaryCubit(this._load) : super(const SessionSummaryState());

  final Future<Result<ScanSessionSummary>> Function() _load;
  bool _loading = false;

  /// Loads the summary; nothing while one is on its way or a `429`'s wait
  /// runs.
  Future<void> load() async {
    if (_loading || state.isWaiting || isClosed) return;
    _loading = true;
    emit(state.copyWith(status: SessionSummaryStatus.loading, failure: null));
    final result = await _load();
    _loading = false;
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => SessionSummaryState(
        status: SessionSummaryStatus.ready,
        session: value,
      ),
      Err(:final failure) => state.copyWith(
        status: SessionSummaryStatus.failed,
        failure: failure,
        retryAt: failure.retryAtFrom(clock.now()),
      ),
    });
  }
}
