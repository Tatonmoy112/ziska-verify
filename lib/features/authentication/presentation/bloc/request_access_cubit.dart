import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/utils/waits_until.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';

part 'request_access_cubit.freezed.dart';

enum AccessStage { loading, form, code, pending }

/// Request access (final.md §13.8). Each emit changes only the fields it
/// names (`copyWith`), so a roles reload never clears a wait or the busy
/// flag (production audit P-22).
@freezed
abstract class RequestAccessState with _$RequestAccessState {
  const factory RequestAccessState({
    @Default(AccessStage.loading) AccessStage stage,
    @Default(<RequestableRole>[]) List<RequestableRole> roles,
    @Default(false) bool busy,
    Failure? failure,
    DateTime? retryAt,
    String? email,
    @Default(0) int codeVersion,

    /// The role list was answered at least once. An empty [roles] means
    /// "none can be asked for" only then; before, the load failed or runs.
    @Default(false) bool rolesLoaded,

    /// The waits of a `429` on asking for a code and on sending the
    /// request: the limits are counted apart, so one never blocks the
    /// other.
    DateTime? codeRetryAt,
    DateTime? submitRetryAt,
  }) = _RequestAccessState;

  const RequestAccessState._();

  bool get codeWaiting => waitsUntil(codeRetryAt);
  bool get submitWaiting => waitsUntil(submitRetryAt);
}

class RequestAccessCubit extends Cubit<RequestAccessState> {
  RequestAccessCubit({
    required GetRequestableRoles roles,
    required SendAccessCode sendCode,
    required SubmitAccessRequest submit,
  }) : _roles = roles,
       _sendCode = sendCode,
       _submit = submit,
       super(const RequestAccessState());
  final GetRequestableRoles _roles;
  final SendAccessCode _sendCode;
  final SubmitAccessRequest _submit;
  bool _loadingRoles = false;

  /// Loads the roles; changes the roles only (and leaves `loading`).
  Future<void> load() async {
    if (_loadingRoles || isClosed) return;
    _loadingRoles = true;
    final result = await _roles();
    _loadingRoles = false;
    if (isClosed) return;
    final stage = state.stage == AccessStage.loading
        ? AccessStage.form
        : state.stage;
    switch (result) {
      case Success(:final value):
        emit(state.copyWith(stage: stage, roles: value, rolesLoaded: true));
      case Err(:final failure):
        emit(
          state.copyWith(
            stage: stage,
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
          ),
        );
    }
  }

  void emailEdited() {
    if (state.busy || state.stage != AccessStage.code) return;
    // The code belongs to the old address: back to the form.
    emit(
      state.copyWith(
        stage: AccessStage.form,
        email: null,
        failure: null,
        codeVersion: state.codeVersion + 1,
      ),
    );
  }

  Future<void> sendCode(String email) async {
    if (state.busy || state.codeWaiting || state.roles.isEmpty) return;
    final previous = state;
    emit(state.copyWith(busy: true, failure: null, retryAt: null));
    final result = await _sendCode(email);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            stage: AccessStage.code,
            busy: false,
            failure: null,
            retryAt: null,
            email: email.trim(),
            codeVersion: previous.codeVersion + 1,
          ),
        );
      case Err(:final failure):
        final wait = failure.retryAtFrom(clock.now());
        emit(
          state.copyWith(
            stage: previous.stage,
            busy: false,
            failure: failure,
            retryAt: wait,
            codeRetryAt: wait,
            email: previous.email,
            codeVersion: previous.codeVersion,
          ),
        );
    }
  }

  Future<void> submit(AccessRequest request) async {
    if (state.busy ||
        state.submitWaiting ||
        state.stage != AccessStage.code ||
        request.email.trim() != state.email) {
      return;
    }
    final previous = state;
    emit(state.copyWith(busy: true, failure: null, retryAt: null));
    final result = await _submit(request);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(const RequestAccessState(stage: AccessStage.pending));
      case Err(:final failure):
        // 409, too many requests waiting for the office: the code was used
        // up, so the next try starts with a new one (guide §3.9).
        final consumed = failure.exception is ConflictException;
        final wait = failure.retryAtFrom(clock.now());
        emit(
          state.copyWith(
            stage: consumed ? AccessStage.form : AccessStage.code,
            busy: false,
            failure: failure,
            retryAt: wait,
            submitRetryAt: wait,
            email: previous.email,
            codeVersion: previous.codeVersion + (consumed ? 1 : 0),
          ),
        );
        // "Role not found.": the roles changed; load them again.
        if (failure.exception is NotFoundException) await load();
    }
  }
}
