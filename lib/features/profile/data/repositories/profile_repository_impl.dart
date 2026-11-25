import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/features/profile/data/mappers/profile_mappers.dart';
import 'package:ziska_verify/features/profile/data/services/profile_api_service.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, this._session);

  final ProfileApiService _api;
  final SessionService _session;

  @override
  Future<Result<Profile>> getProfile() => guard(() async {
    final profile = (await _api.getMe()).toEntity();
    if (profile.mustChangePassword) _session.requirePasswordChange();
    return profile;
  });
}
