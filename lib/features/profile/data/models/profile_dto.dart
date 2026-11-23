import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

/// `GET me` → `data` (app API guide §3.8). Unknown fields are ignored.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.mustChangePassword,
    this.organisation,
    this.support,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  final String id;
  final String name;
  final String email;
  final String role;

  /// Missing or `null` reads as no permission at all: the official sees no
  /// feature rather than a crash (final.md Sections 7.2, 13.1.5).
  @JsonKey(defaultValue: <String>[])
  final List<String> permissions;
  final bool mustChangePassword;
  final String? organisation;
  final SupportDto? support;
}

@JsonSerializable(createToJson: false)
class SupportDto {
  const SupportDto({this.email, this.phone});

  factory SupportDto.fromJson(Map<String, dynamic> json) =>
      _$SupportDtoFromJson(json);

  final String? email;
  final String? phone;
}
