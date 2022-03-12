import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/data/config.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en', '');

  String languageName(String languageCode) =>
      Config.language.firstWhere((element) => element['value'] == languageCode)['subtitle'] ?? '';

  String get currentLanguageName => languageName(_appLocale.languageCode);

  Locale get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('${GlobalConfiguration().getValue('defaultLanguage')}', '');
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

    if (S.delegate.supportedLocales.indexOf(type) != -1) {
      _appLocale = type;
      await prefs.setString('language_code', type.languageCode);
      await prefs.setString('countryCode', type.countryCode ?? '');
    }
    notifyListeners();
  }
}
