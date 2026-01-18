enum AppLanguage {
  hu,
  en,
}

extension AppLanguageExt on AppLanguage {
  String get code => name; // "hu" | "en"
}
