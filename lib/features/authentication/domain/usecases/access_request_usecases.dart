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
  Future<Result<void>> call(AccessRequest request) async {
    if (!looksLikeEmail(request.email) ||
        request.name.trim().isEmpty ||
        request.name.trim().runes.length > 100 ||
        request.roleId < 1 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(request.code) ||
        !const PasswordPolicy().check(request.password).isValid) {
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
