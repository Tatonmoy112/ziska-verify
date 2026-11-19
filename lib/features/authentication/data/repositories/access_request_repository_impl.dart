import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/authentication/data/services/access_request_api_service.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/repositories/access_request_repository.dart';

class AccessRequestRepositoryImpl implements AccessRequestRepository {
  const AccessRequestRepositoryImpl(this._api);
  final AccessRequestApiService _api;
  @override
  Future<Result<List<RequestableRole>>> roles() => guard(
    () async => [
      for (final role in await _api.roles())
        RequestableRole(id: role.id, name: role.name),
    ],
  );
  @override
  Future<Result<void>> sendCode(String email) =>
      guard(() => _api.sendCode(email));
  @override
  Future<Result<void>> submit(AccessRequest request) =>
      guard(() => _api.submit(request));
}
