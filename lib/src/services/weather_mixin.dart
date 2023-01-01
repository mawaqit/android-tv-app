import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/weather.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

/// this is an extend for [MosqueManager]
mixin WeatherMixin on ChangeNotifier {
  Weather? weather;

  Future<void> loadWeather(Mosque mosque) async {
    if (mosque.uuid != null)
      Api.getWeather(mosque.uuid!).then((value) {
        weather = value;
        notifyListeners();
      }).catchError((e, stack) {
        debugPrintStack(stackTrace: stack, label: e.toString());
      });
  }
}
