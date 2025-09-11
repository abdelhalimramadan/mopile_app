import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// In lib/services/language_service.dart
class LanguageService with ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageService() {
    loadSavedLanguage();  // Changed from _loadSavedLanguage to loadSavedLanguage
  }

  // Changed from _loadSavedLanguage to loadSavedLanguage (public)
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    
    _locale = locale;
    notifyListeners();
  }

  bool isRTL() {
    return _locale.languageCode == 'ar';
  }
// ... rest of the class remains the same
}
