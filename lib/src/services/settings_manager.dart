import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/repository/settings_service.dart';

class SettingsManager extends ChangeNotifier {
  final settingsService = SettingsService();
  final sharedPref = SharedPref();

  Settings? _settings;

  Settings get settings => _settings!;

  bool get settingsLoaded => _settings != null;

  Future<void> init() async {
    _settings = await settingsService.getSettings();

    notifyListeners();
  }
}
