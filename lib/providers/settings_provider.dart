import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  final SharedPreferences _prefs;

  String _selectedLanguage = 'en'; // Default to English

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  String get selectedLanguage => _selectedLanguage;

  Future<void> _loadSettings() async {
    _selectedLanguage = _prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_selectedLanguage != languageCode) {
      _selectedLanguage = languageCode;
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  // Helper method to get language name from code
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      default:
        return 'English';
    }
  }
}
