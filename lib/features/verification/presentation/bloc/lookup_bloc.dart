import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

part 'lookup_bloc.freezed.dart';

sealed class LookupEvent {
  const LookupEvent();
}

/// Loads `GET formats`; needed before any input can be checked.
final class FormatsRequested extends LookupEvent {
  const FormatsRequested();
}

/// A scanned QR text or a typed serial (final.md 8.4).
final class LookupRequested extends LookupEvent {
  const LookupRequested(this.way, this.raw);
  final LookupWay way;

  /// The raw input is normalized before the request.
  final String raw;
}

/// Back to idle after a result was shown or an error was read.
final class LookupCleared extends LookupEvent {
  const LookupCleared();
}

enum LookupStatus { idle, inProgress, completed, failed, refused }

@freezed
abstract class LookupState with _$LookupState {
  const factory LookupState({
    InputFormats? formats,
    @Default(false) bool formatsLoading,
    Failure? formatsFailure,

    /// After a `429` on the formats: Retry waits until this time.
    DateTime? formatsRetryAt,
    @Default(LookupStatus.idle) LookupStatus status,
    LookupResult? result,

    /// The serial/QR value and response time (final.md Section 13.1).
    CheckedInput? checked,
    Failure? failure,
    RefusedInput? refused,

    /// After a `429`: when the next lookup may be sent (`Retry-After`).
    DateTime? retryAt,
  }) = _LookupState;

  const LookupState._();

  bool get isBusy => status == LookupStatus.inProgress;
}

/// The single lookup (final.md Sections 8.4, 13.1). `droppable`: every
/// lookup is a recorded check, so a second request while one is in flight
/// is never sent (Section 8.3).
class LookupBloc extends Bloc<LookupEvent, LookupState> {
  LookupBloc({
    required GetFormats getFormats,
    required LookupItem lookupItem,
    PrepareInput prepareInput = const PrepareInput(),
    DateTime Function()? now,
  }) : _getFormats = getFormats,
       _now = now ?? clock.now,
       _lookupItem = lookupItem,
       _prepare = prepareInput,
       super(const LookupState()) {
    on<FormatsRequested>(_onFormats, transformer: droppable());
    on<LookupRequested>(_onLookup, transformer: droppable());
    on<LookupCleared>(
      (_, emit) => emit(
        state.copyWith(
          status: LookupStatus.idle,
          result: null,
          checked: null,
          failure: null,
          refused: null,
        ),
      ),
    );
  }

  final GetFormats _getFormats;
  final LookupItem _lookupItem;
  final PrepareInput _prepare;
  final DateTime Function() _now;

  Future<void> _onFormats(
    FormatsRequested event,
    Emitter<LookupState> emit,
  ) async {
    if (state.formats != null) return;
    final wait = state.formatsRetryAt;
    if (wait != null && _now().isBefore(wait)) return;
    emit(state.copyWith(formatsLoading: true, formatsFailure: null));
    final result = await _getFormats();
    emit(switch (result) {
      Success(:final value) => state.copyWith(
        formats: value,
        formatsLoading: false,
      ),
      Err(:final failure) => state.copyWith(
        formatsLoading: false,
        formatsFailure: failure,
        formatsRetryAt: failure.retryAtFrom(_now()),
      ),
    });
  }

  Future<void> _onLookup(
    LookupRequested event,
    Emitter<LookupState> emit,
  ) async {
    final formats = state.formats;
    if (formats == null) return;
    // A `429` countdown is running: nothing is sent before it ends
    // (final.md Sections 13.1.6, 15.4).
    final wait = state.retryAt;
    if (wait != null && _now().isBefore(wait)) return;

    final prepared = _prepare(event.way, event.raw, formats);
    if (prepared is RefusedInput) {
      emit(
        state.copyWith(
          status: LookupStatus.refused,
          refused: prepared,
          result: null,
          failure: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LookupStatus.inProgress,
        refused: null,
        failure: null,
      ),
    );
    final ready = prepared as ReadyInput;
    final result = await _lookupItem(ready);
    emit(switch (result) {
      Success(:final value) => state.copyWith(
        status: LookupStatus.completed,
        result: value,
        checked: CheckedInput.of(ready.way, ready.value, _now()),
      ),
      Err(:final failure) => state.copyWith(
        status: LookupStatus.failed,
        failure: failure,
        retryAt: failure.exception is RateLimitedException
            ? failure.retryAtFrom(_now())
            : null,
      ),
    });
  }
}
