import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';

/// One use case per action (final.md §3).
class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<Result<LoginOutcome>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email.trim(), password: password);
}

class VerifyCode {
  const VerifyCode(this._repository);
  final AuthRepository _repository;

  Future<Result<LoginOutcome>> call(String code) =>
      _repository.verifyCode(code.trim());
}

class ResendCode {
  const ResendCode(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.resendCode();
}

class CancelCode {
  const CancelCode(this._repository);
  final AuthRepository _repository;

  void call() => _repository.cancelCode();
}

class ChangePassword {
  const ChangePassword(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call({
    required String oldPassword,
    required String newPassword,
  }) => _repository.changePassword(
    oldPassword: oldPassword,
    newPassword: newPassword,
  );
}

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) =>
      _repository.requestPasswordReset(email.trim());
}

class ResetPassword {
  const ResetPassword(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) => _repository.resetPassword(
    email: email.trim(),
    code: code.trim(),
    newPassword: newPassword,
  );
}

class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
