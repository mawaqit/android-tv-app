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

  String getColorFeeling() {
    String? feeling = weather?.feeling;
    String color = "#FFFFFF";
    switch (feeling) {
      case "very-hot":
        color = "#AA3333";
        return color;
      case "hot":
        color = "#d58512";
        return color;
      case "middle":
        color = "#ffd05f";
        return color;
      case "cold":
        color = "#FFFFFF";
        return color;
      case "very-cold":
        color = "#3498db";
        return color;
    }
    return color;
  }
}
