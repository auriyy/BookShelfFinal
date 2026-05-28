import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  throw UnimplementedError('warn');
});

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  static const _themeKey = 'app_theme_mode';
  static const _localeKey = 'app_locale';
  static const _lastSearchKey = 'app_last_search_query';

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
  }

  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'uk'; 
  }

  Future<void> saveLastSearchQuery(String query) async {
    await _prefs.setString(_lastSearchKey, query);
  }

  String getLastSearchQuery() {
    return _prefs.getString(_lastSearchKey) ?? '';
  }
}