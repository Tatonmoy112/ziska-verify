import 'package:json_annotation/json_annotation.dart';

part 'auth_dtos.g.dart';

/// `auth/login`, `auth/verify-phone` → `data` (app API guide §3.1, §3.2).
/// `status` is `logged_in` or `code_sent`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LoginResponseDto {
  const LoginResponseDto({
    required this.status,
    this.challengeId,
    this.accessToken,
    this.refreshToken,
    this.mustChangePassword,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  final String status;
  final String? challengeId;
  final String? accessToken;
  final String? refreshToken;
  final bool? mustChangePassword;
}

/// `me/password` → `data` (app API guide §3.6). The refresh pass stays.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PasswordChangeResponseDto {
  const PasswordChangeResponseDto({
    required this.accessToken,
    required this.mustChangePassword,
  });

  factory PasswordChangeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeResponseDtoFromJson(json);

  final String accessToken;
  final bool mustChangePassword;
}
