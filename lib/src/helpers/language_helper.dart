class LanguageHelper {

  /// [mapLocaleWithQuran] is a helper function that maps the locale to the Quran API locale.
  ///
  /// using this api `https://mp3quran.net/api/v3/languages`
  static String mapLocaleWithQuran(String locale) {
    switch (locale) {
      case 'ar':
        return 'ar';
      case 'ba':
        return 'bs';
      case 'bg':
        return 'bg';
      case 'bn':
        return 'bn';
      case 'ca':
        return 'ca';
      case 'cs':
        return 'cs';
      case 'da':
        return 'da';
      case 'de':
        return 'de';
      case 'el':
        return 'el';
      case 'en':
        return 'eng';
      case 'es':
        return 'es';
      case 'et':
        return 'et';
      case 'fi':
        return 'fi';
      case 'fr':
        return 'fr';
      case 'he':
        return 'he';
      case 'hr':
        return 'hr';
      case 'hu':
        return 'hu';
      case 'id':
        return 'id';
      case 'it':
        return 'it';
      case 'ja':
        return 'ja';
      case 'ko':
        return 'ko';
      case 'lt':
        return 'lt';
      case 'lv':
        return 'lv';
      case 'nl':
        return 'nl';
      case 'no':
        return 'no';
      case 'pl':
        return 'pl';
      case 'pt':
        return 'pt';
      case 'ro':
        return 'ro';
      case 'ru':
        return 'ru';
      case 'sl':
        return 'sl';
      case 'sv':
        return 'sv';
      case 'ta':
        return 'ta';
      case 'tr':
        return 'tr';
      case 'uk':
        return 'uk';
      case 'ur':
        return 'ur';
      case 'zh':
        return 'cn';
      default:
        return 'eng';
    }
  }
}
