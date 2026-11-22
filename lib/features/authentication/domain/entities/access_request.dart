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

  /// A name is 1 to 100 characters (guide section 3.9), counted in UTF-16
  /// units as the test server counts them (2026-11-22, backend question B5).
  static const nameMaxLength = 100;

  final String email;
  final String code;
  final String name;
  final int roleId;
  final String password;
}
