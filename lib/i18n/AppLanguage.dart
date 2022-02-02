import 'package:flutter/material.dart';
import 'package:flyweb/src/data/config.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en', '');

  String get currentLanguageName {
    final currentLang = Config.language.firstWhere(
      (element) => element['value'] == _appLocale.languageCode,
    );

    return currentLang['subtitle'];
  }

  Locale get appLocal => _appLocale ?? Locale('en', '');

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale =
          Locale('${GlobalConfiguration().getValue('defaultLanguage')}', '');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("es", "")) {
      _appLocale = Locale("es", "");
      await prefs.setString('language_code', 'es');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("fr", "")) {
      _appLocale = Locale("fr", "");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', 'FR');
    } else if (type == Locale("ar", "")) {
      _appLocale = Locale("ar", "");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', 'AR');
    } else if (type == Locale("pt", "")) {
      _appLocale = Locale("pt", "");
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', 'PT');
    } else if (type == Locale("hi", "")) {
      _appLocale = Locale("hi", "");
      await prefs.setString('language_code', 'hi');
      await prefs.setString('countryCode', 'HI');
    } else if (type == Locale("de", "")) {
      _appLocale = Locale("de", "");
      await prefs.setString('language_code', 'de');
      await prefs.setString('countryCode', 'DE');
    } else if (type == Locale("it", "")) {
      _appLocale = Locale("it", "");
      await prefs.setString('language_code', 'it');
      await prefs.setString('countryCode', 'IT');
    } else if (type == Locale("tr", "")) {
      _appLocale = Locale("tr", "");
      await prefs.setString('language_code', 'tr');
      await prefs.setString('countryCode', 'TR');
    } else if (type == Locale("ru", "")) {
      _appLocale = Locale("ru", "");
      await prefs.setString('language_code', 'ru');
      await prefs.setString('countryCode', 'RU');
    } else {
      _appLocale = Locale("en", "");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }
}
