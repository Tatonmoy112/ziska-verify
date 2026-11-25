import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/utils/ascii_digits.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ziska_verify/features/authentication/domain/services/email_check.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';

/// One use case per action (final.md §3). Each validates its input
/// before the repository; a screen checks first only to say so
/// (production audit P-33).
class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<Result<LoginOutcome>> call({
    required String email,
    required String password,
  }) async {
    if (!looksLikeEmail(email) || password.isEmpty) return _invalid;
    return _repository.login(email: email.trim(), password: password);
  }
}

class VerifyCode {
  const VerifyCode(this._repository);
  final AuthRepository _repository;

  /// The emailed code: exactly 6 digits (guide §3.2), any script's
  /// digits read as 0-9.
  Future<Result<LoginOutcome>> call(String code) async {
    final digits = _code(code);
    if (digits == null) return _invalid;
    return _repository.verifyCode(digits);
  }
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
  }) async {
    if (oldPassword.isEmpty || !_strong(newPassword)) return _invalid;
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) async {
    if (!looksLikeEmail(email)) return _invalid;
    return _repository.requestPasswordReset(email.trim());
  }
}

class ResetPassword {
  const ResetPassword(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final digits = _code(code);
    if (!looksLikeEmail(email) || digits == null || !_strong(newPassword)) {
      return _invalid;
    }
    return _repository.resetPassword(
      email: email.trim(),
      code: digits,
      newPassword: newPassword,
    );
  }
}

class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

/// Input the server would refuse: nothing is sent.
const _invalid = Err<Never>(Failure(ValidationException()));

/// [input] as the 6 digits the server takes, or `null` (guide §3.2).
String? _code(String input) {
  final digits = toAsciiDigits(input.trim());
  return RegExp(r'^[0-9]{6}$').hasMatch(digits) ? digits : null;
}

/// A new password the server's rule takes (guide §3.6).
bool _strong(String password) => const PasswordPolicy().check(password).isValid;
