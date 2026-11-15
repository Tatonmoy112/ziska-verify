import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';

part 'submit_state.freezed.dart';

enum SubmitStatus { idle, submitting, success, failure }

/// The state of a form that sends one request.
@freezed
abstract class SubmitState with _$SubmitState {
  const factory SubmitState({
    @Default(SubmitStatus.idle) SubmitStatus status,
    Failure? failure,

    /// After a `429`: no new request before this time (final.md Section
    /// 15.4: a countdown from `Retry-After`, then a retry is allowed).
    DateTime? retryAt,
  }) = _SubmitState;

  /// A failed request; a `429` also sets [retryAt].
  factory SubmitState.failed(Failure failure) => SubmitState(
    status: SubmitStatus.failure,
    failure: failure,
    retryAt: failure.exception is RateLimitedException
        ? clock.now().add(failure.retryAfter ?? defaultRetryAfter)
        : null,
  );

  const SubmitState._();

  /// The wait shown when a `429` has no usable `Retry-After`.
  static const defaultRetryAfter = Duration(seconds: 60);

  bool get isSubmitting => status == SubmitStatus.submitting;

  /// A `429` countdown is still running: a new request is not sent.
  bool get isWaiting => retryAt != null && clock.now().isBefore(retryAt!);
}
