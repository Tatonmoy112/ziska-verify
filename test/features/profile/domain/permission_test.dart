import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/profile/data/mappers/profile_mappers.dart';
import 'package:ziska_verify/features/profile/data/models/profile_dtos.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

/// TC-ROLE-021 … -023 (docs/test-cases/03-roles-nav.md): the permissions
/// of `GET me` become typed [Permission]s at the data boundary; only the
/// four keys of the app grant anything (final.md §7; production audit P-4).
void main() {
  /// The profile `GET me` gives for [keys], through the real mapper.
  Profile profileWith(List<String> keys) => ProfileDto(
    id: '1',
    name: 'Asha Rao',
    email: 'asha@example.com',
    role: 'Field inspector',
    permissions: keys,
    mustChangePassword: false,
  ).toEntity();

  ({bool lookup, bool bulk, bool history, bool report}) can(Profile p) => (
    lookup: p.canLookup,
    bulk: p.canBulkLookup,
    // The app checks the key itself (the routes and the History tab).
    history: p.permissions.contains(Permission.ownHistory),
    report: p.canReport,
  );

  const nothing = (lookup: false, bulk: false, history: false, report: false);

  group('TC-ROLE-021 normal: each key grants its one capability', () {
    test('the four keys, as the backend writes them', () {
      expect(Permission.values.map((p) => p.key), [
        'item:lookup',
        'item:bulk_lookup',
        'history:own',
        'incident:report',
      ]);
    });

    for (final (key, permission, expected) in [
      (
        'item:lookup',
        Permission.lookup,
        (lookup: true, bulk: false, history: false, report: false),
      ),
      (
        'item:bulk_lookup',
        Permission.bulkLookup,
        (lookup: false, bulk: true, history: false, report: false),
      ),
      (
        'history:own',
        Permission.ownHistory,
        (lookup: false, bulk: false, history: true, report: false),
      ),
      (
        'incident:report',
        Permission.report,
        (lookup: false, bulk: false, history: false, report: true),
      ),
    ]) {
      test(key, () {
        expect(Permission.fromKey(key), permission);
        final profile = profileWith([key]);
        expect(profile.permissions, {permission});
        expect(profile.can(permission), isTrue);
        expect(can(profile), expected);
      });
    }

    test('all four together: everything', () {
      final profile = profileWith(Permission.values.map((p) => p.key).toList());
      expect(profile.permissions, Permission.values.toSet());
      expect(
        can(profile),
        (lookup: true, bulk: true, history: true, report: true),
      );
    });
  });

  group('TC-ROLE-022 edge: an empty or withdrawn set grants nothing', () {
    test('no permission at all is valid: nothing', () {
      final profile = profileWith(const []);
      expect(profile.permissions, isEmpty);
      expect(can(profile), nothing);
    });

    test('history:all and retail_user:add are withdrawn: nothing', () {
      final profile = profileWith(const ['history:all', 'retail_user:add']);
      expect(profile.permissions, isEmpty);
      expect(can(profile), nothing);
    });

    test('a key sent twice is one permission', () {
      final profile = profileWith(const ['history:own', 'history:own']);
      expect(profile.permissions, {Permission.ownHistory});
    });

    test('a bulk-only role can scan many but not one, nor read history', () {
      expect(
        can(profileWith(const ['item:bulk_lookup'])),
        (lookup: false, bulk: true, history: false, report: false),
      );
    });
  });

  group("TC-ROLE-023 worst: a key not exactly the backend's grants "
      'nothing', () {
    for (final key in [
      'ITEM:LOOKUP',
      'Item:Lookup',
      ' item:lookup',
      'item:lookup ',
      'item:lookup:extra',
      'item_lookup',
      'item:',
      ':lookup',
      '',
      'history:own\n',
      'item:lookup,history:own',
      'a-new-permission',
    ]) {
      test('"${key.replaceAll('\n', r'\n')}"', () {
        expect(Permission.fromKey(key), isNull);
        final profile = profileWith([key]);
        expect(profile.permissions, isEmpty);
        expect(can(profile), nothing);
      });
    }

    test('unknown keys beside a real one: only the real one', () {
      final profile = profileWith(const [
        'ITEM:LOOKUP',
        'incident:report',
        'retail_user:add',
        'x',
      ]);
      expect(profile.permissions, {Permission.report});
      expect(
        can(profile),
        (lookup: false, bulk: false, history: false, report: true),
      );
    });
  });
}
