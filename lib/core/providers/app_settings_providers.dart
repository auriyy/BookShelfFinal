import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/shared_prefs_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefsService = ref.watch(sharedPrefsServiceProvider);
  return LocaleNotifier(prefsService);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPrefsService _prefsService;

  LocaleNotifier(this._prefsService) : super(Locale(_prefsService.getLocale()));

  Future<void> changeLanguage(String langCode) async {
    if (state.languageCode == langCode) return;
    state = Locale(langCode);
    await _prefsService.saveLocale(langCode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefsService = ref.watch(sharedPrefsServiceProvider);
  return ThemeModeNotifier(prefsService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPrefsService _prefsService;

  ThemeModeNotifier(this._prefsService) : super(_parseTheme(_prefsService.getThemeMode()));

  static ThemeMode _parseTheme(String themeStr) {
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _prefsService.saveThemeMode(mode.name);
  }
}

final lastSearchQueryProvider = StateNotifierProvider<LastSearchNotifier, String>((ref) {
  final prefsService = ref.watch(sharedPrefsServiceProvider);
  return LastSearchNotifier(prefsService);
});

class LastSearchNotifier extends StateNotifier<String> {
  final SharedPrefsService _prefsService;

  LastSearchNotifier(this._prefsService) : super(_prefsService.getLastSearchQuery());

  Future<void> updateSearchQuery(String query) async {
    if (state == query) return;
    state = query;
    await _prefsService.saveLastSearchQuery(query);
  }
}