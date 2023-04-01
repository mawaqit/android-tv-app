import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _announcementsStoreKey = 'UserPreferencesManager.AnnouncementsOnly';

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
}
