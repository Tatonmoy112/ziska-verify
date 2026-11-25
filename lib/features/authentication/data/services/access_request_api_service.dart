import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/features/authentication/data/models/access_request_dtos.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';

/// The public routes of Request access (final.md §13.8; app API guide §3.9),
/// sent without a pass.
abstract interface class AccessRequestApiService {
  /// `GET roles/requestable`: the roles a person may ask for.
  Future<List<RequestableRoleDto>> roles();

  /// `POST auth/access/code`: emails a code to [email].
  Future<void> sendCode(String email);

  /// `POST auth/access`: sends the request; its answer is `pending`.
  Future<void> submit(AccessRequest request);
}

class DioAccessRequestApiService implements AccessRequestApiService {
  const DioAccessRequestApiService(this._api);
  final ApiClient _api;

  @override
  Future<List<RequestableRoleDto>> roles() async {
    final data = await _api.get(ApiRoutes.requestableRoles, skipAuth: true);
    return [
      for (final role in ApiData.list(data, 'access_roles'))
        RequestableRoleDto.fromJson(role),
    ];
  }

  @override
  Future<void> sendCode(String email) =>
      _api.post(ApiRoutes.accessCode, skipAuth: true, body: {'email': email});

  @override
  Future<void> submit(AccessRequest request) async {
    final data = await _api.post(
      ApiRoutes.accessRequest,
      skipAuth: true,
      body: {
        'email': request.email,
        'code': request.code,
        'name': request.name,
        'role_id': request.roleId,
        'password': request.password,
      },
    );
    if (ApiData.map(data, 'access_pending')['status'] != 'pending') {
      throw const InternalErrorException(message: 'access_pending_shape');
    }
  }
}
