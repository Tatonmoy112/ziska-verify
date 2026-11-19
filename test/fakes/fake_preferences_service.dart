import 'package:ziska_verify/core/services/storage/preferences_service.dart';

/// The phone's preferences, in memory; pass the same one to a second
/// `startApp` to restart with the choices kept.
class FakePreferencesService implements PreferencesService {
  FakePreferencesService({this.language});

  String? language;

  /// Set to make reads and saves fail.
  Exception? failure;

  @override
  Future<String?> languageCode() async {
    if (failure != null) throw failure!;
    return language;
  }

  @override
  Future<void> setLanguageCode(String code) async {
    if (failure != null) throw failure!;
    language = code;
  }
}
