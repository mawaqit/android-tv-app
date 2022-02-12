import 'package:flutter/material.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/repository/settings_service.dart';

class SettingsManager extends ChangeNotifier {
  final settingsService = SettingsService();
  Settings? _settings;

  Settings get settings => _settings!;

  bool get settingsLoaded => _settings != null;

  Future<void> init() async {
    _settings = await settingsService.getSettings();
    notifyListeners();
  }
}
