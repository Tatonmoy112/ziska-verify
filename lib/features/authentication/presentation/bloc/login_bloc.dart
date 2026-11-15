import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:ziska_verify/features/authentication/presentation/bloc/submit_state.dart';

sealed class LoginEvent {
  const LoginEvent();
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});
  final String email;
  final String password;
}

/// Login. `droppable`: a second press while a login is in flight is ignored
/// (final.md Section 8.3). On success the session state moves the official
/// to Verify code, Change password, or Home (Section 9.4).
class LoginBloc extends Bloc<LoginEvent, SubmitState> {
  LoginBloc(this._login) : super(const SubmitState()) {
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final Login _login;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<SubmitState> emit,
  ) async {
    if (state.isWaiting) return;
    emit(const SubmitState(status: SubmitStatus.submitting));
    final result = await _login(email: event.email, password: event.password);
    switch (result) {
      case Success():
        emit(const SubmitState(status: SubmitStatus.success));
      case Err(:final failure):
        emit(SubmitState.failed(failure));
    }
  }
}
