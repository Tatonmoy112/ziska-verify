import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/features/retail_users/data/models/retail_user_dtos.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';

extension RetailUsersPageMapper on RetailUsersPageDto {
  CursorPage<RetailUser> toEntity() => CursorPage(
    items: [for (final u in retailUsers) u.toEntity()],
    nextCursor: nextCursor,
  );
}

extension RetailUserMapper on RetailUserDto {
  /// The email stays as the server masked it; the app never shows more
  /// (final.md §12).
  RetailUser toEntity() => RetailUser(id: id, name: name, maskedEmail: email);
}
