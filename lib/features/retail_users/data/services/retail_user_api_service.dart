import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/models/retail_user_dtos.dart';

/// Retail user routes (final.md Sections 5.7, 13.6).
abstract interface class RetailUserApiService {
  Future<RetailUsersPageDto> search(String? search, PageRequest page);
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
}
