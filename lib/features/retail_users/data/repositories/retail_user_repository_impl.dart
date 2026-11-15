import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/data/services/retail_user_api_service.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user_admin.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';

class RetailUserRepositoryImpl implements RetailUserRepository {
  RetailUserRepositoryImpl(this._api);

  final RetailUserApiService _api;

  @override
  Future<Result<CursorPage<RetailUser>>> search(
    String? search,
    PageRequest page,
  ) => guard(() async {
    final dto = await _api.search(search, page);
    return CursorPage(
      items: [
        for (final u in dto.retailUsers)
          RetailUser(id: u.id, name: u.name, maskedEmail: u.email),
      ],
      nextCursor: dto.nextCursor,
    );
  });

  @override
  Future<Result<List<RetailRole>>> retailRoles() => guard(
    () async => [
      for (final r in await _api.retailRoles())
        RetailRole(id: r.id, name: r.name),
    ],
  );

  @override
  Future<Result<AddedRetailUser>> add({
    required String name,
    required String email,
    required int roleId,
    required String password,
    required bool sendEmail,
  }) => guard(() async {
    final dto = await _api.add({
      'name': name,
      'email': email,
      'role_id': roleId,
      'password': password,
      'send_email': sendEmail,
    });
    return AddedRetailUser(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      emailOutcome: switch (dto.emailSent) {
        true => EmailOutcome.sent,
        false => EmailOutcome.failed,
        null => EmailOutcome.notRequested,
      },
    );
  });

  @override
  Future<Result<void>> emailNewFirstPassword(String id) =>
      guard(() => _api.emailNewFirstPassword(id));
}
