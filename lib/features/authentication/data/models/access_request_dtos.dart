import 'package:json_annotation/json_annotation.dart';

part 'access_request_dtos.g.dart';

@JsonSerializable(createToJson: false)
class RequestableRoleDto {
  const RequestableRoleDto({required this.id, required this.name});
  factory RequestableRoleDto.fromJson(Map<String, dynamic> json) =>
      _$RequestableRoleDtoFromJson(json);
  final int id;
  final String name;
}
