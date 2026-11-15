/// The 7 role profiles of `docs/USER.md`, as `GET me` → `data`
/// (test plan Section 7).
abstract final class Roles {
  static Map<String, dynamic> _profile(
    String id,
    String name,
    String email,
    String role,
    List<String> permissions, {
    Map<String, dynamic>? support,
  }) => {
    'id': '5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e$id',
    'name': name,
    'email': email,
    'role': role,
    'permissions': permissions,
    'organisation': 'Ziska Pharma',
    'support':
        support ?? {'email': 'help@ziska.example', 'phone': '+91 80 0000 0000'},
    'must_change_password': false,
  };

  static final Map<String, dynamic> supervisor = _profile(
    '01',
    'Karim Supervisor',
    'supervisor@example.com',
    'Supervisor',
    [
      'history:all',
      'history:own',
      'incident:report',
      'item:bulk_lookup',
      'item:lookup',
      'retail_user:add',
    ],
  );

  static final Map<String, dynamic> fieldInspector = _profile(
    '6f',
    'Asha Rao',
    'official@example.com',
    'Field inspector',
    ['history:own', 'incident:report', 'item:bulk_lookup', 'item:lookup'],
  );

  static final Map<String, dynamic> auditor = _profile(
    '03',
    'Nusrat Auditor',
    'auditor@example.com',
    'Head office auditor',
    ['history:all', 'history:own', 'item:lookup'],
  );

  static final Map<String, dynamic> seniorSeller = _profile(
    '04',
    'Hasan Pharmacy',
    'hasan.pharmacy@example.com',
    'Senior seller',
    ['history:own', 'item:bulk_lookup', 'item:lookup'],
  );

  /// A retail role as the portal makes it by default (backend D53).
  static final Map<String, dynamic> retailSeller = _profile(
    '05',
    'Rahim Store',
    'rahim.store@example.com',
    'Retail seller',
    ['history:own', 'item:lookup'],
  );

  /// A retail role whose admin turned history off.
  static final Map<String, dynamic> retailSellerNoHistory = _profile(
    '09',
    'Karim Store',
    'karim.store@example.com',
    'Retail seller (no history)',
    ['item:lookup'],
  );

  static final Map<String, dynamic> incidentReporter = _profile(
    '06',
    'Field Reporter',
    'reporter@example.com',
    'Incident reporter',
    ['incident:report'],
  );

  static final Map<String, dynamic> trainee = _profile(
    '07',
    'New Trainee',
    'trainee@example.com',
    'Trainee',
    [],
  );

  /// A profile whose office set no support contact.
  static final Map<String, dynamic> noSupport = _profile(
    '08',
    'Asha Rao',
    'official@example.com',
    'Field inspector',
    ['item:lookup'],
    support: {'email': null, 'phone': null},
  );

  /// A made-up role with exactly [permissions], for the pairwise and edge
  /// cases (docs/test-cases/03-roles-nav.md).
  static Map<String, dynamic> only(List<String> permissions) =>
      _profile('99', 'Test Official', 'test@example.com', 'Test role', [
        ...permissions,
      ]);
}
