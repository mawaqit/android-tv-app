import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/weather_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    if (mosqueManager.weather?.temperature == null) return SizedBox();
    print(mosqueManager.weather!.icon);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            WeatherIcons.fromString(mosqueManager.weather!.icon),
            size: 30,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text(
            "${mosqueManager.weather!.temperature} ",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
          ),
          Text(
            "°C",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              height: .5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
