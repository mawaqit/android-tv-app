import 'package:flutter/cupertino.dart';

class WeatherIcons extends IconData {
  const WeatherIcons(super.codePoint) : super(fontFamily: 'WeatherIcons');

  factory WeatherIcons.fromString(String value) {
    return _values[value] ??
        _values["day-$value"] ??
        _values["night-$value"] ??
        degrees;
  }

  factory WeatherIcons.fromStringWithDateNight(
    String value, [
    bool isDay = true,
  ]) {
    return _values['${isDay ? 'day' : 'night'}-$value'] ??
        WeatherIcons.fromString(value);
  }

  static const Map _values = {
    "day-sunny": day_sunny,
    "day-cloudy": day_cloudy,
    "day-cloudy-gusts": day_cloudy_gusts,
    "day-cloudy-windy": day_cloudy_windy,
    "day-fog": day_fog,
    "day-hail": day_hail,
    "day-haze": day_haze,
    "haze": day_haze,
    "day-lightning": day_lightning,
    "day-rain": day_rain,
    "day-rain-mix": day_rain_mix,
    "day-rain-wind": day_rain_wind,
    "day-showers": day_showers,
    "day-sleet": day_sleet,
    "day-sleet-storm": day_sleet_storm,
    "day-snow": day_snow,
    "day-snow-thunderstorm": day_snow_thunderstorm,
    "day-snow-wind": day_snow_wind,
    "day-sprinkle": day_sprinkle,
    "day-storm-showers": day_storm_showers,
    "day-sunny-overcast": day_sunny_overcast,
    "day-thunderstorm": day_thunderstorm,
    "day-windy": day_windy,
    "day-cloudy-high": day_cloudy_high,
    "day-light-wind": day_light_wind,
    "solar-eclipse": solar_eclipse,
    "hot": hot,
    "night-clear": night_clear,
    "night-alt-cloudy": night_alt_cloudy,
    "night-alt-cloudy-gusts": night_alt_cloudy_gusts,
    "night-alt-cloudy-windy": night_alt_cloudy_windy,
    "night-alt-hail": night_alt_hail,
    "night-alt-lightning": night_alt_lightning,
    "night-alt-rain": night_alt_rain,
    "night-alt-rain-mix": night_alt_rain_mix,
    "night-alt-rain-wind": night_alt_rain_wind,
    "night-alt-showers": night_alt_showers,
    "night-alt-sleet": night_alt_sleet,
    "night-alt-sleet-storm": night_alt_sleet_storm,
    "night-alt-snow": night_alt_snow,
    "night-alt-snow-thunderstorm": night_alt_snow_thunderstorm,
    "night-alt-snow-wind": night_alt_snow_wind,
    "night-alt-sprinkle": night_alt_sprinkle,
    "night-alt-storm-showers": night_alt_storm_showers,
    "night-alt-thunderstorm": night_alt_thunderstorm,
    "night-cloudy": night_cloudy,
    "night-cloudy-gusts": night_cloudy_gusts,
    "night-cloudy-windy": night_cloudy_windy,
    "night-fog": night_fog,
    "night-hail": night_hail,
    "night-lightning": night_lightning,
    "night-partly-cloudy": night_partly_cloudy,
    "night-rain": night_rain,
    "night-rain-mix": night_rain_mix,
    "night-rain-wind": night_rain_wind,
    "night-showers": night_showers,
    "night-sleet": night_sleet,
    "night-sleet-storm": night_sleet_storm,
    "night-snow": night_snow,
    "night-snow-thunderstorm": night_snow_thunderstorm,
    "night-snow-wind": night_snow_wind,
    "night-sprinkle": night_sprinkle,
    "night-storm-showers": night_storm_showers,
    "night-thunderstorm": night_thunderstorm,
    "night-alt-cloudy-high": night_alt_cloudy_high,
    "night-cloudy-high": night_cloudy_high,
    "night-alt-partly-cloudy": night_alt_partly_cloudy,
    "lunar-eclipse": lunar_eclipse,
    "stars": stars,
    "cloud": cloud,
    "cloudy": cloudy,
    "cloudy-gusts": cloudy_gusts,
    "cloudy-windy": cloudy_windy,
    "fog": fog,
    "hail": hail,
    "rain": rain,
    "rain-mix": rain_mix,
    "rain-wind": rain_wind,
    "showers": showers,
    "sleet": sleet,
    "sprinkle": sprinkle,
    "storm-showers": storm_showers,
    "thunderstorm": thunderstorm,
    "snow-wind": snow_wind,
    "snow": snow,
    "smog": smog,
    "smoke": smoke,
    "lightning": lightning,
    "raindrops": raindrops,
    "raindrop": raindrop,
    "dust": dust,
    "snowflake-cold": snowflake_cold,
    "windy": windy,
    "strong-wind": strong_wind,
    "sandstorm": sandstorm,
    "earthquake": earthquake,
    "fire": fire,
    "flood": flood,
    "meteor": meteor,
    "tsunami": tsunami,
    "volcano": volcano,
    "hurricane": hurricane,
    "tornado": tornado,
    "small-craft-advisory": small_craft_advisory,
    "gale-warning": gale_warning,
    "storm-warning": storm_warning,
    "hurricane-warning": hurricane_warning,
    "wind-direction": wind_direction,
    "alien": alien,
    "celsius": celsius,
    "fahrenheit": fahrenheit,
    "degrees": degrees,
    "thermometer": thermometer,
    "thermometer-exterior": thermometer_exterior,
    "thermometer-internal": thermometer_internal,
    "cloud-down": cloud_down,
    "cloud-up": cloud_up,
    "cloud-refresh": cloud_refresh,
    "horizon": horizon,
    "horizon-alt": horizon_alt,
    "sunrise": sunrise,
    "sunset": sunset,
    "moonrise": moonrise,
    "moonset": moonset,
    "refresh": refresh,
    "refresh-alt": refresh_alt,
    "umbrella": umbrella,
    "barometer": barometer,
    "humidity": humidity,
    "na": na,
    "train": train,
    "moon-new": moon_new,
    "moon-waxing-crescent-1": moon_waxing_crescent_1,
    "moon-waxing-crescent-2": moon_waxing_crescent_2,
    "moon-waxing-crescent-3": moon_waxing_crescent_3,
    "moon-waxing-crescent-4": moon_waxing_crescent_4,
    "moon-waxing-crescent-5": moon_waxing_crescent_5,
    "moon-waxing-crescent-6": moon_waxing_crescent_6,
    "moon-first-quarter": moon_first_quarter,
    "moon-waxing-gibbous-1": moon_waxing_gibbous_1,
    "moon-waxing-gibbous-2": moon_waxing_gibbous_2,
    "moon-waxing-gibbous-3": moon_waxing_gibbous_3,
    "moon-waxing-gibbous-4": moon_waxing_gibbous_4,
    "moon-waxing-gibbous-5": moon_waxing_gibbous_5,
    "moon-waxing-gibbous-6": moon_waxing_gibbous_6,
    "moon-full": moon_full,
    "moon-waning-gibbous-1": moon_waning_gibbous_1,
    "moon-waning-gibbous-2": moon_waning_gibbous_2,
    "moon-waning-gibbous-3": moon_waning_gibbous_3,
    "moon-waning-gibbous-4": moon_waning_gibbous_4,
    "moon-waning-gibbous-5": moon_waning_gibbous_5,
    "moon-waning-gibbous-6": moon_waning_gibbous_6,
    "moon-third-quarter": moon_third_quarter,
    "moon-waning-crescent-1": moon_waning_crescent_1,
    "moon-waning-crescent-2": moon_waning_crescent_2,
    "moon-waning-crescent-3": moon_waning_crescent_3,
    "moon-waning-crescent-4": moon_waning_crescent_4,
    "moon-waning-crescent-5": moon_waning_crescent_5,
    "moon-waning-crescent-6": moon_waning_crescent_6,
    "moon-alt-new": moon_alt_new,
    "moon-alt-waxing-crescent-1": moon_alt_waxing_crescent_1,
    "moon-alt-waxing-crescent-2": moon_alt_waxing_crescent_2,
    "moon-alt-waxing-crescent-3": moon_alt_waxing_crescent_3,
    "moon-alt-waxing-crescent-4": moon_alt_waxing_crescent_4,
    "moon-alt-waxing-crescent-5": moon_alt_waxing_crescent_5,
    "moon-alt-waxing-crescent-6": moon_alt_waxing_crescent_6,
    "moon-alt-first-quarter": moon_alt_first_quarter,
    "moon-alt-waxing-gibbous-1": moon_alt_waxing_gibbous_1,
    "moon-alt-waxing-gibbous-2": moon_alt_waxing_gibbous_2,
    "moon-alt-waxing-gibbous-3": moon_alt_waxing_gibbous_3,
    "moon-alt-waxing-gibbous-4": moon_alt_waxing_gibbous_4,
    "moon-alt-waxing-gibbous-5": moon_alt_waxing_gibbous_5,
    "moon-alt-waxing-gibbous-6": moon_alt_waxing_gibbous_6,
    "moon-alt-full": moon_alt_full,
    "moon-alt-waning-gibbous-1": moon_alt_waning_gibbous_1,
    "moon-alt-waning-gibbous-2": moon_alt_waning_gibbous_2,
    "moon-alt-waning-gibbous-3": moon_alt_waning_gibbous_3,
    "moon-alt-waning-gibbous-4": moon_alt_waning_gibbous_4,
    "moon-alt-waning-gibbous-5": moon_alt_waning_gibbous_5,
    "moon-alt-waning-gibbous-6": moon_alt_waning_gibbous_6,
    "moon-alt-third-quarter": moon_alt_third_quarter,
    "moon-alt-waning-crescent-1": moon_alt_waning_crescent_1,
    "moon-alt-waning-crescent-2": moon_alt_waning_crescent_2,
    "moon-alt-waning-crescent-3": moon_alt_waning_crescent_3,
    "moon-alt-waning-crescent-4": moon_alt_waning_crescent_4,
    "moon-alt-waning-crescent-5": moon_alt_waning_crescent_5,
    "moon-alt-waning-crescent-6": moon_alt_waning_crescent_6,
    "moon-0": moon_0,
    "moon-1": moon_1,
    "moon-2": moon_2,
    "moon-3": moon_3,
    "moon-4": moon_4,
    "moon-5": moon_5,
    "moon-6": moon_6,
    "moon-7": moon_7,
    "moon-8": moon_8,
    "moon-9": moon_9,
    "moon-10": moon_10,
    "moon-11": moon_11,
    "moon-12": moon_12,
    "moon-13": moon_13,
    "moon-14": moon_14,
    "moon-15": moon_15,
    "moon-16": moon_16,
    "moon-17": moon_17,
    "moon-18": moon_18,
    "moon-19": moon_19,
    "moon-20": moon_20,
    "moon-21": moon_21,
    "moon-22": moon_22,
    "moon-23": moon_23,
    "moon-24": moon_24,
    "moon-25": moon_25,
    "moon-26": moon_26,
    "moon-27": moon_27,
    "time-1": time_1,
    "time-2": time_2,
    "time-3": time_3,
    "time-4": time_4,
    "time-5": time_5,
    "time-6": time_6,
    "time-7": time_7,
    "time-8": time_8,
    "time-9": time_9,
    "time-10": time_10,
    "time-11": time_11,
    "time-12": time_12,
    "direction-up": direction_up,
    "direction-up-right": direction_up_right,
    "direction-right": direction_right,
    "direction-down-right": direction_down_right,
    "direction-down": direction_down,
    "direction-down-left": direction_down_left,
    "direction-left": direction_left,
    "direction-up-left": direction_up_left,
    "wind-beaufort-0": wind_beaufort_0,
    "wind-beaufort-1": wind_beaufort_1,
    "wind-beaufort-2": wind_beaufort_2,
    "wind-beaufort-3": wind_beaufort_3,
    "wind-beaufort-4": wind_beaufort_4,
    "wind-beaufort-5": wind_beaufort_5,
    "wind-beaufort-6": wind_beaufort_6,
    "wind-beaufort-7": wind_beaufort_7,
    "wind-beaufort-8": wind_beaufort_8,
    "wind-beaufort-9": wind_beaufort_9,
    "wind-beaufort-10": wind_beaufort_10,
    "wind-beaufort-11": wind_beaufort_11,
    "wind-beaufort-12": wind_beaufort_12,
    "yahoo-0": yahoo_0,
    "yahoo-1": yahoo_1,
    "yahoo-2": yahoo_2,
    "yahoo-3": yahoo_3,
    "yahoo-4": yahoo_4,
    "yahoo-5": yahoo_5,
    "yahoo-6": yahoo_6,
    "yahoo-7": yahoo_7,
    "yahoo-8": yahoo_8,
    "yahoo-9": yahoo_9,
    "yahoo-10": yahoo_10,
    "yahoo-11": yahoo_11,
    "yahoo-12": yahoo_12,
    "yahoo-13": yahoo_13,
    "yahoo-14": yahoo_14,
    "yahoo-15": yahoo_15,
    "yahoo-16": yahoo_16,
    "yahoo-17": yahoo_17,
    "yahoo-18": yahoo_18,
    "yahoo-19": yahoo_19,
    "yahoo-20": yahoo_20,
    "yahoo-21": yahoo_21,
    "yahoo-22": yahoo_22,
    "yahoo-23": yahoo_23,
    "yahoo-24": yahoo_24,
    "yahoo-25": yahoo_25,
    "yahoo-26": yahoo_26,
    "yahoo-27": yahoo_27,
    "yahoo-28": yahoo_28,
    "yahoo-29": yahoo_29,
    "yahoo-30": yahoo_30,
    "yahoo-31": yahoo_31,
    "yahoo-32": yahoo_32,
    "yahoo-33": yahoo_33,
    "yahoo-34": yahoo_34,
    "yahoo-35": yahoo_35,
    "yahoo-36": yahoo_36,
    "yahoo-37": yahoo_37,
    "yahoo-38": yahoo_38,
    "yahoo-39": yahoo_39,
    "yahoo-40": yahoo_40,
    "yahoo-41": yahoo_41,
    "yahoo-42": yahoo_42,
    "yahoo-43": yahoo_43,
    "yahoo-44": yahoo_44,
    "yahoo-45": yahoo_45,
    "yahoo-46": yahoo_46,
    "yahoo-47": yahoo_47,
    "yahoo-3200": yahoo_3200,
    "forecast-io-clear-day": forecast_io_clear_day,
    "forecast-io-clear-night": forecast_io_clear_night,
    "forecast-io-rain": forecast_io_rain,
    "forecast-io-snow": forecast_io_snow,
    "forecast-io-sleet": forecast_io_sleet,
    "forecast-io-wind": forecast_io_wind,
    "forecast-io-fog": forecast_io_fog,
    "forecast-io-cloudy": forecast_io_cloudy,
    "forecast-io-partly-cloudy-day": forecast_io_partly_cloudy_day,
    "forecast-io-partly-cloudy-night": forecast_io_partly_cloudy_night,
    "forecast-io-hail": forecast_io_hail,
    "forecast-io-thunderstorm": forecast_io_thunderstorm,
    "forecast-io-tornado": forecast_io_tornado,
    "wmo4680-00,wmo4680-0": wmo4680_00wmo4680_0,
    "wmo4680-01,wmo4680-1": wmo4680_01wmo4680_1,
    "wmo4680-02,wmo4680-2": wmo4680_02wmo4680_2,
    "wmo4680-03,wmo4680-3": wmo4680_03wmo4680_3,
    "wmo4680-04,wmo4680-4": wmo4680_04wmo4680_4,
    "wmo4680-05,wmo4680-5": wmo4680_05wmo4680_5,
    "wmo4680-10": wmo4680_10,
    "wmo4680-11": wmo4680_11,
    "wmo4680-12": wmo4680_12,
    "wmo4680-18": wmo4680_18,
    "wmo4680-20": wmo4680_20,
    "wmo4680-21": wmo4680_21,
    "wmo4680-22": wmo4680_22,
    "wmo4680-23": wmo4680_23,
    "wmo4680-24": wmo4680_24,
    "wmo4680-25": wmo4680_25,
    "wmo4680-26": wmo4680_26,
    "wmo4680-27": wmo4680_27,
    "wmo4680-28": wmo4680_28,
    "wmo4680-29": wmo4680_29,
    "wmo4680-30": wmo4680_30,
    "wmo4680-31": wmo4680_31,
    "wmo4680-32": wmo4680_32,
    "wmo4680-33": wmo4680_33,
    "wmo4680-34": wmo4680_34,
    "wmo4680-35": wmo4680_35,
    "wmo4680-40": wmo4680_40,
    "wmo4680-41": wmo4680_41,
    "wmo4680-42": wmo4680_42,
    "wmo4680-43": wmo4680_43,
    "wmo4680-44": wmo4680_44,
    "wmo4680-45": wmo4680_45,
    "wmo4680-46": wmo4680_46,
    "wmo4680-47": wmo4680_47,
    "wmo4680-48": wmo4680_48,
    "wmo4680-50": wmo4680_50,
    "wmo4680-51": wmo4680_51,
    "wmo4680-52": wmo4680_52,
    "wmo4680-53": wmo4680_53,
    "wmo4680-54": wmo4680_54,
    "wmo4680-55": wmo4680_55,
    "wmo4680-56": wmo4680_56,
    "wmo4680-57": wmo4680_57,
    "wmo4680-58": wmo4680_58,
    "wmo4680-60": wmo4680_60,
    "wmo4680-61": wmo4680_61,
    "wmo4680-62": wmo4680_62,
    "wmo4680-63": wmo4680_63,
    "wmo4680-64": wmo4680_64,
    "wmo4680-65": wmo4680_65,
    "wmo4680-66": wmo4680_66,
    "wmo4680-67": wmo4680_67,
    "wmo4680-68": wmo4680_68,
    "wmo4680-70": wmo4680_70,
    "wmo4680-71": wmo4680_71,
    "wmo4680-72": wmo4680_72,
    "wmo4680-73": wmo4680_73,
    "wmo4680-74": wmo4680_74,
    "wmo4680-75": wmo4680_75,
    "wmo4680-76": wmo4680_76,
    "wmo4680-77": wmo4680_77,
    "wmo4680-78": wmo4680_78,
    "wmo4680-80": wmo4680_80,
    "wmo4680-81": wmo4680_81,
    "wmo4680-82": wmo4680_82,
    "wmo4680-83": wmo4680_83,
    "wmo4680-84": wmo4680_84,
    "wmo4680-85": wmo4680_85,
    "wmo4680-86": wmo4680_86,
    "wmo4680-87": wmo4680_87,
    "wmo4680-89": wmo4680_89,
    "wmo4680-90": wmo4680_90,
    "wmo4680-91": wmo4680_91,
    "wmo4680-92": wmo4680_92,
    "wmo4680-93": wmo4680_93,
    "wmo4680-94": wmo4680_94,
    "wmo4680-95": wmo4680_95,
    "wmo4680-96": wmo4680_96,
    "wmo4680-99": wmo4680_99,
    "owm-200": owm_200,
    "owm-201": owm_201,
    "owm-202": owm_202,
    "owm-210": owm_210,
    "owm-211": owm_211,
    "owm-212": owm_212,
    "owm-221": owm_221,
    "owm-230": owm_230,
    "owm-231": owm_231,
    "owm-232": owm_232,
    "owm-300": owm_300,
    "owm-301": owm_301,
    "owm-302": owm_302,
    "owm-310": owm_310,
    "owm-311": owm_311,
    "owm-312": owm_312,
    "owm-313": owm_313,
    "owm-314": owm_314,
    "owm-321": owm_321,
    "owm-500": owm_500,
    "owm-501": owm_501,
    "owm-502": owm_502,
    "owm-503": owm_503,
    "owm-504": owm_504,
    "owm-511": owm_511,
    "owm-520": owm_520,
    "owm-521": owm_521,
    "owm-522": owm_522,
    "owm-531": owm_531,
    "owm-600": owm_600,
    "owm-601": owm_601,
    "owm-602": owm_602,
    "owm-611": owm_611,
    "owm-612": owm_612,
    "owm-615": owm_615,
    "owm-616": owm_616,
    "owm-620": owm_620,
    "owm-621": owm_621,
    "owm-622": owm_622,
    "owm-701": owm_701,
    "owm-711": owm_711,
    "owm-721": owm_721,
    "owm-731": owm_731,
    "owm-741": owm_741,
    "owm-761": owm_761,
    "owm-762": owm_762,
    "owm-771": owm_771,
    "owm-781": owm_781,
    "owm-800": owm_800,
    "owm-801": owm_801,
    "owm-802": owm_802,
    "owm-803": owm_803,
    "owm-804": owm_804,
    "owm-900": owm_900,
    "owm-901": owm_901,
    "owm-902": owm_902,
    "owm-903": owm_903,
    "owm-904": owm_904,
    "owm-905": owm_905,
    "owm-906": owm_906,
    "owm-957": owm_957,
    "owm-day-200": owm_day_200,
    "owm-day-201": owm_day_201,
    "owm-day-202": owm_day_202,
    "owm-day-210": owm_day_210,
    "owm-day-211": owm_day_211,
    "owm-day-212": owm_day_212,
    "owm-day-221": owm_day_221,
    "owm-day-230": owm_day_230,
    "owm-day-231": owm_day_231,
    "owm-day-232": owm_day_232,
    "owm-day-300": owm_day_300,
    "owm-day-301": owm_day_301,
    "owm-day-302": owm_day_302,
    "owm-day-310": owm_day_310,
    "owm-day-311": owm_day_311,
    "owm-day-312": owm_day_312,
    "owm-day-313": owm_day_313,
    "owm-day-314": owm_day_314,
    "owm-day-321": owm_day_321,
    "owm-day-500": owm_day_500,
    "owm-day-501": owm_day_501,
    "owm-day-502": owm_day_502,
    "owm-day-503": owm_day_503,
    "owm-day-504": owm_day_504,
    "owm-day-511": owm_day_511,
    "owm-day-520": owm_day_520,
    "owm-day-521": owm_day_521,
    "owm-day-522": owm_day_522,
    "owm-day-531": owm_day_531,
    "owm-day-600": owm_day_600,
    "owm-day-601": owm_day_601,
    "owm-day-602": owm_day_602,
    "owm-day-611": owm_day_611,
    "owm-day-612": owm_day_612,
    "owm-day-615": owm_day_615,
    "owm-day-616": owm_day_616,
    "owm-day-620": owm_day_620,
    "owm-day-621": owm_day_621,
    "owm-day-622": owm_day_622,
    "owm-day-701": owm_day_701,
    "owm-day-711": owm_day_711,
    "owm-day-721": owm_day_721,
    "owm-day-731": owm_day_731,
    "owm-day-741": owm_day_741,
    "owm-day-761": owm_day_761,
    "owm-day-762": owm_day_762,
    "owm-day-781": owm_day_781,
    "owm-day-800": owm_day_800,
    "owm-day-801": owm_day_801,
    "owm-day-802": owm_day_802,
    "owm-day-803": owm_day_803,
    "owm-day-804": owm_day_804,
    "owm-day-900": owm_day_900,
    "owm-day-902": owm_day_902,
    "owm-day-903": owm_day_903,
    "owm-day-904": owm_day_904,
    "owm-day-906": owm_day_906,
    "owm-day-957": owm_day_957,
    "owm-night-200": owm_night_200,
    "owm-night-201": owm_night_201,
    "owm-night-202": owm_night_202,
    "owm-night-210": owm_night_210,
    "owm-night-211": owm_night_211,
    "owm-night-212": owm_night_212,
    "owm-night-221": owm_night_221,
    "owm-night-230": owm_night_230,
    "owm-night-231": owm_night_231,
    "owm-night-232": owm_night_232,
    "owm-night-300": owm_night_300,
    "owm-night-301": owm_night_301,
    "owm-night-302": owm_night_302,
    "owm-night-310": owm_night_310,
    "owm-night-311": owm_night_311,
    "owm-night-312": owm_night_312,
    "owm-night-313": owm_night_313,
    "owm-night-314": owm_night_314,
    "owm-night-321": owm_night_321,
    "owm-night-500": owm_night_500,
    "owm-night-501": owm_night_501,
    "owm-night-502": owm_night_502,
    "owm-night-503": owm_night_503,
    "owm-night-504": owm_night_504,
    "owm-night-511": owm_night_511,
    "owm-night-520": owm_night_520,
    "owm-night-521": owm_night_521,
    "owm-night-522": owm_night_522,
    "owm-night-531": owm_night_531,
    "owm-night-600": owm_night_600,
    "owm-night-601": owm_night_601,
    "owm-night-602": owm_night_602,
    "owm-night-611": owm_night_611,
    "owm-night-612": owm_night_612,
    "owm-night-615": owm_night_615,
    "owm-night-616": owm_night_616,
    "owm-night-620": owm_night_620,
    "owm-night-621": owm_night_621,
    "owm-night-622": owm_night_622,
    "owm-night-701": owm_night_701,
    "owm-night-711": owm_night_711,
    "owm-night-721": owm_night_721,
    "owm-night-731": owm_night_731,
    "owm-night-741": owm_night_741,
    "owm-night-761": owm_night_761,
    "owm-night-762": owm_night_762,
    "owm-night-781": owm_night_781,
    "owm-night-800": owm_night_800,
    "owm-night-801": owm_night_801,
    "owm-night-802": owm_night_802,
    "owm-night-803": owm_night_803,
    "owm-night-804": owm_night_804,
    "owm-night-900": owm_night_900,
    "owm-night-902": owm_night_902,
    "owm-night-903": owm_night_903,
    "owm-night-904": owm_night_904,
    "owm-night-906": owm_night_906,
    "owm-night-957": owm_night_957,
    "wu-chanceflurries": wu_chanceflurries,
    "wu-chancerain": wu_chancerain,
    "wu-chancesleat": wu_chancesleat,
    "wu-chancesnow": wu_chancesnow,
    "wu-chancetstorms": wu_chancetstorms,
    "wu-clear": wu_clear,
    "wu-cloudy": wu_cloudy,
    "wu-flurries": wu_flurries,
    "wu-hazy": wu_hazy,
    "wu-mostlycloudy": wu_mostlycloudy,
    "wu-mostlysunny": wu_mostlysunny,
    "wu-partlycloudy": wu_partlycloudy,
    "wu-partlysunny": wu_partlysunny,
    "wu-rain": wu_rain,
    "wu-sleat": wu_sleat,
    "wu-snow": wu_snow,
    "wu-sunny": wu_sunny,
    "wu-tstorms": wu_tstorms,
  };

