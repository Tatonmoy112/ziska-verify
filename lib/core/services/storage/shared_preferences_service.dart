import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziska_verify/core/services/storage/preferences_service.dart';

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
