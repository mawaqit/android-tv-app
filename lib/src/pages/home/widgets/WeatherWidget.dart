import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/weather_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;
    final weather = mosqueManager.weather;
    final temperature = weather?.temperature;
    final temperatureUnit = mosqueConfig?.temperatureUnit;
    final temperatureEnable = mosqueConfig?.temperatureEnabled;

    if (temperature == null || !temperatureEnable!) return SizedBox();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(top: 2.vh),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              WeatherIcons.fromString(mosqueManager.weather!.icon),
              size: 3.vw,
              color: Colors.white,
            ),
            SizedBox(width: 1.6.vw),
            Text(
              "$temperature",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 3.vw,
                    fontWeight: FontWeight.w500,
                    color: HexColor(mosqueManager.getColorFeeling()),
                  ),
            ),
            Text(
              "°$temperatureUnit",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                height: 1,
                color: HexColor(mosqueManager.getColorFeeling()),
                fontSize: 2.4.vw,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
