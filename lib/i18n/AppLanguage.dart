import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/config.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en', '');

  String languageName(String languageCode) => Config.isoLang[languageCode]?['nativeName'] ?? languageCode;

  String get currentLanguageName => languageName(_appLocale.languageCode);

  Locale get appLocal => _appLocale;

  static Future<String?> getCountryCode() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  Future<void> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('${GlobalConfiguration().getValue('defaultLanguage')}', '');
      notifyListeners();
      return null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
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

    if (S.supportedLocales.indexOf(type) != -1) {
      _appLocale = type;
      await prefs.setString('language_code', type.languageCode);
      await prefs.setString('countryCode', type.countryCode ?? '');
    }
    notifyListeners();
  }

  bool isArabic() {
    return _appLocale.languageCode == "ar" || _appLocale.languageCode == "ur";
  }
}
