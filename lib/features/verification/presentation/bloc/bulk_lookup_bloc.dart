import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

part 'bulk_lookup_bloc.freezed.dart';

sealed class BulkLookupEvent {
  const BulkLookupEvent();
}

final class BulkFormatsRequested extends BulkLookupEvent {
  const BulkFormatsRequested();
}

/// A scanned QR text or a typed serial or hidden code to add to the list.
final class BulkItemAdded extends BulkLookupEvent {
  const BulkItemAdded(this.way, this.raw);
  final LookupWay way;
  final String raw;
}

final class BulkItemRemoved extends BulkLookupEvent {
  const BulkItemRemoved(this.id);
  final int id;
}

final class BulkListCleared extends BulkLookupEvent {
  const BulkListCleared();
}

/// Sends the whole list once (`droppable`, final.md Section 8.3).
final class BulkSubmitted extends BulkLookupEvent {
  const BulkSubmitted();
}

/// Leaves the results and starts a new, empty list.
final class BulkRestarted extends BulkLookupEvent {
  const BulkRestarted();
}

/// Why an item was not added.
sealed class AddProblem {
  const AddProblem();
}

final class AddRefused extends AddProblem {
  const AddRefused(this.refused);
  final RefusedInput refused;
}

/// The same item is already in the list. Each item sent is its own
/// recorded check, so the app never adds it twice.
final class AddDuplicate extends AddProblem {
  const AddDuplicate();
}

/// The list already holds [bulkMaxItems].
final class AddListFull extends AddProblem {
  const AddListFull();
}

enum BulkStatus { composing, sending, done, failed }

@freezed
abstract class BulkLookupState with _$BulkLookupState {
  const factory BulkLookupState({
    InputFormats? formats,
    Failure? formatsFailure,
    @Default(<BulkEntry>[]) List<BulkEntry> entries,
    @Default(BulkStatus.composing) BulkStatus status,

    /// The last add that was refused, and a counter so each one is shown.
    AddProblem? addProblem,
    @Default(0) int addProblemCount,

    /// The last item added (feedback while scanning many codes).
    BulkEntry? lastAdded,
    BulkOutcome? outcome,

    /// When the [outcome] arrived: the check time of every row.
    DateTime? checkedAt,
    Failure? failure,

    /// After a `429`: when the list may be sent again.
    DateTime? retryAt,
  }) = _BulkLookupState;

  const BulkLookupState._();

  bool get isFull => entries.length >= bulkMaxItems;
  bool get canSend =>
      entries.isNotEmpty &&
      status != BulkStatus.sending &&
      status != BulkStatus.done;
}

/// Bulk lookup (final.md Section 13.2): up to 500 items, results matched by
/// position. On `503` or `429` nothing was checked: the same list stays and
/// can be sent again.
class BulkLookupBloc extends Bloc<BulkLookupEvent, BulkLookupState> {
  BulkLookupBloc({
    required GetFormats getFormats,
    required BulkLookup bulkLookup,
    PrepareInput prepareInput = const PrepareInput(),
    DateTime Function()? now,
  }) : _getFormats = getFormats,
       _bulkLookup = bulkLookup,
       _prepare = prepareInput,
       _now = now ?? clock.now,
       super(const BulkLookupState()) {
    on<BulkFormatsRequested>(_onFormats, transformer: droppable());
    on<BulkItemAdded>(_onAdd);
    on<BulkItemRemoved>(
      (e, emit) => emit(
        state.copyWith(
          entries: [
            for (final entry in state.entries)
              if (entry.id != e.id) entry,
          ],
        ),
      ),
    );
    on<BulkListCleared>(
      (_, emit) => emit(
        state.copyWith(
          entries: const [],
          lastAdded: null,
          failure: null,
          status: BulkStatus.composing,
        ),
      ),
    );
    on<BulkSubmitted>(_onSubmit, transformer: droppable());
    on<BulkRestarted>(
      (_, emit) => emit(BulkLookupState(formats: state.formats)),
    );
  }

  final GetFormats _getFormats;
  final BulkLookup _bulkLookup;
  final PrepareInput _prepare;
  final DateTime Function() _now;
  int _nextId = 0;

  Future<void> _onFormats(
    BulkFormatsRequested event,
    Emitter<BulkLookupState> emit,
  ) async {
    if (state.formats != null) return;
    emit(state.copyWith(formatsFailure: null));
    final result = await _getFormats();
    emit(switch (result) {
      Success(:final value) => state.copyWith(formats: value),
      Err(:final failure) => state.copyWith(formatsFailure: failure),
    });
  }

  void _onAdd(BulkItemAdded event, Emitter<BulkLookupState> emit) {
    final formats = state.formats;
    if (formats == null || state.status == BulkStatus.sending) return;
    if (state.status == BulkStatus.done) return;

    void refuse(AddProblem problem) => emit(
      state.copyWith(
        addProblem: problem,
        addProblemCount: state.addProblemCount + 1,
      ),
    );

    if (state.isFull) return refuse(const AddListFull());
    final prepared = _prepare(event.way, event.raw, formats);
    switch (prepared) {
      case RefusedInput():
        return refuse(AddRefused(prepared));
      case ReadyInput(:final way, :final value):
        final duplicate = state.entries.any(
          (e) => e.way == way && e.value == value,
        );
        if (duplicate) return refuse(const AddDuplicate());
        final entry = BulkEntry(id: _nextId++, way: way, value: value);
        emit(
          state.copyWith(
            entries: [...state.entries, entry],
            lastAdded: entry,
            addProblem: null,
            status: BulkStatus.composing,
            failure: null,
          ),
        );
    }
  }

  Future<void> _onSubmit(
    BulkSubmitted event,
    Emitter<BulkLookupState> emit,
  ) async {
    if (!state.canSend) return;
    final retryAt = state.retryAt;
    if (retryAt != null && _now().isBefore(retryAt)) return;

    emit(state.copyWith(status: BulkStatus.sending, failure: null));
    final result = await _bulkLookup(state.entries);
    switch (result) {
      case Success(:final value):
        // The typed values, hidden codes included, are dropped once the
        // results are in; the rows keep only masked labels (Section 12.1).
        emit(
          BulkLookupState(
            formats: state.formats,
            status: BulkStatus.done,
            checkedAt: _now(),
            outcome: value,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: BulkStatus.failed,
            failure: failure,
            retryAt: failure.exception is RateLimitedException
                ? _now().add(failure.retryAfter ?? const Duration(seconds: 60))
                : null,
          ),
        );
    }
  }
}
