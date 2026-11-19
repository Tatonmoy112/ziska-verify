import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';

class SearchRetailUsers {
  const SearchRetailUsers(this._repository);
  final RetailUserRepository _repository;

  /// The API takes at most 100 characters.
  static const maxSearchLength = 100;

  Future<Result<CursorPage<RetailUser>>> call(
    String? search,
    PageRequest page,
  ) {
    final text = search?.trim();
    return _repository.search(
      text == null || text.isEmpty
          ? null
          : text.substring(0, text.length.clamp(0, maxSearchLength)),
      page,
    );
  }
}
