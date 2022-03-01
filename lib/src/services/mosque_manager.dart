import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/AnalyticsWrapper.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:http/http.dart' as http;

class MosqueManager extends ChangeNotifier {
  final sharedPref = SharedPref();

  String? mosqueId;

  Future<void> init() async {
    mosqueId = await sharedPref.read("mosqueId").catchError((e) => null);

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
