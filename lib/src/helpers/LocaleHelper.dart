import 'package:flutter/material.dart';

import '../../i18n/AppLanguage.dart';

/// A utility class for sorting a list of [Locale] objects.
///
/// This class provides static methods to sort locales based on specific language rules.
/// It supports sorting the locales such that 'ar' (Arabic) is always at the start,
/// 'ba' is excluded, and the rest are sorted alphabetically by their language names.
class LocaleHelper {
  /// [_customLocaleCompare] A private static method that defines the sorting logic.
  ///
  /// It ensures that:
  /// - 'ar' (Arabic) is always at the beginning.
  /// - 'ba' is excluded from the sorting.
  /// - Other locales are sorted alphabetically by their language names.
  static int _customLocaleCompare(Locale a, Locale b, Map<String, String> localeNames) {
    if (a.languageCode == 'ar') return -1;
    if (b.languageCode == 'ar') return 1;
    if (a.languageCode == 'ba') return 1;
    if (b.languageCode == 'ba') return -1;
    return localeNames[a.languageCode]!.compareTo(localeNames[b.languageCode]!);
  }

  /// [splitLocaleCode] Splits a combined language-country code string into a [Locale] object.
  static Locale splitLocaleCode(String localeCode) {
    var parts = localeCode.split('_');
    var languageCode = parts[0];
    var countryCode = parts.length > 1 ? parts[1] : null;

    return Locale(languageCode, countryCode);
  }

  /// [transformLocaleToString] Transforms a [Locale] to its standard string representation.
  ///
  /// Returns format: 'languageCode' or 'languageCode_COUNTRYCODE'
  /// Examples:
  /// - Locale('en') -> 'en'
  /// - Locale('en', 'US') -> 'en_US'
  /// - Locale('pt', 'BR') -> 'pt_BR'
  ///
  /// This is a better-named version of the original _transformLocale function.
  static String transformLocaleToString(Locale locale) {
    return '${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode!.toUpperCase()}' : ''}';
  }

  /// [getSortedLocales] Public static method to get a sorted list of locales according to the defined rules.
  static List<Locale> getSortedLocales(List<Locale> locales, AppLanguage appLanguage) {
    final localeNames = Map.fromEntries(
      locales.map(
        (locale) => MapEntry(
          locale.languageCode,
          appLanguage.languageName(locale.languageCode).toLowerCase(),
        ),
      ),
    );

    // Creating a new list from the original to avoid modifying it and sorting it.
    final sortedLocales = List<Locale>.from(locales)..sort((a, b) => _customLocaleCompare(a, b, localeNames));
    return sortedLocales;
  }
}
