import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';

ValueNotifier<Settings> setting = new ValueNotifier(new Settings());

class SettingsService {
  final _sharedPref = SharedPref();

  Future<Settings> getSettings() async {
    try {
      var res = await get(
        Uri.parse(
          '${GlobalConfiguration().getValue('api_base_url')}/api/settings/settings.php',
        ),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        Settings settings = Settings.fromJson(json["data"]);

        _sharedPref.save('settings', json['data']);

        return settings;
      } else {
        throw Exception('Getting local saved settings');
      }
    } catch (e) {
      final localeSettings = await getLocalSettings();

      if (localeSettings == null) throw Exception('Failed to load /api/settings');

      return localeSettings;
    }
  }

  Future<Settings?> getLocalSettings() async {
    var set = await _sharedPref.read("settings");

    if (set != null) return Settings.fromJson(set);

    return null;
  }
}
