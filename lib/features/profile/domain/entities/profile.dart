import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// What a role allows (final.md §7; backend D61, SRS 4.2). The only place
/// the keys of `GET me` are written: everything else reads these values.
enum Permission {
  /// One item, by serial or QR.
  lookup('item:lookup'),

  /// Scanner mode and serial stacks.
  bulkLookup('item:bulk_lookup'),

  /// Own checks, own sessions, the Profile counts.
  ownHistory('history:own'),

  /// Incident reports, their photos, the retail picker.
  report('incident:report')
  ;

  const Permission(this.key);

  /// The key exactly as the backend sends it.
  final String key;

  /// The permission [key] names, or `null`: a key the app does not know,
  /// a withdrawn one (`history:all`, `retail_user:add`) or one not written
  /// exactly as the backend writes it grants nothing (§7).
  static Permission? fromKey(String key) => _byKey[key];

  static final Map<String, Permission> _byKey = {
    for (final p in values) p.key: p,
  };
}

/// The logged-in official (`GET me`, final.md §13.7).
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required String email,
    required String role,
    required Set<Permission> permissions,
    required bool mustChangePassword,
    String? organisation,
    String? supportEmail,
    String? supportPhone,
  }) = _Profile;

  const Profile._();

  bool can(Permission permission) => permissions.contains(permission);

  bool get canLookup => can(Permission.lookup);
  bool get canBulkLookup => can(Permission.bulkLookup);
  bool get canReport => can(Permission.report);
}
