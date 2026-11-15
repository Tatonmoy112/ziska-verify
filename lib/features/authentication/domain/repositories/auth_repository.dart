import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';

/// Login, the emailed code, passwords, and logout (final.md Section 6).
/// Every outcome also moves the session state, which drives the router.
abstract interface class AuthRepository {
  Future<Result<LoginOutcome>> login({
    required String email,
    required String password,
  });

  Future<Result<LoginOutcome>> verifyCode(String code);

  Future<Result<void>> resendCode();

  /// Back from Verify code to Login.
  void cancelCode();

  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Result<void>> requestPasswordReset(String email);

  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Ends the login on this phone. The phone stays trusted.
  Future<void> logout();
}
