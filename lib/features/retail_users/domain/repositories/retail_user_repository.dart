import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';

abstract interface class RetailUserRepository {
  /// `GET retail-users`: active retail users by name; [search] is part of a
  /// name or a whole email, up to 100 characters (final.md Section 13.6).
  Future<Result<CursorPage<RetailUser>>> search(
    String? search,
    PageRequest page,
  );
}
