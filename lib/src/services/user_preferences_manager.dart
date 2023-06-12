import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _announcementsStoreKey = 'UserPreferencesManager.AnnouncementsOnly';
const _developerModeKey = 'UserPreferencesManager.developer.mode.enabled';
const _secondaryScreenKey = 'UserPreferencesManager.secondary.screen.enabled';
const _webViewModeKey = 'UserPreferencesManager.webView.mode.enabled';
const _forceStagingKey = 'UserPreferencesManager.api.settings.staging';
const _screenOrientation = 'UserPreferencesManager.screen.orientation';

/// this manager responsible for managing user preferences
class UserPreferencesManager extends ChangeNotifier {
  UserPreferencesManager() {
    _init();
  }

  Future<void> _init() async {
    _sharedPref = await SharedPreferences.getInstance();

    Api.useStagingApi(forceStaging);
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

  bool get forceStaging => _sharedPref.getBool(_forceStagingKey) ?? false;

  /// this method is used to force staging api
  /// if value is null, it will be [false]
  set forceStaging(bool value) {
    Api.useStagingApi(value);

    _sharedPref.setBool(_forceStagingKey, value);
    notifyListeners();
  }

  /// return true if the screen orientation is horizontal
  /// null will use the default orientation
  bool? get orientationLandscape =>
      _sharedPref.getBool(_screenOrientation) ?? RelativeSizes.instance.orientation == Orientation.landscape;

  /// set the screen orientation
  /// null will use the default orientation based on the device
  set orientationLandscape(bool? value) {
    if (value == null) {
      _sharedPref.remove(_screenOrientation);
    } else {
      _sharedPref.setBool(_screenOrientation, value);
    }
    notifyListeners();
  }

  void toggleOrientation(){
    orientationLandscape = !orientationLandscape!;
  }

  /// calculate the orientation based on the user preferences and screen size
  Orientation get calculatedOrientation {
    switch (orientationLandscape) {
      case true:
        return Orientation.landscape;
      case false:
        return Orientation.portrait;
      default:
        return RelativeSizes.instance.orientation;
    }
  }
}
