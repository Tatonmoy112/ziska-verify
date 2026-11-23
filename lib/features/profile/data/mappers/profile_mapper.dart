import 'package:ziska_verify/features/profile/data/models/profile_dto.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

extension ProfileMapper on ProfileDto {
  /// Text the server sends empty or as spaces counts as not set, never as a
  /// blank row (test-server integration, step 3); a blank name gives way to
  /// the email, so a screen never greets nobody.
  Profile toEntity() => Profile(
    id: id,
    name: _text(name) ?? email.trim(),
    email: email,
    role: role,
    permissions: permissions.toSet(),
    mustChangePassword: mustChangePassword,
    organisation: _text(organisation),
    supportEmail: _text(support?.email),
    supportPhone: _text(support?.phone),
  );
}

/// [value] without surrounding spaces; `null` when nothing is left.
String? _text(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}
