class RandomHadithHelper {
  static String changeLanguageFormat(String language) {
    return language.replaceAll('_', '-');
  }

  static bool isTwoLanguage(String language) {
    // Check if the language is in the format of 'language1-language2' or 'language1_language2'.
    return language.contains('-') || language.contains('_');
  }

  static List<String> getLanguage(String language) {
    return language.split(RegExp(r'[-_]'));
  }
}
