import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _announcementsStoreKey = 'UserPreferencesManager.AnnouncementsOnly';
const _developerModeKey = 'UserPreferencesManager.developer.mode.enabled';

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
}
