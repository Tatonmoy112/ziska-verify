import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The logged-in official (`GET me`, final.md Section 13.7).
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required String email,
    required String role,
    required Set<String> permissions,
    required bool mustChangePassword,

    /// With [mustChangePassword]: the official may choose **Not now**.
    @Default(false) bool passwordChangeSkippable,

    /// The password is still the one someone else set: Profile shows a
    /// reminder (final.md Section 13.7).
    @Default(false) bool passwordChangePending,
    String? organisation,
    String? supportEmail,
    String? supportPhone,
  }) = _Profile;

  const Profile._();

  bool can(String permission) => permissions.contains(permission);
}
