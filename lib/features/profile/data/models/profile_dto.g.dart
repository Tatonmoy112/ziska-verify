// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  mustChangePassword: json['must_change_password'] as bool,
  organisation: json['organisation'] as String?,
  support: json['support'] == null
      ? null
      : SupportDto.fromJson(json['support'] as Map<String, dynamic>),
);

SupportDto _$SupportDtoFromJson(Map<String, dynamic> json) => SupportDto(
  email: json['email'] as String?,
  phone: json['phone'] as String?,
);
