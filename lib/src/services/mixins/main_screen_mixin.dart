import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mainScreenKey = 'MainScreen.Value';

mixin MainScreenMixin on ChangeNotifier {
  bool _mainScreen = true;

  /// get is this mosque is set to main screen or not
  fetchMainScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getBool(_mainScreenKey);
    _mainScreen = value ?? _mainScreen;

    notifyListeners();
  }

  /// save the main screen value in shared preferences
  storeMainScreenValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_mainScreenKey, value);
  }

  /// get is this mosque is set to main screen or not
  bool get isMainScreen => _mainScreen;

  /// this setup the main screen for single mosque
  set isMainScreen(bool value) {
    _mainScreen = value;
    storeMainScreenValue(value);
    notifyListeners();
  }
}
