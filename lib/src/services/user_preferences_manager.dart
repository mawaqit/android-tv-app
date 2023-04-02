import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _announcementsStoreKey = 'UserPreferencesManager.AnnouncementsOnly';
const _developerModeKey = 'UserPreferencesManager.developer.mode.enabled';
const _secondaryScreenKey = 'UserPreferencesManager.secondary.screen.enabled';
const _webViewModeKey = 'UserPreferencesManager.webView.mode.enabled';

/// this manager responsible for managing user preferences
class UserPreferencesManager extends ChangeNotifier {
  UserPreferencesManager() {
    SharedPreferences.getInstance().then((value) => _sharedPref = value);
  }

  late SharedPreferences _sharedPref;

  bool get announcementsOnly => _sharedPref.getBool(_announcementsStoreKey) ?? false;

  set announcementsOnly(bool value) {
    _sharedPref.setBool(_announcementsStoreKey, value);
    notifyListeners();
  }

  bool get developerModeEnabled => _sharedPref.getBool(_developerModeKey) ?? false;

  set developerModeEnabled(bool value) {
    _sharedPref.setBool(_developerModeKey, value);
    notifyListeners();
  }

  bool get isSecondaryScreen => _sharedPref.getBool(_secondaryScreenKey) ?? false;

  set isSecondaryScreen(bool value) {
    _sharedPref.setBool(_secondaryScreenKey, value);
    notifyListeners();
  }

  bool get webViewMode => _sharedPref.getBool(_webViewModeKey) ?? false;

  set webViewMode(bool value) {
    _sharedPref.setBool(_webViewModeKey, value);
    notifyListeners();
  }
}
