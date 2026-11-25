import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_request.freezed.dart';

@freezed
abstract class RequestableRole with _$RequestableRole {
  const factory RequestableRole({required int id, required String name}) =
      _RequestableRole;
}

@freezed
abstract class AccessRequest with _$AccessRequest {
  const factory AccessRequest({
    required String email,
    required String code,
    required String name,
    required int roleId,
    required String password,
  }) = _AccessRequest;

  const AccessRequest._();

  /// A name is 1 to 100 characters (guide section 3.9), counted in UTF-16
  /// units as the test server counts them (2026-11-22, backend question B5).
  static const nameMaxLength = 100;

  /// Never the email, the emailed code or the password: a request printed
  /// in a log or an error stays safe (AGENTS.md; final.md §12).
  @override
  String toString() => 'AccessRequest(name: $name, roleId: $roleId)';
}
