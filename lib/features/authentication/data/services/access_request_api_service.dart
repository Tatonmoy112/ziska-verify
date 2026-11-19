import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/authentication/data/models/access_request_dtos.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';

class AccessRequestApiService {
  const AccessRequestApiService(this._api);
  final ApiClient _api;

  Future<List<RequestableRoleDto>> roles() async {
    final data = await _api.get('roles/requestable', skipAuth: true);
    if (data is! List) {
      throw const InternalErrorException(message: 'access_roles_shape');
    }
    return [
      for (final role in data.cast<Map<String, dynamic>>())
        RequestableRoleDto.fromJson(role),
    ];
  }

  Future<void> sendCode(String email) =>
      _api.post('auth/access/code', skipAuth: true, body: {'email': email});
  Future<void> submit(AccessRequest request) async {
    final data = await _api.post(
      'auth/access',
      skipAuth: true,
      body: {
        'email': request.email,
        'code': request.code,
        'name': request.name,
        'role_id': request.roleId,
        'password': request.password,
      },
    );
    if (data is! Map<String, dynamic> || data['status'] != 'pending') {
      throw const InternalErrorException(message: 'access_pending_shape');
    }
  }
}
