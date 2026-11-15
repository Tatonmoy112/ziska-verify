import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';

part 'verify_code_bloc.freezed.dart';

sealed class VerifyCodeEvent {
  const VerifyCodeEvent();
}

final class CodeSubmitted extends VerifyCodeEvent {
  const CodeSubmitted(this.code);
  final String code;
}

final class ResendRequested extends VerifyCodeEvent {
  const ResendRequested();
}

final class BackToLoginRequested extends VerifyCodeEvent {
  const BackToLoginRequested();
}

@freezed
abstract class VerifyCodeState with _$VerifyCodeState {
  const factory VerifyCodeState({
    @Default(SubmitState()) SubmitState submit,

    /// When "Send the code again" becomes available.
    DateTime? resendAvailableAt,
    @Default(false) bool resending,
    Failure? resendFailure,

    /// Increments on every successful resend, to show "A new code was
    /// sent." once.
    @Default(0) int resentCount,

    /// The 3 resends are used up: the official must log in again.
    @Default(false) bool resendLimitReached,
  }) = _VerifyCodeState;
}

/// The emailed 6-digit code (final.md Section 6.2). Resending is allowed
/// once a minute, 3 times in all; the wait follows `Retry-After`.
class VerifyCodeBloc extends Bloc<VerifyCodeEvent, VerifyCodeState> {
  VerifyCodeBloc({
    required VerifyCode verifyCode,
    required ResendCode resendCode,
    required CancelCode cancelCode,
    DateTime Function()? now,
  }) : _verifyCode = verifyCode,
       _resendCode = resendCode,
       _cancelCode = cancelCode,
       _now = now ?? clock.now,
       // The first code was just emailed: the first resend waits a minute.
       super(
         VerifyCodeState(
           resendAvailableAt: (now ?? clock.now)().add(resendWait),
         ),
       ) {
    on<CodeSubmitted>(_onCodeSubmitted, transformer: droppable());
    on<ResendRequested>(_onResend, transformer: droppable());
    on<BackToLoginRequested>((_, _) => _cancelCode());
  }

  /// At most one resend a minute (app API guide §3.2).
  static const resendWait = Duration(minutes: 1);

  final VerifyCode _verifyCode;
  final ResendCode _resendCode;
  final CancelCode _cancelCode;
  final DateTime Function() _now;

  Future<void> _onCodeSubmitted(
    CodeSubmitted event,
    Emitter<VerifyCodeState> emit,
  ) async {
    if (state.submit.isWaiting) return;
    emit(
      state.copyWith(
        submit: const SubmitState(status: SubmitStatus.submitting),
      ),
    );
    final result = await _verifyCode(event.code);
    emit(
      state.copyWith(
        submit: switch (result) {
          Success() => const SubmitState(status: SubmitStatus.success),
          Err(:final failure) => SubmitState.failed(failure),
        },
      ),
    );
  }

  Future<void> _onResend(
    ResendRequested event,
    Emitter<VerifyCodeState> emit,
  ) async {
    final availableAt = state.resendAvailableAt;
    if (availableAt != null && _now().isBefore(availableAt)) return;

    emit(state.copyWith(resending: true, resendFailure: null));
    final result = await _resendCode();
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            resending: false,
            resentCount: state.resentCount + 1,
            resendAvailableAt: _now().add(resendWait),
          ),
        );
      case Err(:final failure):
        final exception = failure.exception;
        emit(
          state.copyWith(
            resending: false,
            resendFailure: failure,
            resendLimitReached: exception is UnauthenticatedException,
            resendAvailableAt: exception is RateLimitedException
                ? _now().add(failure.retryAfter ?? resendWait)
                : state.resendAvailableAt,
          ),
        );
    }
  }
}
