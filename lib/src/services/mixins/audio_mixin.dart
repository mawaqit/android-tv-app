import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

mixin AudioMixin on ChangeNotifier {
  abstract MosqueConfig? mosqueConfig;

  // Abstract getter that will be implemented by classes that use this mixin
  bool get typeIsMosque;

  Duration getAdhanDuration(bool isFajrPray) {
    // If mosqueConfig is null, return a default duration
    if (mosqueConfig == null) {
      return Duration(seconds: 150); // Default duration if config is missing
    }

    String? adhanName = mosqueConfig?.adhanVoice;

    // If mosque type, use the duration from API
    if (typeIsMosque && mosqueConfig?.adhanDuration != null) {
      return Duration(seconds: mosqueConfig!.adhanDuration!);
    }

    // For home type or if adhanDuration is not set, use predefined durations
    Duration duration = Duration(seconds: mosqueConfig?.adhanDuration ?? 180);

    if (isFajrPray && adhanName != null) {
      adhanName = adhanName + '-fajr';
    }

    switch (adhanName) {
      case "adhan-afassy":
        duration = Duration(seconds: 154 + 5);
        break;
      case "adhan-afassy-fajr":
        duration = Duration(seconds: 182 + 5);
        break;
      case "adhan-algeria":
        duration = Duration(seconds: 173 + 5);
        break;
      case "adhan-egypt":
        duration = Duration(seconds: 221 + 5);
        break;
      case "adhan-egypt-fajr":
        duration = Duration(seconds: 245 + 5);
        break;
      case "adhan-madina":
        duration = Duration(seconds: 213 + 5);
        break;
      case "adhan-madina-fajr":
        duration = Duration(seconds: 253 + 5);
        break;
      case "adhan-maquah":
        duration = Duration(seconds: 203 + 5);

        break;
      case "adhan-maquah-fajr":
        duration = Duration(seconds: 251 + 5);
        break;
      case "adhan-quds":
        duration = Duration(seconds: 185 + 5);
        break;
    }

    return duration;
  }
}
