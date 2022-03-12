import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';

final mawaqitApi = "${GlobalConfiguration().getValue('api_base_url')}api/2.0";
const mawaqitApiToken = "2c4a6bcb-dda3-4611-83d0-9b99d94ae22e";

class MosqueManager extends ChangeNotifier {
  final sharedPref = SharedPref();

  String? mosqueId;

  Future<void> init() async {
    mosqueId = await sharedPref.read("mosqueId");

    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<String> setMosqueId(String id) async {
    var url = 'https://mawaqit.net/en/id/$id?view=desktop';

    var value = await http.get(Uri.parse(url));

    if (value.statusCode != 200) {
      throw InvalidMosqueId();
    } else {
      AnalyticsWrapper.changeMosque(id);

      mosqueId = id;
      sharedPref.save('mosqueId', mosqueId);
      notifyListeners();
      return mosqueId!;
    }
  }
}

class InvalidMosqueId implements Exception {}
