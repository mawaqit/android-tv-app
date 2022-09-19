import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';

ValueNotifier<Settings> setting = new ValueNotifier(new Settings());

class SettingsService {
  final _sharedPref = SharedPref();

  /// fetch the setting from the server and cache it for future usage
  ///
  /// 1. load settings from server
  /// 2. in case of server error uses the last cached settings value
  /// 3. in case of not exists uses the default value in `assets/cfg/settings.json`
  Future<Settings> getSettings() async {
    try {
      var res = await http
          .get(
            Uri.parse(
              '${GlobalConfiguration().getValue('api_base_url')}/api/settings/settings.php',
            ),
          )
          .timeout(Duration(seconds: 5));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        Settings settings = Settings.fromJson(json["data"]);

        saveCachedSettings(json['data']);

        return settings;
      } else {
        throw Exception('Getting local saved settings');
      }
    } catch (e) {
      var localSettings = await getCachedSettings().catchError((e) => null);
      localSettings ??= await getLocalSettings();

      if (localSettings == null) throw Exception('Failed to load /api/settings');

      return localSettings;
    }
  }

  Future<void> saveCachedSettings(dynamic settings) => _sharedPref.save("settings", settings);

  /// used for performance improvement (initial start up time)
  /// used for fall back in case of server down
  Future<Settings?> getCachedSettings() async {
    final settings = await _sharedPref.read('settings');

    if (settings == null) return null;

    return Settings.fromJson(settings);
  }

  Future<Settings?> getLocalSettings() async {
    final data = await rootBundle.loadString('assets/cfg/settings.json');

    final settings = jsonDecode(data);
    return Settings.fromJson(settings);
  }
}
