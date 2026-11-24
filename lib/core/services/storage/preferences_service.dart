/// The phone's own settings, kept outside the login: they stay after a
/// logout (final.md Section 12.1). Nothing secret is kept here.
abstract interface class PreferencesService {
  /// The chosen app language (`en` or `bn`); `null` before any choice.
  Future<String?> languageCode();

  Future<void> setLanguageCode(String code);
}
