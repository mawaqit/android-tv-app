import 'package:flutter/cupertino.dart';

class WeatherIcons extends IconData {
  const WeatherIcons(super.codePoint) : super(fontFamily: 'WeatherIcons');

  factory WeatherIcons.fromString(String value) {
    return _values[value];
  }

  static const Map _values = {
    'storm-showers': const WeatherIcons(0xf00e),
    'thunderstorm': const WeatherIcons(0xf010),
    'sprinkle': const WeatherIcons(0xf00b),
    'rain': const WeatherIcons(0xf008),
    'rain-mix': const WeatherIcons(0xf006),
    'showers': const WeatherIcons(0xf009),
    'snow': const WeatherIcons(0xf01b),
    'sleet': const WeatherIcons(0xf0b5),
    'smoke': const WeatherIcons(0xf062),
    'haze': const WeatherIcons(0xf0b6),
    'cloudy-gusts': const WeatherIcons(0xf000),
    'fog': const WeatherIcons(0xf014),
    'dust': const WeatherIcons(0xf063),
    'smog': const WeatherIcons(0xf074),
    'windy': const WeatherIcons(0xf085),
    'tornado': const WeatherIcons(0xf056),
    'sunny': const WeatherIcons(0xf00d),
    'cloudy': const WeatherIcons(0xf07d),
  };
}
