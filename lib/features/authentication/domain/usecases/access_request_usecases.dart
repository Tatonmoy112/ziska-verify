import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/access_request_repository.dart';
import 'package:ziska_verify/features/authentication/domain/services/email_check.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';

class GetRequestableRoles {
  const GetRequestableRoles(this._repository);
  final AccessRequestRepository _repository;
  Future<Result<List<RequestableRole>>> call() => _repository.roles();
}

class SendAccessCode {
  const SendAccessCode(this._repository);
  final AccessRequestRepository _repository;
  Future<Result<void>> call(String email) async => looksLikeEmail(email)
      ? _repository.sendCode(email.trim())
      : const Err(Failure(ValidationException()));
}

class SubmitAccessRequest {
  const SubmitAccessRequest(this._repository);
  final AccessRequestRepository _repository;

  /// Whether the form can be sent, the code aside: a name of 1 to
  /// [AccessRequest.nameMaxLength] (UTF-16 units, as the server counts a
  /// name, B5), an email, a password the rule takes, and a role. The screen
  /// asks it to enable Send (production audit P-38).
  static bool formReady({
    required String name,
    required String email,
    required String password,
    required int? roleId,
  }) =>
      name.trim().isNotEmpty &&
      name.trim().length <= AccessRequest.nameMaxLength &&
      looksLikeEmail(email) &&
      const PasswordPolicy().check(password).isValid &&
      roleId != null &&
      roleId >= 1;

  Future<Result<void>> call(AccessRequest request) async {
    if (!formReady(
          name: request.name,
          email: request.email,
          password: request.password,
          roleId: request.roleId,
        ) ||
        !RegExp(r'^[0-9]{6}$').hasMatch(request.code)) {
      return const Err(Failure(ValidationException()));
    }
    return _repository.submit(
      AccessRequest(
        email: request.email.trim(),
        code: request.code,
        name: request.name.trim(),
        roleId: request.roleId,
        password: request.password,
      ),
    );
  }
}
