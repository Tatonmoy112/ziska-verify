// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      status: json['status'] as String,
      challengeId: json['challenge_id'] as String?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      mustChangePassword: json['must_change_password'] as bool?,
    );

PasswordChangeResponseDto _$PasswordChangeResponseDtoFromJson(
  Map<String, dynamic> json,
) => PasswordChangeResponseDto(
  accessToken: json['access_token'] as String,
  mustChangePassword: json['must_change_password'] as bool,
);
