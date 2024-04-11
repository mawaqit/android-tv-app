
class RandomHadithHelper {
  static String changeLanguageFormat(String language) {
    return language.replaceAll('_', '-');
  }

  static bool isTwoLanguage(String language) {
    return language.contains('-');
  }

  static List<String> getLanguage(String language) {
    return language.split('-');
  }
}
