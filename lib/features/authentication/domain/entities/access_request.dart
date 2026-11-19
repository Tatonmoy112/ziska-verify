class RequestableRole {
  const RequestableRole({required this.id, required this.name});
  final int id;
  final String name;
}

class AccessRequest {
  const AccessRequest({
    required this.email,
    required this.code,
    required this.name,
    required this.roleId,
    required this.password,
  });
  final String email;
  final String code;
  final String name;
  final int roleId;
  final String password;
}
