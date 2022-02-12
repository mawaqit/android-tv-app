import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';

ValueNotifier<Settings> setting = new ValueNotifier(new Settings());

class SettingsService {
  Future<Settings> getSettings() async {
    // var localSettings =
    var res = await get(
      Uri.parse(
        '${GlobalConfiguration().getValue('api_base_url')}/api/settings/settings.php',
      ),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      Settings settings = Settings.fromJson(json["data"]);
      return settings;
    } else {
      throw Exception('Failed to load api');
    }
  }
}
