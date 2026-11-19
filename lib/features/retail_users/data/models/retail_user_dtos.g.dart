// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retail_user_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetailUsersPageDto _$RetailUsersPageDtoFromJson(Map<String, dynamic> json) =>
    RetailUsersPageDto(
      retailUsers: (json['retail_users'] as List<dynamic>)
          .map((e) => RetailUserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

RetailUserDto _$RetailUserDtoFromJson(Map<String, dynamic> json) =>
    RetailUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
