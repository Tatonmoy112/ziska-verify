import 'package:ziska_verify/features/profile/data/models/profile_dto.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

extension ProfileMapper on ProfileDto {
  Profile toEntity() => Profile(
    id: id,
    name: name,
    email: email,
    role: role,
    permissions: permissions.toSet(),
    mustChangePassword: mustChangePassword,
    passwordChangeSkippable: passwordChangeSkippable ?? false,
    passwordChangePending: passwordChangePending ?? false,
    organisation: organisation,
    supportEmail: support?.email,
    supportPhone: support?.phone,
  );
}
