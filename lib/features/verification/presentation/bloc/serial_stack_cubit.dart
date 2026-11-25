import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/services/parse_stack.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
part 'serial_stack_cubit.freezed.dart';

@freezed
abstract class SerialStackState with _$SerialStackState {
  const factory SerialStackState({
    InputFormats? formats,
    @Default(false) bool busy,
    @Default(false) bool paused,
    @Default(false) bool uncertain,

    /// The stack was recorded, but its answer could not be read (it did not
    /// match what was sent). Never sent again: all or nothing applies only
    /// to an answer that is not 200 (app API guide §4.7).
    @Default(false) bool recorded,

    /// The serial that stopped the stack before sending, by its place.
    ({int position, String value})? badSerial,
    @Default(false) bool submitted,

    /// The stack as typed, counted as it will be sent: shown under the box
    /// (production audit P-38). `null` before the formats or with no text.
    ParsedStack? draft,
    @Default(<String>[]) List<String> serials,
    SerialStackResult? result,
    DateTime? checkedAt,
    Failure? failure,
    DateTime? retryAt,
  }) = _SerialStackState;
}

class SerialStackCubit extends Cubit<SerialStackState> {
  SerialStackCubit({
    required GetFormats getFormats,
    required CheckSerials checkSerials,
  }) : _getFormats = getFormats,
       _checkSerials = checkSerials,
       super(const SerialStackState());
  final GetFormats _getFormats;
  final CheckSerials _checkSerials;
  Timer? _retry;
  bool _loading = false;

  /// The text in the box, counted again once the formats arrive.
  String _typed = '';
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final result = await _getFormats();
    _loading = false;
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            formats: value,
            failure: null,
            retryAt: null,
            draft: _parse(_typed, value),
          ),
        );
      case Err(:final failure):
        // A 429 counts down on the button before it reads them again.
        emit(
          state.copyWith(
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
          ),
        );
    }
  }

  /// The box changed (typed, pasted or cleared): its stack is counted.
  void edit(String text) {
    _typed = text;
    if (isClosed) return;
    emit(state.copyWith(draft: _parse(text, state.formats)));
  }

  static ParsedStack? _parse(String text, InputFormats? formats) {
    if (formats == null) return null;
    final parsed = const ParseStack()(text, formats);
    return parsed.typed == 0 ? null : parsed;
  }

  /// Send: the stack already composed goes again (after a wait or once
  /// sent); otherwise [text] is composed first, and goes only if it is a
  /// stack that can be sent.
  Future<void> submitText(String text) async {
    if (state.submitted || state.retryAt != null || compose(text)) {
      await submit();
    }
  }

  bool compose(String text) {
    final formats = state.formats;
    if (state.busy ||
        state.submitted ||
        state.result != null ||
        formats == null ||
        state.retryAt != null ||
        state.uncertain ||
        state.recorded) {
      return false;
    }
    final parsed = const ParseStack()(text, formats);
    if (parsed.bad case final bad?) {
      // Name the serial: one bad value among 50 must be findable.
      emit(
        state.copyWith(
          failure: const Failure(
            ValidationException(reason: VerificationReason.serialInput),
          ),
          badSerial: bad,
        ),
      );
      return false;
    }
    final serials = parsed.serials;
    // The stack's rule is the use case's (P-29): asked here only to say so
    // before anything is sent.
    if (CheckSerials.refusal(serials) case final refused?) {
      emit(state.copyWith(failure: Failure(refused)));
      return false;
    }
    emit(
      state.copyWith(
        serials: List.unmodifiable(serials),
        failure: null,
        badSerial: null,
      ),
    );
    return true;
  }

  Future<void> submit({bool automatic = false}) async {
    if (state.busy ||
        state.paused ||
        state.recorded ||
        state.serials.isEmpty ||
        state.result != null ||
        (state.retryAt != null && clock.now().isBefore(state.retryAt!))) {
      return;
    }
    _retry?.cancel();
    final values = state.serials;
    emit(
      state.copyWith(
        busy: true,
        submitted: true,
        failure: null,
        uncertain: false,
        retryAt: null,
      ),
    );
    final result = await _checkSerials(values);
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            busy: false,
            result: value,
            checkedAt: clock.now(),
            serials: [],
          ),
        );
      case Err(:final failure)
          when failure.exception is InternalErrorException &&
              failure.exception.reason ==
                  VerificationReason.serialStackMismatch:
        emit(state.copyWith(busy: false, failure: failure, recorded: true));
      case Err(:final failure):
        final retryAt =
            failure.retryAtFrom(clock.now()) ??
            (!automatic && failure.exception is ServiceUnavailableException
                ? clock.now().add(const Duration(seconds: 1))
                : null);
        emit(
          state.copyWith(
            busy: false,
            failure: failure,
            retryAt: retryAt,
            // Never sent (no connection): nothing was recorded. Sent and
            // lost: it may have been recorded, so the official decides.
            uncertain:
                failure.exception is NetworkException &&
                !(failure.exception as NetworkException).wasNotSent,
          ),
        );
        Duration? delay;
        if (!automatic && failure.exception is ServiceUnavailableException) {
          delay = const Duration(seconds: 1);
        }
        if (retryAt != null && !automatic) {
          delay = retryAt.difference(clock.now());
        }
        if (delay != null && !state.paused) {
          _retry = Timer(delay, () {
            if (!isClosed && !state.paused) unawaited(submit(automatic: true));
          });
        }
    }
  }

  void pause() {
    _retry?.cancel();
    emit(state.copyWith(paused: true));
  }

  void resume() => emit(state.copyWith(paused: false));
  void reset() {
    _retry?.cancel();
    emit(SerialStackState(formats: state.formats));
  }

  @override
  Future<void> close() {
    _retry?.cancel();
    return super.close();
  }
}
