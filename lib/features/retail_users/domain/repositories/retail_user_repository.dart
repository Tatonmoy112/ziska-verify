import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user_admin.dart';

abstract interface class RetailUserRepository {
  /// `GET retail-users`: active retail users by name; [search] is part of a
  /// name or a whole email, up to 100 characters (final.md Section 13.6).
  Future<Result<CursorPage<RetailUser>>> search(
    String? search,
    PageRequest page,
  );

  /// `GET retail-roles`. An empty list means no retail user can be added
  /// yet.
  Future<Result<List<RetailRole>>> retailRoles();

  /// `POST retail-users` (final.md Section 13.6.1).
  Future<Result<AddedRetailUser>> add({
    required String name,
    required String email,
    required int roleId,
    required String password,
    required bool sendEmail,
  });

  /// `POST retail-users/{id}/password`: always emailed.
  Future<Result<void>> emailNewFirstPassword(String id);
}
