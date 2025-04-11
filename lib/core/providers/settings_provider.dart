import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language {
  english('English'),
  hindi('हिंदी'),
  marathi('मराठी');

  final String name;
  const Language(this.name);
}

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  SettingsProvider(this._prefs);

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;

  Language get currentLanguage {
    final languageCode = _prefs.getString(_languageKey) ?? 'english';
    return Language.values.firstWhere(
      (lang) => lang.name.toLowerCase() == languageCode,
      orElse: () => Language.english,
    );
  }

  Future<void> toggleTheme() async {
    final newValue = !isDarkMode;
    await _prefs.setBool(_themeKey, newValue);
    notifyListeners();
  }

  Future<void> setLanguage(Language language) async {
    await _prefs.setString(_languageKey, language.name.toLowerCase());
    notifyListeners();
  }

  Future<void> logout() async {
    // TODO: Implement actual logout logic (clear tokens, etc.)
    await Future.delayed(const Duration(seconds: 1));
  }
}
