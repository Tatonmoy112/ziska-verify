import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';

/// Shared behaviour: one request at a time, then success or failure.
abstract class _SubmitCubit extends Cubit<SubmitState> {
  _SubmitCubit() : super(const SubmitState());

  Future<void> run(Future<Result<void>> Function() action) async {
    if (state.isSubmitting || state.isWaiting) return;
    emit(const SubmitState(status: SubmitStatus.submitting));
    final result = await action();
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(const SubmitState(status: SubmitStatus.success));
      case Err(:final failure):
        emit(SubmitState.failed(failure));
    }
  }
}

/// `me/password`, forced or voluntary (final.md §6).
class ChangePasswordCubit extends _SubmitCubit {
  ChangePasswordCubit(this._changePassword, this._logout);

  final ChangePassword _changePassword;
  final Logout _logout;

  Future<void> submit({
    required String oldPassword,
    required String newPassword,
  }) => run(
    () => _changePassword(oldPassword: oldPassword, newPassword: newPassword),
  );

  /// The only way out of a forced change.
  Future<void> logout() => _logout();
}

/// `auth/password/forgot`: always the same answer.
class ForgotPasswordCubit extends _SubmitCubit {
  ForgotPasswordCubit(this._request);

  final RequestPasswordReset _request;

  Future<void> submit(String email) => run(() => _request(email));
}

/// `auth/password/reset`: the code and a new password.
class ResetPasswordCubit extends _SubmitCubit {
  ResetPasswordCubit(this._reset);

  final ResetPassword _reset;

  Future<void> submit({
    required String email,
    required String code,
    required String newPassword,
  }) => run(
    () => _reset(email: email, code: code, newPassword: newPassword),
  );
}
