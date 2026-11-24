import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  /// Loads the profile. When it says `must_change_password`, the session
  /// moves to the forced password change (final.md §6).
  Future<Result<Profile>> getProfile();
}
