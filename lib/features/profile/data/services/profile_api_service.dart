import 'package:ziska_verify/core/errors/failure_reason.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/core/network/api_data.dart';
import 'package:ziska_verify/core/network/api_routes.dart';
import 'package:ziska_verify/features/profile/data/models/profile_dtos.dart';

/// `GET me` (final.md §15).
abstract interface class ProfileApiService {
  Future<ProfileDto> getMe();
}

class DioProfileApiService implements ProfileApiService {
  DioProfileApiService(this._api);

  final ApiClient _api;

  @override
  Future<ProfileDto> getMe() async {
    final data = await _api.get(ApiRoutes.me);
    return ProfileDto.fromJson(ApiData.map(data, ApiAnswer.me));
  }
}
