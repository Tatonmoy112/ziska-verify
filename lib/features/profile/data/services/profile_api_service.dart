import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/profile/data/models/profile_dto.dart';

/// `GET me` (final.md Section 5.7).
abstract interface class ProfileApiService {
  Future<ProfileDto> getMe();
}

class DioProfileApiService implements ProfileApiService {
  DioProfileApiService(this._api);

  final ApiClient _api;

  @override
  Future<ProfileDto> getMe() async {
    final data = await _api.get('me');
    if (data is! Map<String, dynamic>) {
      throw const InternalErrorException(message: 'me_shape');
    }
    return ProfileDto.fromJson(data);
  }
}
