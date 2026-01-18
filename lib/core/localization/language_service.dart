import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language.dart';
import 'app_strings.dart';

class LanguageService {
  static const _key = 'app_language';

  static AppLanguage selectedLanguage = AppLanguage.hu;

  static final ValueNotifier<AppLanguage> notifier = ValueNotifier<AppLanguage>(
    selectedLanguage,
  );

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);

    if (code != null) {
      selectedLanguage = AppLanguage.values.firstWhere((l) => l.code == code);
    }

    notifier.value = selectedLanguage;
    AppStrings.setLanguage(selectedLanguage);
  }

  static Future<void> saveLanguage(AppLanguage lang) async {
    selectedLanguage = lang;
    notifier.value = lang;
    AppStrings.setLanguage(lang);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang.code);
  }
}
