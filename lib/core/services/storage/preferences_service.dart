import 'package:shared_preferences/shared_preferences.dart';

/// The phone's own settings, kept outside the login: they stay after a
/// logout (final.md Section 12.1). Nothing secret is kept here.
abstract interface class PreferencesService {
  /// The chosen app language (`en` or `bn`); `null` before any choice.
  Future<String?> languageCode();

  Future<void> setLanguageCode(String code);
}

/// [PreferencesService] on `shared_preferences`.
class SharedPreferencesService implements PreferencesService {
  SharedPreferencesService([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _language = 'language';

  @override
  Future<String?> languageCode() => _preferences.getString(_language);

  @override
  Future<void> setLanguageCode(String code) =>
      _preferences.setString(_language, code);
}
