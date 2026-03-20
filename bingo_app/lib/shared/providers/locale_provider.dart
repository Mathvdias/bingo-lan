import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    _saveToPrefs(newLocale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    _saveToPrefs(null);
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs(String? localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (localeCode == null) {
      prefs.remove(_localeKey);
    } else {
      prefs.setString(_localeKey, localeCode);
    }
  }
}
