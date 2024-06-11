import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/weather.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

/// this is an extend for [MosqueManager]
mixin WeatherMixin on ChangeNotifier {
  Weather? weather;
  MosqueConfig? mosqueConfig;

  StreamSubscription? _weatherSubscription;

  void loadWeather(Mosque mosque) async {
    if (mosque.uuid != null) {
      _weatherSubscription?.cancel().catchError((e) {});

      _weatherSubscription =
          generateStream(Duration(hours: 1)).listen((event) => Api.getWeather(mosque.uuid!).then((value) {
                weather = value;
                notifyListeners();
              }).catchError((e, stack) {
                debugPrintStack(stackTrace: stack, label: e.toString());
                weather = null;
                notifyListeners();
              }));
    }
  }

  Color getColorFeeling() {
    final temp = weather?.temperature;

    switch (temp) {
      case null:
        return Colors.white;
      case <= 0:
        return Color(0xFF3498DB); // very cold
      case <= 10:
        return Color(0xFFFFFFFF); // cold
      case <= 20:
        return Color(0xFFFFD05F); // middle
      case <= 30:
        return Color(0xFFD58512); // hot
      default:
        return Color(0xFFAA3333); // very hot
    }
  }

  Color getColorTheme() {
    String? theme = mosqueConfig?.theme?.toLowerCase();

    switch (theme) {
      case "spring":
        return Colors.green.shade900;
      case "winter":
        return Colors.cyan.shade700;
      case "summer":
        return Colors.red.shade900;
      case "autumn":
        return Colors.lime.shade900;
      default:
        return Color(0xff38008a);
    }
  }
}