  static const day_sunny = WeatherIcons(0xf00d);
  static const day_cloudy = WeatherIcons(0xf002);
  static const day_cloudy_gusts = WeatherIcons(0xf000);
  static const day_cloudy_windy = WeatherIcons(0xf001);
  static const day_fog = WeatherIcons(0xf003);
  static const day_hail = WeatherIcons(0xf004);
  static const day_haze = WeatherIcons(0xf0b6);
  static const day_lightning = WeatherIcons(0xf005);
  static const day_rain = WeatherIcons(0xf008);
  static const day_rain_mix = WeatherIcons(0xf006);
  static const day_rain_wind = WeatherIcons(0xf007);
  static const day_showers = WeatherIcons(0xf009);
  static const day_sleet = WeatherIcons(0xf0b2);
  static const day_sleet_storm = WeatherIcons(0xf068);
  static const day_snow = WeatherIcons(0xf00a);
  static const day_snow_thunderstorm = WeatherIcons(0xf06b);
  static const day_snow_wind = WeatherIcons(0xf065);
  static const day_sprinkle = WeatherIcons(0xf00b);
  static const day_storm_showers = WeatherIcons(0xf00e);
  static const day_sunny_overcast = WeatherIcons(0xf00c);
  static const day_thunderstorm = WeatherIcons(0xf010);
  static const day_windy = WeatherIcons(0xf085);
  static const day_cloudy_high = WeatherIcons(0xf07d);
  static const day_light_wind = WeatherIcons(0xf0c4);
  static const solar_eclipse = WeatherIcons(0xf06e);
  static const hot = WeatherIcons(0xf072);
  static const night_clear = WeatherIcons(0xf02e);
  static const night_alt_cloudy = WeatherIcons(0xf086);
  static const night_alt_cloudy_gusts = WeatherIcons(0xf022);
  static const night_alt_cloudy_windy = WeatherIcons(0xf023);
  static const night_alt_hail = WeatherIcons(0xf024);
  static const night_alt_lightning = WeatherIcons(0xf025);
  static const night_alt_rain = WeatherIcons(0xf028);
  static const night_alt_rain_mix = WeatherIcons(0xf026);
  static const night_alt_rain_wind = WeatherIcons(0xf027);
  static const night_alt_showers = WeatherIcons(0xf029);
  static const night_alt_sleet = WeatherIcons(0xf0b4);
  static const night_alt_sleet_storm = WeatherIcons(0xf06a);
  static const night_alt_snow = WeatherIcons(0xf02a);
  static const night_alt_snow_thunderstorm = WeatherIcons(0xf06d);
  static const night_alt_snow_wind = WeatherIcons(0xf067);
  static const night_alt_sprinkle = WeatherIcons(0xf02b);
  static const night_alt_storm_showers = WeatherIcons(0xf02c);
  static const night_alt_thunderstorm = WeatherIcons(0xf02d);
  static const night_cloudy = WeatherIcons(0xf031);
  static const night_cloudy_gusts = WeatherIcons(0xf02f);
  static const night_cloudy_windy = WeatherIcons(0xf030);
  static const night_fog = WeatherIcons(0xf04a);
  static const night_hail = WeatherIcons(0xf032);
  static const night_lightning = WeatherIcons(0xf033);
  static const night_partly_cloudy = WeatherIcons(0xf083);
  static const night_rain = WeatherIcons(0xf036);
  static const night_rain_mix = WeatherIcons(0xf034);
  static const night_rain_wind = WeatherIcons(0xf035);
  static const night_showers = WeatherIcons(0xf037);
  static const night_sleet = WeatherIcons(0xf0b3);
  static const night_sleet_storm = WeatherIcons(0xf069);
  static const night_snow = WeatherIcons(0xf038);
  static const night_snow_thunderstorm = WeatherIcons(0xf06c);
  static const night_snow_wind = WeatherIcons(0xf066);
  static const night_sprinkle = WeatherIcons(0xf039);
  static const night_storm_showers = WeatherIcons(0xf03a);
  static const night_thunderstorm = WeatherIcons(0xf03b);
  static const night_alt_cloudy_high = WeatherIcons(0xf07e);
  static const night_cloudy_high = WeatherIcons(0xf080);
  static const night_alt_partly_cloudy = WeatherIcons(0xf081);
  static const lunar_eclipse = WeatherIcons(0xf070);
  static const stars = WeatherIcons(0xf077);
  static const cloud = WeatherIcons(0xf041);
  static const cloudy = WeatherIcons(0xf013);
  static const cloudy_gusts = WeatherIcons(0xf011);
  static const cloudy_windy = WeatherIcons(0xf012);
  static const fog = WeatherIcons(0xf014);
  static const hail = WeatherIcons(0xf015);
  static const rain = WeatherIcons(0xf019);
  static const rain_mix = WeatherIcons(0xf017);
  static const rain_wind = WeatherIcons(0xf018);
  static const showers = WeatherIcons(0xf01a);
  static const sleet = WeatherIcons(0xf0b5);
  static const sprinkle = WeatherIcons(0xf01c);
  static const storm_showers = WeatherIcons(0xf01d);
  static const thunderstorm = WeatherIcons(0xf01e);
  static const snow_wind = WeatherIcons(0xf064);
  static const snow = WeatherIcons(0xf01b);
  static const smog = WeatherIcons(0xf074);
  static const smoke = WeatherIcons(0xf062);
  static const lightning = WeatherIcons(0xf016);
  static const raindrops = WeatherIcons(0xf04e);
  static const raindrop = WeatherIcons(0xf078);
  static const dust = WeatherIcons(0xf063);
  static const snowflake_cold = WeatherIcons(0xf076);
  static const windy = WeatherIcons(0xf021);
  static const strong_wind = WeatherIcons(0xf050);
  static const sandstorm = WeatherIcons(0xf082);
  static const earthquake = WeatherIcons(0xf0c6);
  static const fire = WeatherIcons(0xf0c7);
  static const flood = WeatherIcons(0xf07c);
  static const meteor = WeatherIcons(0xf071);
  static const tsunami = WeatherIcons(0xf0c5);
  static const volcano = WeatherIcons(0xf0c8);
  static const hurricane = WeatherIcons(0xf073);
  static const tornado = WeatherIcons(0xf056);
  static const small_craft_advisory = WeatherIcons(0xf0cc);
  static const gale_warning = WeatherIcons(0xf0cd);
  static const storm_warning = WeatherIcons(0xf0ce);
  static const hurricane_warning = WeatherIcons(0xf0cf);
  static const wind_direction = WeatherIcons(0xf0b1);
  static const alien = WeatherIcons(0xf075);
  static const celsius = WeatherIcons(0xf03c);
  static const fahrenheit = WeatherIcons(0xf045);
  static const degrees = WeatherIcons(0xf042);
  static const thermometer = WeatherIcons(0xf055);
  static const thermometer_exterior = WeatherIcons(0xf053);
  static const thermometer_internal = WeatherIcons(0xf054);
  static const cloud_down = WeatherIcons(0xf03d);
  static const cloud_up = WeatherIcons(0xf040);
  static const cloud_refresh = WeatherIcons(0xf03e);
  static const horizon = WeatherIcons(0xf047);
  static const horizon_alt = WeatherIcons(0xf046);
  static const sunrise = WeatherIcons(0xf051);
  static const sunset = WeatherIcons(0xf052);
  static const moonrise = WeatherIcons(0xf0c9);
  static const moonset = WeatherIcons(0xf0ca);
  static const refresh = WeatherIcons(0xf04c);
  static const refresh_alt = WeatherIcons(0xf04b);
  static const umbrella = WeatherIcons(0xf084);
  static const barometer = WeatherIcons(0xf079);
  static const humidity = WeatherIcons(0xf07a);
  static const na = WeatherIcons(0xf07b);
  static const train = WeatherIcons(0xf0cb);
  static const moon_new = WeatherIcons(0xf095);
  static const moon_waxing_crescent_1 = WeatherIcons(0xf096);
  static const moon_waxing_crescent_2 = WeatherIcons(0xf097);
  static const moon_waxing_crescent_3 = WeatherIcons(0xf098);
  static const moon_waxing_crescent_4 = WeatherIcons(0xf099);
  static const moon_waxing_crescent_5 = WeatherIcons(0xf09a);
  static const moon_waxing_crescent_6 = WeatherIcons(0xf09b);
  static const moon_first_quarter = WeatherIcons(0xf09c);
  static const moon_waxing_gibbous_1 = WeatherIcons(0xf09d);
  static const moon_waxing_gibbous_2 = WeatherIcons(0xf09e);
  static const moon_waxing_gibbous_3 = WeatherIcons(0xf09f);
  static const moon_waxing_gibbous_4 = WeatherIcons(0xf0a0);
  static const moon_waxing_gibbous_5 = WeatherIcons(0xf0a1);
  static const moon_waxing_gibbous_6 = WeatherIcons(0xf0a2);
  static const moon_full = WeatherIcons(0xf0a3);
  static const moon_waning_gibbous_1 = WeatherIcons(0xf0a4);
  static const moon_waning_gibbous_2 = WeatherIcons(0xf0a5);
  static const moon_waning_gibbous_3 = WeatherIcons(0xf0a6);
  static const moon_waning_gibbous_4 = WeatherIcons(0xf0a7);
  static const moon_waning_gibbous_5 = WeatherIcons(0xf0a8);
  static const moon_waning_gibbous_6 = WeatherIcons(0xf0a9);
  static const moon_third_quarter = WeatherIcons(0xf0aa);
  static const moon_waning_crescent_1 = WeatherIcons(0xf0ab);
  static const moon_waning_crescent_2 = WeatherIcons(0xf0ac);
  static const moon_waning_crescent_3 = WeatherIcons(0xf0ad);
  static const moon_waning_crescent_4 = WeatherIcons(0xf0ae);
  static const moon_waning_crescent_5 = WeatherIcons(0xf0af);
  static const moon_waning_crescent_6 = WeatherIcons(0xf0b0);
  static const moon_alt_new = WeatherIcons(0xf0eb);
  static const moon_alt_waxing_crescent_1 = WeatherIcons(0xf0d0);
  static const moon_alt_waxing_crescent_2 = WeatherIcons(0xf0d1);
  static const moon_alt_waxing_crescent_3 = WeatherIcons(0xf0d2);
  static const moon_alt_waxing_crescent_4 = WeatherIcons(0xf0d3);
  static const moon_alt_waxing_crescent_5 = WeatherIcons(0xf0d4);
  static const moon_alt_waxing_crescent_6 = WeatherIcons(0xf0d5);
  static const moon_alt_first_quarter = WeatherIcons(0xf0d6);
  static const moon_alt_waxing_gibbous_1 = WeatherIcons(0xf0d7);
  static const moon_alt_waxing_gibbous_2 = WeatherIcons(0xf0d8);
  static const moon_alt_waxing_gibbous_3 = WeatherIcons(0xf0d9);
  static const moon_alt_waxing_gibbous_4 = WeatherIcons(0xf0da);
  static const moon_alt_waxing_gibbous_5 = WeatherIcons(0xf0db);
  static const moon_alt_waxing_gibbous_6 = WeatherIcons(0xf0dc);
  static const moon_alt_full = WeatherIcons(0xf0dd);
  static const moon_alt_waning_gibbous_1 = WeatherIcons(0xf0de);
  static const moon_alt_waning_gibbous_2 = WeatherIcons(0xf0df);
  static const moon_alt_waning_gibbous_3 = WeatherIcons(0xf0e0);
  static const moon_alt_waning_gibbous_4 = WeatherIcons(0xf0e1);
  static const moon_alt_waning_gibbous_5 = WeatherIcons(0xf0e2);
  static const moon_alt_waning_gibbous_6 = WeatherIcons(0xf0e3);
  static const moon_alt_third_quarter = WeatherIcons(0xf0e4);
  static const moon_alt_waning_crescent_1 = WeatherIcons(0xf0e5);
  static const moon_alt_waning_crescent_2 = WeatherIcons(0xf0e6);
  static const moon_alt_waning_crescent_3 = WeatherIcons(0xf0e7);
  static const moon_alt_waning_crescent_4 = WeatherIcons(0xf0e8);
  static const moon_alt_waning_crescent_5 = WeatherIcons(0xf0e9);
  static const moon_alt_waning_crescent_6 = WeatherIcons(0xf0ea);
  static const moon_0 = WeatherIcons(0xf095);
  static const moon_1 = WeatherIcons(0xf096);
  static const moon_2 = WeatherIcons(0xf097);
  static const moon_3 = WeatherIcons(0xf098);
  static const moon_4 = WeatherIcons(0xf099);
  static const moon_5 = WeatherIcons(0xf09a);
  static const moon_6 = WeatherIcons(0xf09b);
  static const moon_7 = WeatherIcons(0xf09c);
  static const moon_8 = WeatherIcons(0xf09d);
  static const moon_9 = WeatherIcons(0xf09e);
  static const moon_10 = WeatherIcons(0xf09f);
  static const moon_11 = WeatherIcons(0xf0a0);
  static const moon_12 = WeatherIcons(0xf0a1);
  static const moon_13 = WeatherIcons(0xf0a2);
  static const moon_14 = WeatherIcons(0xf0a3);
  static const moon_15 = WeatherIcons(0xf0a4);
  static const moon_16 = WeatherIcons(0xf0a5);
  static const moon_17 = WeatherIcons(0xf0a6);
  static const moon_18 = WeatherIcons(0xf0a7);
  static const moon_19 = WeatherIcons(0xf0a8);
  static const moon_20 = WeatherIcons(0xf0a9);
  static const moon_21 = WeatherIcons(0xf0aa);
  static const moon_22 = WeatherIcons(0xf0ab);
  static const moon_23 = WeatherIcons(0xf0ac);
  static const moon_24 = WeatherIcons(0xf0ad);
  static const moon_25 = WeatherIcons(0xf0ae);
  static const moon_26 = WeatherIcons(0xf0af);
  static const moon_27 = WeatherIcons(0xf0b0);
  static const time_1 = WeatherIcons(0xf08a);
  static const time_2 = WeatherIcons(0xf08b);
  static const time_3 = WeatherIcons(0xf08c);
  static const time_4 = WeatherIcons(0xf08d);
  static const time_5 = WeatherIcons(0xf08e);
  static const time_6 = WeatherIcons(0xf08f);
  static const time_7 = WeatherIcons(0xf090);
  static const time_8 = WeatherIcons(0xf091);
  static const time_9 = WeatherIcons(0xf092);
  static const time_10 = WeatherIcons(0xf093);
  static const time_11 = WeatherIcons(0xf094);
  static const time_12 = WeatherIcons(0xf089);
  static const direction_up = WeatherIcons(0xf058);
  static const direction_up_right = WeatherIcons(0xf057);
  static const direction_right = WeatherIcons(0xf04d);
  static const direction_down_right = WeatherIcons(0xf088);
  static const direction_down = WeatherIcons(0xf044);
  static const direction_down_left = WeatherIcons(0xf043);
  static const direction_left = WeatherIcons(0xf048);
  static const direction_up_left = WeatherIcons(0xf087);
  static const wind_beaufort_0 = WeatherIcons(0xf0b7);
  static const wind_beaufort_1 = WeatherIcons(0xf0b8);
  static const wind_beaufort_2 = WeatherIcons(0xf0b9);
  static const wind_beaufort_3 = WeatherIcons(0xf0ba);
  static const wind_beaufort_4 = WeatherIcons(0xf0bb);
  static const wind_beaufort_5 = WeatherIcons(0xf0bc);
  static const wind_beaufort_6 = WeatherIcons(0xf0bd);
  static const wind_beaufort_7 = WeatherIcons(0xf0be);
  static const wind_beaufort_8 = WeatherIcons(0xf0bf);
  static const wind_beaufort_9 = WeatherIcons(0xf0c0);
  static const wind_beaufort_10 = WeatherIcons(0xf0c1);
  static const wind_beaufort_11 = WeatherIcons(0xf0c2);
  static const wind_beaufort_12 = WeatherIcons(0xf0c3);
  static const yahoo_0 = WeatherIcons(0xf056);
  static const yahoo_1 = WeatherIcons(0xf00e);
  static const yahoo_2 = WeatherIcons(0xf073);
  static const yahoo_3 = WeatherIcons(0xf01e);
  static const yahoo_4 = WeatherIcons(0xf01e);
  static const yahoo_5 = WeatherIcons(0xf017);
  static const yahoo_6 = WeatherIcons(0xf017);
  static const yahoo_7 = WeatherIcons(0xf017);
  static const yahoo_8 = WeatherIcons(0xf015);
  static const yahoo_9 = WeatherIcons(0xf01a);
  static const yahoo_10 = WeatherIcons(0xf015);
  static const yahoo_11 = WeatherIcons(0xf01a);
  static const yahoo_12 = WeatherIcons(0xf01a);
  static const yahoo_13 = WeatherIcons(0xf01b);
  static const yahoo_14 = WeatherIcons(0xf00a);
  static const yahoo_15 = WeatherIcons(0xf064);
  static const yahoo_16 = WeatherIcons(0xf01b);
  static const yahoo_17 = WeatherIcons(0xf015);
  static const yahoo_18 = WeatherIcons(0xf017);
  static const yahoo_19 = WeatherIcons(0xf063);
  static const yahoo_20 = WeatherIcons(0xf014);
  static const yahoo_21 = WeatherIcons(0xf021);
  static const yahoo_22 = WeatherIcons(0xf062);
  static const yahoo_23 = WeatherIcons(0xf050);
  static const yahoo_24 = WeatherIcons(0xf050);
  static const yahoo_25 = WeatherIcons(0xf076);
  static const yahoo_26 = WeatherIcons(0xf013);
  static const yahoo_27 = WeatherIcons(0xf031);
  static const yahoo_28 = WeatherIcons(0xf002);
  static const yahoo_29 = WeatherIcons(0xf031);
  static const yahoo_30 = WeatherIcons(0xf002);
  static const yahoo_31 = WeatherIcons(0xf02e);
  static const yahoo_32 = WeatherIcons(0xf00d);
  static const yahoo_33 = WeatherIcons(0xf083);
  static const yahoo_34 = WeatherIcons(0xf00c);
  static const yahoo_35 = WeatherIcons(0xf017);
  static const yahoo_36 = WeatherIcons(0xf072);
  static const yahoo_37 = WeatherIcons(0xf00e);
  static const yahoo_38 = WeatherIcons(0xf00e);
  static const yahoo_39 = WeatherIcons(0xf00e);
  static const yahoo_40 = WeatherIcons(0xf01a);
  static const yahoo_41 = WeatherIcons(0xf064);
  static const yahoo_42 = WeatherIcons(0xf01b);
  static const yahoo_43 = WeatherIcons(0xf064);
  static const yahoo_44 = WeatherIcons(0xf00c);
  static const yahoo_45 = WeatherIcons(0xf00e);
  static const yahoo_46 = WeatherIcons(0xf01b);
  static const yahoo_47 = WeatherIcons(0xf00e);
  static const yahoo_3200 = WeatherIcons(0xf077);
  static const forecast_io_clear_day = WeatherIcons(0xf00d);
  static const forecast_io_clear_night = WeatherIcons(0xf02e);
  static const forecast_io_rain = WeatherIcons(0xf019);
  static const forecast_io_snow = WeatherIcons(0xf01b);
  static const forecast_io_sleet = WeatherIcons(0xf0b5);
  static const forecast_io_wind = WeatherIcons(0xf050);
  static const forecast_io_fog = WeatherIcons(0xf014);
  static const forecast_io_cloudy = WeatherIcons(0xf013);
  static const forecast_io_partly_cloudy_day = WeatherIcons(0xf002);
  static const forecast_io_partly_cloudy_night = WeatherIcons(0xf031);
  static const forecast_io_hail = WeatherIcons(0xf015);
  static const forecast_io_thunderstorm = WeatherIcons(0xf01e);
  static const forecast_io_tornado = WeatherIcons(0xf056);
  static const wmo4680_00wmo4680_0 = WeatherIcons(0xf055);
  static const wmo4680_01wmo4680_1 = WeatherIcons(0xf013);
  static const wmo4680_02wmo4680_2 = WeatherIcons(0xf055);
  static const wmo4680_03wmo4680_3 = WeatherIcons(0xf013);
  static const wmo4680_04wmo4680_4 = WeatherIcons(0xf014);
  static const wmo4680_05wmo4680_5 = WeatherIcons(0xf014);
  static const wmo4680_10 = WeatherIcons(0xf014);
  static const wmo4680_11 = WeatherIcons(0xf014);
  static const wmo4680_12 = WeatherIcons(0xf016);
  static const wmo4680_18 = WeatherIcons(0xf050);
  static const wmo4680_20 = WeatherIcons(0xf014);
  static const wmo4680_21 = WeatherIcons(0xf017);
  static const wmo4680_22 = WeatherIcons(0xf017);
  static const wmo4680_23 = WeatherIcons(0xf019);
  static const wmo4680_24 = WeatherIcons(0xf01b);
  static const wmo4680_25 = WeatherIcons(0xf015);
  static const wmo4680_26 = WeatherIcons(0xf01e);
  static const wmo4680_27 = WeatherIcons(0xf063);
  static const wmo4680_28 = WeatherIcons(0xf063);
  static const wmo4680_29 = WeatherIcons(0xf063);
  static const wmo4680_30 = WeatherIcons(0xf014);
  static const wmo4680_31 = WeatherIcons(0xf014);
  static const wmo4680_32 = WeatherIcons(0xf014);
  static const wmo4680_33 = WeatherIcons(0xf014);
  static const wmo4680_34 = WeatherIcons(0xf014);
  static const wmo4680_35 = WeatherIcons(0xf014);
  static const wmo4680_40 = WeatherIcons(0xf017);
  static const wmo4680_41 = WeatherIcons(0xf01c);
  static const wmo4680_42 = WeatherIcons(0xf019);
  static const wmo4680_43 = WeatherIcons(0xf01c);
  static const wmo4680_44 = WeatherIcons(0xf019);
  static const wmo4680_45 = WeatherIcons(0xf015);
  static const wmo4680_46 = WeatherIcons(0xf015);
  static const wmo4680_47 = WeatherIcons(0xf01b);
  static const wmo4680_48 = WeatherIcons(0xf01b);
  static const wmo4680_50 = WeatherIcons(0xf01c);
  static const wmo4680_51 = WeatherIcons(0xf01c);
  static const wmo4680_52 = WeatherIcons(0xf019);
  static const wmo4680_53 = WeatherIcons(0xf019);
  static const wmo4680_54 = WeatherIcons(0xf076);
  static const wmo4680_55 = WeatherIcons(0xf076);
  static const wmo4680_56 = WeatherIcons(0xf076);
  static const wmo4680_57 = WeatherIcons(0xf01c);
  static const wmo4680_58 = WeatherIcons(0xf019);
  static const wmo4680_60 = WeatherIcons(0xf01c);
  static const wmo4680_61 = WeatherIcons(0xf01c);
  static const wmo4680_62 = WeatherIcons(0xf019);
  static const wmo4680_63 = WeatherIcons(0xf019);
  static const wmo4680_64 = WeatherIcons(0xf015);
  static const wmo4680_65 = WeatherIcons(0xf015);
  static const wmo4680_66 = WeatherIcons(0xf015);
  static const wmo4680_67 = WeatherIcons(0xf017);
  static const wmo4680_68 = WeatherIcons(0xf017);
  static const wmo4680_70 = WeatherIcons(0xf01b);
  static const wmo4680_71 = WeatherIcons(0xf01b);
  static const wmo4680_72 = WeatherIcons(0xf01b);
  static const wmo4680_73 = WeatherIcons(0xf01b);
  static const wmo4680_74 = WeatherIcons(0xf076);
  static const wmo4680_75 = WeatherIcons(0xf076);
  static const wmo4680_76 = WeatherIcons(0xf076);
  static const wmo4680_77 = WeatherIcons(0xf01b);
  static const wmo4680_78 = WeatherIcons(0xf076);
  static const wmo4680_80 = WeatherIcons(0xf019);
  static const wmo4680_81 = WeatherIcons(0xf01c);
  static const wmo4680_82 = WeatherIcons(0xf019);
  static const wmo4680_83 = WeatherIcons(0xf019);
  static const wmo4680_84 = WeatherIcons(0xf01d);
  static const wmo4680_85 = WeatherIcons(0xf017);
  static const wmo4680_86 = WeatherIcons(0xf017);
  static const wmo4680_87 = WeatherIcons(0xf017);
  static const wmo4680_89 = WeatherIcons(0xf015);
  static const wmo4680_90 = WeatherIcons(0xf016);
  static const wmo4680_91 = WeatherIcons(0xf01d);
  static const wmo4680_92 = WeatherIcons(0xf01e);
  static const wmo4680_93 = WeatherIcons(0xf01e);
  static const wmo4680_94 = WeatherIcons(0xf016);
  static const wmo4680_95 = WeatherIcons(0xf01e);
  static const wmo4680_96 = WeatherIcons(0xf01e);
  static const wmo4680_99 = WeatherIcons(0xf056);
  static const owm_200 = WeatherIcons(0xf01e);
  static const owm_201 = WeatherIcons(0xf01e);
  static const owm_202 = WeatherIcons(0xf01e);
  static const owm_210 = WeatherIcons(0xf016);
  static const owm_211 = WeatherIcons(0xf016);
  static const owm_212 = WeatherIcons(0xf016);
  static const owm_221 = WeatherIcons(0xf016);
  static const owm_230 = WeatherIcons(0xf01e);
  static const owm_231 = WeatherIcons(0xf01e);
  static const owm_232 = WeatherIcons(0xf01e);
  static const owm_300 = WeatherIcons(0xf01c);
  static const owm_301 = WeatherIcons(0xf01c);
  static const owm_302 = WeatherIcons(0xf019);
  static const owm_310 = WeatherIcons(0xf017);
  static const owm_311 = WeatherIcons(0xf019);
  static const owm_312 = WeatherIcons(0xf019);
  static const owm_313 = WeatherIcons(0xf01a);
  static const owm_314 = WeatherIcons(0xf019);
  static const owm_321 = WeatherIcons(0xf01c);
  static const owm_500 = WeatherIcons(0xf01c);
  static const owm_501 = WeatherIcons(0xf019);
  static const owm_502 = WeatherIcons(0xf019);
  static const owm_503 = WeatherIcons(0xf019);
  static const owm_504 = WeatherIcons(0xf019);
  static const owm_511 = WeatherIcons(0xf017);
  static const owm_520 = WeatherIcons(0xf01a);
  static const owm_521 = WeatherIcons(0xf01a);
  static const owm_522 = WeatherIcons(0xf01a);
  static const owm_531 = WeatherIcons(0xf01d);
  static const owm_600 = WeatherIcons(0xf01b);
  static const owm_601 = WeatherIcons(0xf01b);
  static const owm_602 = WeatherIcons(0xf0b5);
  static const owm_611 = WeatherIcons(0xf017);
  static const owm_612 = WeatherIcons(0xf017);
  static const owm_615 = WeatherIcons(0xf017);
  static const owm_616 = WeatherIcons(0xf017);
  static const owm_620 = WeatherIcons(0xf017);
  static const owm_621 = WeatherIcons(0xf01b);
  static const owm_622 = WeatherIcons(0xf01b);
  static const owm_701 = WeatherIcons(0xf01a);
  static const owm_711 = WeatherIcons(0xf062);
  static const owm_721 = WeatherIcons(0xf0b6);
  static const owm_731 = WeatherIcons(0xf063);
  static const owm_741 = WeatherIcons(0xf014);
  static const owm_761 = WeatherIcons(0xf063);
  static const owm_762 = WeatherIcons(0xf063);
  static const owm_771 = WeatherIcons(0xf011);
  static const owm_781 = WeatherIcons(0xf056);
  static const owm_800 = WeatherIcons(0xf00d);
  static const owm_801 = WeatherIcons(0xf011);
  static const owm_802 = WeatherIcons(0xf011);
  static const owm_803 = WeatherIcons(0xf012);
  static const owm_804 = WeatherIcons(0xf013);
  static const owm_900 = WeatherIcons(0xf056);
  static const owm_901 = WeatherIcons(0xf01d);
  static const owm_902 = WeatherIcons(0xf073);
  static const owm_903 = WeatherIcons(0xf076);
  static const owm_904 = WeatherIcons(0xf072);
  static const owm_905 = WeatherIcons(0xf021);
  static const owm_906 = WeatherIcons(0xf015);
  static const owm_957 = WeatherIcons(0xf050);
  static const owm_day_200 = WeatherIcons(0xf010);
  static const owm_day_201 = WeatherIcons(0xf010);
  static const owm_day_202 = WeatherIcons(0xf010);
  static const owm_day_210 = WeatherIcons(0xf005);
  static const owm_day_211 = WeatherIcons(0xf005);
  static const owm_day_212 = WeatherIcons(0xf005);
  static const owm_day_221 = WeatherIcons(0xf005);
  static const owm_day_230 = WeatherIcons(0xf010);
  static const owm_day_231 = WeatherIcons(0xf010);
  static const owm_day_232 = WeatherIcons(0xf010);
  static const owm_day_300 = WeatherIcons(0xf00b);
  static const owm_day_301 = WeatherIcons(0xf00b);
  static const owm_day_302 = WeatherIcons(0xf008);
  static const owm_day_310 = WeatherIcons(0xf008);
  static const owm_day_311 = WeatherIcons(0xf008);
  static const owm_day_312 = WeatherIcons(0xf008);
  static const owm_day_313 = WeatherIcons(0xf008);
  static const owm_day_314 = WeatherIcons(0xf008);
  static const owm_day_321 = WeatherIcons(0xf00b);
  static const owm_day_500 = WeatherIcons(0xf00b);
  static const owm_day_501 = WeatherIcons(0xf008);
  static const owm_day_502 = WeatherIcons(0xf008);
  static const owm_day_503 = WeatherIcons(0xf008);
  static const owm_day_504 = WeatherIcons(0xf008);
  static const owm_day_511 = WeatherIcons(0xf006);
  static const owm_day_520 = WeatherIcons(0xf009);
  static const owm_day_521 = WeatherIcons(0xf009);
  static const owm_day_522 = WeatherIcons(0xf009);
  static const owm_day_531 = WeatherIcons(0xf00e);
  static const owm_day_600 = WeatherIcons(0xf00a);
  static const owm_day_601 = WeatherIcons(0xf0b2);
  static const owm_day_602 = WeatherIcons(0xf00a);
  static const owm_day_611 = WeatherIcons(0xf006);
  static const owm_day_612 = WeatherIcons(0xf006);
  static const owm_day_615 = WeatherIcons(0xf006);
  static const owm_day_616 = WeatherIcons(0xf006);
  static const owm_day_620 = WeatherIcons(0xf006);
  static const owm_day_621 = WeatherIcons(0xf00a);
  static const owm_day_622 = WeatherIcons(0xf00a);
  static const owm_day_701 = WeatherIcons(0xf009);
  static const owm_day_711 = WeatherIcons(0xf062);
  static const owm_day_721 = WeatherIcons(0xf0b6);
  static const owm_day_731 = WeatherIcons(0xf063);
  static const owm_day_741 = WeatherIcons(0xf003);
  static const owm_day_761 = WeatherIcons(0xf063);
  static const owm_day_762 = WeatherIcons(0xf063);
  static const owm_day_781 = WeatherIcons(0xf056);
  static const owm_day_800 = WeatherIcons(0xf00d);
  static const owm_day_801 = WeatherIcons(0xf000);
  static const owm_day_802 = WeatherIcons(0xf000);
  static const owm_day_803 = WeatherIcons(0xf000);
  static const owm_day_804 = WeatherIcons(0xf00c);
  static const owm_day_900 = WeatherIcons(0xf056);
  static const owm_day_902 = WeatherIcons(0xf073);
  static const owm_day_903 = WeatherIcons(0xf076);
  static const owm_day_904 = WeatherIcons(0xf072);
  static const owm_day_906 = WeatherIcons(0xf004);
  static const owm_day_957 = WeatherIcons(0xf050);
  static const owm_night_200 = WeatherIcons(0xf02d);
  static const owm_night_201 = WeatherIcons(0xf02d);
  static const owm_night_202 = WeatherIcons(0xf02d);
  static const owm_night_210 = WeatherIcons(0xf025);
  static const owm_night_211 = WeatherIcons(0xf025);
  static const owm_night_212 = WeatherIcons(0xf025);
  static const owm_night_221 = WeatherIcons(0xf025);
  static const owm_night_230 = WeatherIcons(0xf02d);
  static const owm_night_231 = WeatherIcons(0xf02d);
  static const owm_night_232 = WeatherIcons(0xf02d);
  static const owm_night_300 = WeatherIcons(0xf02b);
  static const owm_night_301 = WeatherIcons(0xf02b);
  static const owm_night_302 = WeatherIcons(0xf028);
  static const owm_night_310 = WeatherIcons(0xf028);
  static const owm_night_311 = WeatherIcons(0xf028);
  static const owm_night_312 = WeatherIcons(0xf028);
  static const owm_night_313 = WeatherIcons(0xf028);
  static const owm_night_314 = WeatherIcons(0xf028);
  static const owm_night_321 = WeatherIcons(0xf02b);
  static const owm_night_500 = WeatherIcons(0xf02b);
  static const owm_night_501 = WeatherIcons(0xf028);
  static const owm_night_502 = WeatherIcons(0xf028);
  static const owm_night_503 = WeatherIcons(0xf028);
  static const owm_night_504 = WeatherIcons(0xf028);
  static const owm_night_511 = WeatherIcons(0xf026);
  static const owm_night_520 = WeatherIcons(0xf029);
  static const owm_night_521 = WeatherIcons(0xf029);
  static const owm_night_522 = WeatherIcons(0xf029);
  static const owm_night_531 = WeatherIcons(0xf02c);
  static const owm_night_600 = WeatherIcons(0xf02a);
  static const owm_night_601 = WeatherIcons(0xf0b4);
  static const owm_night_602 = WeatherIcons(0xf02a);
  static const owm_night_611 = WeatherIcons(0xf026);
  static const owm_night_612 = WeatherIcons(0xf026);
  static const owm_night_615 = WeatherIcons(0xf026);
  static const owm_night_616 = WeatherIcons(0xf026);
  static const owm_night_620 = WeatherIcons(0xf026);
  static const owm_night_621 = WeatherIcons(0xf02a);
  static const owm_night_622 = WeatherIcons(0xf02a);
  static const owm_night_701 = WeatherIcons(0xf029);
  static const owm_night_711 = WeatherIcons(0xf062);
  static const owm_night_721 = WeatherIcons(0xf0b6);
  static const owm_night_731 = WeatherIcons(0xf063);
  static const owm_night_741 = WeatherIcons(0xf04a);
  static const owm_night_761 = WeatherIcons(0xf063);
  static const owm_night_762 = WeatherIcons(0xf063);
  static const owm_night_781 = WeatherIcons(0xf056);
  static const owm_night_800 = WeatherIcons(0xf02e);
  static const owm_night_801 = WeatherIcons(0xf022);
  static const owm_night_802 = WeatherIcons(0xf022);
  static const owm_night_803 = WeatherIcons(0xf022);
  static const owm_night_804 = WeatherIcons(0xf086);
  static const owm_night_900 = WeatherIcons(0xf056);
  static const owm_night_902 = WeatherIcons(0xf073);
  static const owm_night_903 = WeatherIcons(0xf076);
  static const owm_night_904 = WeatherIcons(0xf072);
  static const owm_night_906 = WeatherIcons(0xf024);
  static const owm_night_957 = WeatherIcons(0xf050);
  static const wu_chanceflurries = WeatherIcons(0xf064);
  static const wu_chancerain = WeatherIcons(0xf019);
  static const wu_chancesleat = WeatherIcons(0xf0b5);
  static const wu_chancesnow = WeatherIcons(0xf01b);
  static const wu_chancetstorms = WeatherIcons(0xf01e);
  static const wu_clear = WeatherIcons(0xf00d);
  static const wu_cloudy = WeatherIcons(0xf002);
  static const wu_flurries = WeatherIcons(0xf064);
  static const wu_hazy = WeatherIcons(0xf0b6);
  static const wu_mostlycloudy = WeatherIcons(0xf002);
  static const wu_mostlysunny = WeatherIcons(0xf00d);
  static const wu_partlycloudy = WeatherIcons(0xf002);
  static const wu_partlysunny = WeatherIcons(0xf00d);
  static const wu_rain = WeatherIcons(0xf01a);
  static const wu_sleat = WeatherIcons(0xf0b5);
  static const wu_snow = WeatherIcons(0xf01b);
  static const wu_sunny = WeatherIcons(0xf00d);
  static const wu_tstorms = WeatherIcons(0xf01e);
}
