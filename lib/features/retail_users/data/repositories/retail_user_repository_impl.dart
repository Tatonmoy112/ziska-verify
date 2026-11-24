import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/mappers/retail_user_mappers.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';

class RetailUserRepositoryImpl implements RetailUserRepository {
  RetailUserRepositoryImpl(this._api);

  final RetailUserApiService _api;

  @override
  Future<Result<CursorPage<RetailUser>>> search(
    String? search,
    PageRequest page,
  ) => guard(() async => (await _api.search(search, page)).toEntity());
}
