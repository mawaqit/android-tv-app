import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/weather_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../themes/UIShadows.dart';

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

    if (temperature == null || !temperatureEnable!)
      return SizedBox(
        width: 10.vw,
        height: 3.vw,
      );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            WeatherIcons.fromString(mosqueManager.weather!.icon),
            size: 3.vw,
            color: Colors.white,
            shadows: kAfterAdhanTextShadow,
          ),
          SizedBox(width: 1.6.vw),
          Text(
            "$temperature",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 3.vw,
                fontWeight: FontWeight.w700,
                color: HexColor(mosqueManager.getColorFeeling()),
                shadows: kHomeTextShadow),
          ),
          Text(
            "°$temperatureUnit",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                height: 1,
                color: HexColor(mosqueManager.getColorFeeling()),
                fontSize: 2.4.vw,
                shadows: kHomeTextShadow),
          ),
        ],
      ),
    );
  }
}
