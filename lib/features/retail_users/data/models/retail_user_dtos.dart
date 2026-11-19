import 'package:json_annotation/json_annotation.dart';

part 'retail_user_dtos.g.dart';

/// `GET retail-users` → `data` (app API guide §7.1). The list key is
/// `retail_users`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class RetailUsersPageDto {
  const RetailUsersPageDto({required this.retailUsers, this.nextCursor});

  factory RetailUsersPageDto.fromJson(Map<String, dynamic> json) =>
      _$RetailUsersPageDtoFromJson(json);

  final List<RetailUserDto> retailUsers;
  final String? nextCursor;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class RetailUserDto {
  const RetailUserDto({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RetailUserDto.fromJson(Map<String, dynamic> json) =>
      _$RetailUserDtoFromJson(json);

  final String id;
  final String name;
  final String email;
}
