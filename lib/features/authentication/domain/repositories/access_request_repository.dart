import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';

abstract interface class AccessRequestRepository {
  Future<Result<List<RequestableRole>>> roles();
  Future<Result<void>> sendCode(String email);
  Future<Result<void>> submit(AccessRequest request);
}
