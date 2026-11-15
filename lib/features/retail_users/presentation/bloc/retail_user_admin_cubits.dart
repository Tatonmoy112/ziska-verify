import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user_admin.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';

enum AddStatus { loadingRoles, rolesFailed, editing, submitting, failed, done }

class AddRetailUserState {
  const AddRetailUserState({
    this.status = AddStatus.loadingRoles,
    this.roles = const [],
    this.failure,
    this.added,
    this.passwordToShow,
    this.retryAt,
  });

  final AddStatus status;
  final List<RetailRole> roles;
  final Failure? failure;
  final AddedRetailUser? added;

  /// The typed first password, shown once more only when it was not emailed
  /// (final.md Section 13.6.1). Cleared with the screen.
  final String? passwordToShow;

  /// After a `429`: no new request before this time (final.md 13.6).
  final DateTime? retryAt;
}

/// Add a retail user (final.md Section 13.6.1).
class AddRetailUserCubit extends Cubit<AddRetailUserState> {
  AddRetailUserCubit({
    required GetRetailRoles getRoles,
    required AddRetailUser addRetailUser,
  }) : _getRoles = getRoles,
       _add = addRetailUser,
       super(const AddRetailUserState());

  final GetRetailRoles _getRoles;
  final AddRetailUser _add;

  Future<void> loadRoles() async {
    emit(const AddRetailUserState());
    final result = await _getRoles();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => AddRetailUserState(
        status: AddStatus.editing,
        roles: value,
      ),
      Err(:final failure) => AddRetailUserState(
        status: AddStatus.rolesFailed,
        failure: failure,
      ),
    });
  }

  Future<void> submit({
    required String name,
    required String email,
    required int roleId,
    required String password,
    required bool sendEmail,
  }) async {
    // One request at a time: a retail user is never added twice.
    if (state.status == AddStatus.submitting) return;
    final wait = state.retryAt;
    if (wait != null && clock.now().isBefore(wait)) return;
    emit(AddRetailUserState(status: AddStatus.submitting, roles: state.roles));
    final result = await _add(
      name: name,
      email: email,
      roleId: roleId,
      password: password,
      sendEmail: sendEmail,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          AddRetailUserState(
            status: AddStatus.done,
            roles: state.roles,
            added: value,
            passwordToShow: value.emailOutcome == EmailOutcome.sent
                ? null
                : password,
          ),
        );
      case Err(:final failure):
        emit(
          AddRetailUserState(
            status: AddStatus.failed,
            roles: state.roles,
            failure: failure,
            retryAt: failure.retryAtFrom(clock.now()),
          ),
        );
    }
  }

  /// Back to an empty form, the password forgotten.
  void addAnother() =>
      emit(AddRetailUserState(status: AddStatus.editing, roles: state.roles));
}

class EmailPasswordState {
  const EmailPasswordState({
    this.busyId,
    this.lastName,
    this.lastFailure,
    this.count = 0,
    this.retryAt,
  });

  /// The retail user whose mail is being sent.
  final String? busyId;
  final String? lastName;

  /// `null` after a success.
  final Failure? lastFailure;

  /// Bumped after each answer, to show its message once.
  final int count;

  /// After a `429`: no new mail is asked for before this time.
  final DateTime? retryAt;
}

/// "Email a new first password" (final.md Section 13.6). Always emailed.
class EmailPasswordCubit extends Cubit<EmailPasswordState> {
  EmailPasswordCubit(this._email) : super(const EmailPasswordState());

  final EmailNewFirstPassword _email;

  Future<void> send({required String id, required String name}) async {
    if (state.busyId != null) return;
    final wait = state.retryAt;
    if (wait != null && clock.now().isBefore(wait)) return;
    emit(EmailPasswordState(busyId: id, count: state.count));
    final result = await _email(id);
    if (isClosed) return;
    emit(
      EmailPasswordState(
        lastName: name,
        lastFailure: switch (result) {
          Success() => null,
          Err(:final failure) => failure,
        },
        count: state.count + 1,
        retryAt: switch (result) {
          Success() => null,
          Err(:final failure) => failure.retryAtFrom(clock.now()),
        },
      ),
    );
  }
}
