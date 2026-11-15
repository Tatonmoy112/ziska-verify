import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/models/retail_user_dtos.dart';

/// Retail user routes (final.md Sections 5.7, 13.6).
abstract interface class RetailUserApiService {
  Future<RetailUsersPageDto> search(String? search, PageRequest page);

  Future<List<RetailRoleDto>> retailRoles();

  Future<AddedRetailUserDto> add(Map<String, Object?> body);

  Future<void> emailNewFirstPassword(String id);
}

class DioRetailUserApiService implements RetailUserApiService {
  DioRetailUserApiService(this._api);

  final ApiClient _api;

  @override
  Future<RetailUsersPageDto> search(String? search, PageRequest page) async {
    final data = await _api.get(
      'retail-users',
      query: {'search': search, 'limit': page.limit, 'cursor': page.cursor},
    );
    if (data is! Map<String, dynamic>) {
      throw const InternalErrorException(message: 'retail_users_shape');
    }
    return RetailUsersPageDto.fromJson(data);
  }

  @override
  Future<List<RetailRoleDto>> retailRoles() async {
    // `data` is the list itself (app API guide §7.2).
    final data = await _api.get('retail-roles');
    if (data is! List) {
      throw const InternalErrorException(message: 'retail_roles_shape');
    }
    return [
      for (final r in data.cast<Map<String, dynamic>>())
        RetailRoleDto.fromJson(r),
    ];
  }

  @override
  Future<AddedRetailUserDto> add(Map<String, Object?> body) async {
    final data = await _api.post('retail-users', body: body);
    if (data is! Map<String, dynamic>) {
      throw const InternalErrorException(message: 'retail_user_shape');
    }
    return AddedRetailUserDto.fromJson(data);
  }

  @override
  Future<void> emailNewFirstPassword(String id) =>
      _api.post('retail-users/${Uri.encodeComponent(id)}/password');
}
