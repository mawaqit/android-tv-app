import 'package:flutter/cupertino.dart';

class WeatherIcons extends IconData {
  WeatherIcons(super.codePoint) : super(fontFamily: 'WeatherIcons');

  WeatherIcons.fromString(String value) : this(values[value] ?? 0xf00);

  static const Map values = {
    'storm-showers': 0xf00e,
    'thunderstorm': 0xf010,
    'sprinkle': 0xf00b,
    'rain': 0xf008,
    'rain-mix': 0xf006,
    'showers': 0xf009,
    'snow': 0xf01b,
    'sleet': 0xf0b5,
    'smoke': 0xf062,
    'haze': 0xf0b6,
    'cloudy-gusts': 0xf000,
    'fog': 0xf014,
    'dust': 0xf063,
    'smog': 0xf074,
    'windy': 0xf085,
    'tornado': 0xf056,
    'sunny': 0xf00d,
    'cloudy': 0xf07d,
  };
}
