import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/storage/preferences_service.dart';

/// The app language (final.md Section 16): English or Bangla, chosen on
/// Profile, applied at once, and kept on the phone across restarts and
/// logouts. English until a choice is made.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._preferences, this._logger, {Locale initial = english})
    : super(initial);

  static const english = Locale('en');
  static const bangla = Locale('bn');
  static const List<Locale> supported = [english, bangla];

  final PreferencesService _preferences;
  final LoggerService _logger;

  /// The stored choice; English when none was made or it cannot be read.
  static Future<Locale> stored(
    PreferencesService preferences,
    LoggerService logger,
  ) async {
    try {
      final code = await preferences.languageCode();
      return supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => english,
      );
    } on Object catch (e) {
      logger.warning('language not read: ${e.runtimeType}');
      return english;
    }
  }

  /// Applies [locale] at once and keeps it. A failed save keeps the change
  /// for this run.
  Future<void> choose(Locale locale) async {
    if (!supported.contains(locale) || locale == state) return;
    emit(locale);
    try {
      await _preferences.setLanguageCode(locale.languageCode);
    } on Object catch (e) {
      _logger.warning('language not saved: ${e.runtimeType}');
    }
  }
}
