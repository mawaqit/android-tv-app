import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/config.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/LocaleHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../src/services/mosque_manager.dart';

/// [AppLanguage] is a class that handles the app language
/// It is a singleton class that can be accessed from anywhere in the app
class AppLanguage extends ChangeNotifier {
  static final AppLanguage _instance = AppLanguage._internal();

  factory AppLanguage() {
    return _instance;
  }

  AppLanguage._internal();

  /// [kHadithLanguage] key stored in the shared preference
  String _hadithLanguage = "";
  Locale _appLocale = Locale('en', '');

  String languageName(String languageCode) => Config.isoLang[languageCode]?['nativeName'] ?? languageCode;

  /// return the language name of the combined language
  /// Example: 'en-ar' will be 'English & Arabic'
  String combinedLanguageName(String languageCode) {
    // Handle special cases for Portuguese variants and other single locale codes with underscores
    if (Config.isoLang.containsKey(languageCode)) {
      return Config.isoLang[languageCode]?['nativeName'] ?? languageCode;
    }

    List<String> codes = languageCode.split('_');
    // Check if we have a combined language code
    if (codes.length == 2) {
      // Retrieve individual language names and combine them
      String firstLanguage = Config.isoLang[codes[0]]?['nativeName'] ?? codes[0];
      String secondLanguage = Config.isoLang[codes[1]]?['nativeName'] ?? codes[1];
      return '$firstLanguage & $secondLanguage';
    } else {
      // Return the language name
      return Config.isoLang[languageCode]?['nativeName'] ?? languageCode;
    }
  }

  String get currentLanguageName => languageName(_appLocale.languageCode);

  Locale get appLocal => _appLocale;

  static Future<String?> getCountryCode() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  Future<void> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale(GlobalConfiguration().getValue('defaultLanguage'), '');
      notifyListeners();
      return null;
    }
    _appLocale = LocaleHelper.splitLocaleCode(prefs.getString('language_code')!);
    notifyListeners();
  }

  void changeLanguage(Locale type, String? mosqueId) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }

    AnalyticsWrapper.changeLanguage(
      oldLanguage: languageName(_appLocale.languageCode),
      language: languageName(type.languageCode),
      mosqueId: mosqueId,
    );
    final service = FlutterBackgroundService();
    service.invoke(
      'updateLocalization',
      {'language_code': LocaleHelper.transformLocaleToString(type)},
    );
    if (S.supportedLocales.indexOf(type) != -1) {
      _appLocale = type;
      await prefs.setString('language_code', LocaleHelper.transformLocaleToString(type));
      await prefs.setString('countryCode', type.countryCode ?? '');
    }
    notifyListeners();
  }

  bool isArabic() {
    return _appLocale.languageCode == "ar" || _appLocale.languageCode == "ur";
  }

  Map<String, String Function(BuildContext)> hadithLocalizedLanguage = {
    'en': (context) => S.of(context).en,
    'fr': (context) => S.of(context).fr,
    'ar': (context) => S.of(context).ar,
    'tr': (context) => S.of(context).tr,
    'de': (context) => S.of(context).de,
    'es': (context) => S.of(context).es,
    'pt': (context) => S.of(context).pt,
    'nl': (context) => S.of(context).nl,
    'fr_ar': (context) => S.of(context).fr_ar,
    'en_ar': (context) => S.of(context).en_ar,
    'de_ar': (context) => S.of(context).de_ar,
    'ta_ar': (context) => S.of(context).ta_ar,
    'tr_ar': (context) => S.of(context).tr_ar,
    'es_ar': (context) => S.of(context).es_ar,
    'pt_ar': (context) => S.of(context).pt_ar,
    'nl_ar': (context) => S.of(context).nl_ar,
  };

  /// set the language of the hadith in shared preference
  Future<void> setHadithLanguage(String language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _hadithLanguage = language;
    await prefs.setString(RandomHadithConstant.kHadithLanguage, language);
    notifyListeners();
  }

  /// get the language of the hadith from shared preference
  /// if there is no language saved, return the api default language
  Future<String> getHadithLanguage(MosqueManager mosqueManager) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? hadithLanguage = prefs.getString(RandomHadithConstant.kHadithLanguage);
    if (hadithLanguage != null && hadithLanguage.isNotEmpty) {
      _hadithLanguage = hadithLanguage;
      notifyListeners();
      return hadithLanguage;
    } else {
      final fallbackLang = mosqueManager.mosqueConfig?.hadithLang ?? "ar";
      _hadithLanguage = fallbackLang;
      // Save the fallback language to shared preferences so it persists
      await prefs.setString(RandomHadithConstant.kHadithLanguage, fallbackLang);
      notifyListeners();
      return fallbackLang;
    }
  }

  /// getters for the hadith language
  String get hadithLanguage => _hadithLanguage;
}
