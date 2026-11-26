import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/utils/waits_until.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/services/prepare_input.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

part 'lookup_bloc.freezed.dart';

sealed class LookupEvent {
  const LookupEvent();
}

/// Loads `GET formats`; needed before any input can be checked.
final class FormatsRequested extends LookupEvent {
  const FormatsRequested();
}

/// A scanned QR text or a typed serial (final.md §13.1).
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
    Failure? formatsFailure,

    /// After a `429` on the formats: Retry waits until this time.
    DateTime? formatsRetryAt,
    @Default(LookupStatus.idle) LookupStatus status,
    LookupResult? result,

    /// The serial/QR value and response time (final.md §13.1).
    CheckedInput? checked,
    Failure? failure,
    RefusedInput? refused,

    /// After a `429`: when the next lookup may be sent (`Retry-After`).
    DateTime? retryAt,
  }) = _LookupState;

  const LookupState._();

  bool get isBusy => status == LookupStatus.inProgress;
}

/// The single lookup (final.md §8, §13.1). `droppable`: every
/// lookup is a recorded check, so a second request while one is in flight
/// is never sent (§8).
class LookupBloc extends Bloc<LookupEvent, LookupState> {
  LookupBloc({
    required GetFormats getFormats,
    required LookupItem lookupItem,
    DateTime Function()? now,
  }) : _getFormats = getFormats,
       _now = now ?? clock.now,
       _lookupItem = lookupItem,
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
  static const _prepare = PrepareInput();
  final DateTime Function() _now;

  Future<void> _onFormats(
    FormatsRequested event,
    Emitter<LookupState> emit,
  ) async {
    if (state.formats != null) return;
    final wait = state.formatsRetryAt;
    if (waitsUntil(wait, now: _now())) return;
    // Loading again: the form shows its spinner while there is neither
    // formats nor a failure.
    emit(state.copyWith(formatsFailure: null));
    final result = await _getFormats();
    emit(switch (result) {
      Success(:final value) => state.copyWith(formats: value),
      Err(:final failure) => state.copyWith(
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
    // (final.md §13.1, §15).
    final wait = state.retryAt;
    if (waitsUntil(wait, now: _now())) return;

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
        // The value as sent, leading zeros included.
        checked: CheckedInput(way: ready.way, shown: ready.value, at: _now()),
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
