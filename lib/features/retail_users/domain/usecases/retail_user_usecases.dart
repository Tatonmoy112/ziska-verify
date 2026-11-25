import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/core/utils/text_limits.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';

class SearchRetailUsers {
  const SearchRetailUsers(this._repository);
  final RetailUserRepository _repository;

  /// The API takes at most 100 characters (guide section 7.1). The test
  /// server counts them in UTF-16 units, an emoji as two (2026-11-22,
  /// backend question B5).
  static const maxSearchLength = 100;

  Future<Result<CursorPage<RetailUser>>> call(
    String? search,
    PageRequest page,
  ) {
    final text = search?.trim();
    return _repository.search(
      text == null || text.isEmpty
          ? null
          : TextLimits.fitUtf16(text, maxSearchLength),
      page,
    );
  }
}
