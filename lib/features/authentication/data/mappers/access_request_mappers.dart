import 'package:ziska_verify/features/authentication/data/models/access_request_dtos.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';

extension RequestableRoleMapper on RequestableRoleDto {
  RequestableRole toEntity() => RequestableRole(id: id, name: name);
}

extension RequestableRolesMapper on List<RequestableRoleDto> {
  /// In the server's order, repeats kept.
  List<RequestableRole> toEntities() => [for (final r in this) r.toEntity()];
}
