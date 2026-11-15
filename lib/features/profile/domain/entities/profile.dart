import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The logged-in official (`GET me`, final.md Section 13.8).
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required String email,
    required String role,
    required Set<String> permissions,
    required bool mustChangePassword,
    String? organisation,
    String? supportEmail,
    String? supportPhone,
  }) = _Profile;

  const Profile._();

  bool can(String permission) => permissions.contains(permission);
}
