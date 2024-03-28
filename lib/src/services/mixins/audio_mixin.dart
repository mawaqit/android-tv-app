import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

mixin AudioMixin on ChangeNotifier {
  abstract MosqueConfig? mosqueConfig;

  Duration getAdhanDuration() {
    String? adhanName = mosqueConfig?.adhanVoice;
    Duration duration = Duration(seconds: mosqueConfig!.adhanDuration!);

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
