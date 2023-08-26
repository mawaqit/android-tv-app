import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/repository/settings_service.dart';

class SettingsManager extends ChangeNotifier {
  final settingsService = SettingsService();
  final sharedPref = SharedPref();

  Settings? _settings;

  Settings get settings => _settings!;

  bool get settingsLoaded => _settings != null;

  /// 1- check for cached value first to speed up the first load time
  /// 2- fetch the new value and cache it for future use
  Future<void> init() async {
    _settings =
        await settingsService.getCachedSettings().catchError((e) => null);

    if (_settings != null) {
      if (hasListeners) notifyListeners();
    }

    _settings = await settingsService.getSettings();
    notifyListeners();
  }
}
