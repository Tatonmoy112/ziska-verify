import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/models/retail_user_dtos.dart';

/// Retail user routes (final.md §15, §13.6).
abstract interface class RetailUserApiService {
  Future<RetailUsersPageDto> search(String? search, PageRequest page);
}

class DioRetailUserApiService implements RetailUserApiService {
  DioRetailUserApiService(this._api);

  final ApiClient _api;

  @override
  Future<RetailUsersPageDto> search(String? search, PageRequest page) async {
    final data = await _api.get(
      ApiRoutes.retailUsers,
      query: {'search': search, 'limit': page.limit, 'cursor': page.cursor},
    );
    return RetailUsersPageDto.fromJson(
      ApiData.map(data, ApiAnswer.retailUsers),
    );
  }
}
