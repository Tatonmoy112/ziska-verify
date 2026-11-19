import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/access_request_usecases.dart';

enum AccessStage { loading, form, code, pending }

class RequestAccessState {
  const RequestAccessState({
    this.stage = AccessStage.loading,
    this.roles = const [],
    this.busy = false,
    this.failure,
    this.retryAt,
    this.email,
    this.codeVersion = 0,
    this.rolesLoaded = false,
    this.codeRetryAt,
    this.submitRetryAt,
  });
  final AccessStage stage;
  final List<RequestableRole> roles;
  final bool busy;
  final Failure? failure;
  final DateTime? retryAt;
  final String? email;
  final int codeVersion;

  /// The role list was answered at least once. An empty [roles] means
  /// "none can be asked for" only then; before, the load failed or runs.
  final bool rolesLoaded;

  /// The waits of a `429` on asking for a code and on sending the request:
  /// the limits are counted apart, so one never blocks the other.
  final DateTime? codeRetryAt;
  final DateTime? submitRetryAt;

  bool get codeWaiting =>
      codeRetryAt != null && clock.now().isBefore(codeRetryAt!);
  bool get submitWaiting =>
      submitRetryAt != null && clock.now().isBefore(submitRetryAt!);
  bool get waiting => retryAt != null && clock.now().isBefore(retryAt!);
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
  Future<void> load() async {
    if (_loadingRoles || isClosed) return;
    _loadingRoles = true;
    final previous = state;
    final result = await _roles();
    _loadingRoles = false;
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          RequestAccessState(
            stage: state.stage == AccessStage.loading
                ? AccessStage.form
                : state.stage,
            roles: value,
            rolesLoaded: true,
            email: state.email,
            failure: state.failure,
            retryAt: state.retryAt,
            codeVersion: state.codeVersion,
          ),
        );
      case Err(:final failure):
        emit(
          RequestAccessState(
            stage: previous.stage == AccessStage.loading
                ? AccessStage.form
                : previous.stage,
            roles: previous.roles,
            rolesLoaded: previous.rolesLoaded,
            codeRetryAt: previous.codeRetryAt,
            submitRetryAt: previous.submitRetryAt,
            email: previous.email,
            codeVersion: previous.codeVersion,
            retryAt: failure.retryAtFrom(clock.now()),
            failure: failure,
          ),
        );
    }
  }

  void emailEdited() {
    if (state.busy || state.stage != AccessStage.code) return;
    emit(
      RequestAccessState(
        stage: AccessStage.form,
        roles: state.roles,
        rolesLoaded: state.rolesLoaded,
        codeRetryAt: state.codeRetryAt,
        submitRetryAt: state.submitRetryAt,
        retryAt: state.retryAt,
        codeVersion: state.codeVersion + 1,
      ),
    );
  }

  Future<void> sendCode(String email) async {
    if (state.busy || state.codeWaiting || state.roles.isEmpty) return;
    final previous = state;
    emit(
      RequestAccessState(
        stage: previous.stage,
        roles: previous.roles,
        rolesLoaded: previous.rolesLoaded,
        codeRetryAt: previous.codeRetryAt,
        submitRetryAt: previous.submitRetryAt,
        busy: true,
        email: previous.email,
        codeVersion: previous.codeVersion,
      ),
    );
    final result = await _sendCode(email);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(
          RequestAccessState(
            stage: AccessStage.code,
            roles: state.roles,
            rolesLoaded: state.rolesLoaded,
            codeRetryAt: state.codeRetryAt,
            submitRetryAt: state.submitRetryAt,
            email: email.trim(),
            codeVersion: previous.codeVersion + 1,
          ),
        );
      case Err(:final failure):
        emit(
          RequestAccessState(
            stage: previous.stage,
            roles: state.roles,
            rolesLoaded: state.rolesLoaded,
            codeRetryAt: failure.retryAtFrom(clock.now()),
            submitRetryAt: state.submitRetryAt,
            email: previous.email,
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
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
    emit(
      RequestAccessState(
        stage: AccessStage.code,
        roles: state.roles,
        rolesLoaded: state.rolesLoaded,
        codeRetryAt: state.codeRetryAt,
        submitRetryAt: state.submitRetryAt,
        busy: true,
        email: state.email,
        codeVersion: state.codeVersion,
      ),
    );
    final result = await _submit(request);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(const RequestAccessState(stage: AccessStage.pending));
      case Err(:final failure):
        final consumed = failure.exception is ConflictException;
        emit(
          RequestAccessState(
            stage: consumed ? AccessStage.form : AccessStage.code,
            roles: state.roles,
            rolesLoaded: state.rolesLoaded,
            codeRetryAt: state.codeRetryAt,
            submitRetryAt: failure.retryAtFrom(clock.now()),
            email: previous.email,
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
            codeVersion: previous.codeVersion + (consumed ? 1 : 0),
          ),
        );
        if (failure.exception is NotFoundException) await load();
    }
  }
}
