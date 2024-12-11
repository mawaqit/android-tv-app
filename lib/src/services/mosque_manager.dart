import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/domain/model/failure/mosque/mosque_failure.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/PerformanceHelper.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_cache.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mixins/weather_mixin.dart';
import 'package:mawaqit/src/services/storage_manager.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_source/device_info_data_source.dart';
import '../helpers/AppDate.dart';
import 'mixins/audio_mixin.dart';
import 'mixins/connectivity_mixin.dart';

final mawaqitApi = "https://mawaqit.net/api/2.0";

const kAzkarDuration = const Duration(seconds: 140);

class MosqueManager extends ChangeNotifier with WeatherMixin, AudioMixin, MosqueHelpersMixin, NetworkConnectivity {
  final sharedPref = SharedPref();

  // String? mosqueId;
  String? mosqueUUID;

  bool _flashEnabled = false;

  bool get flashEnabled => _flashEnabled;

  void _updateFlashEnabled() {
    if (mosque != null) {
      final startDate = DateTime.tryParse(mosque!.flash?.startDate ?? 'x');
      final endDate = DateTime.tryParse(mosque!.flash?.endDate ?? 'x');
      final currentDate = AppDateTime.now();

      DateTime? endOfDay;
      if (endDate != null) {
        endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      }

      if (startDate == null && endDate == null) {
        _flashEnabled = true;
      } else if (startDate != null && endDate == null) {
        _flashEnabled = currentDate.isAfter(startDate) || currentDate.isAtSameMomentAs(startDate);
      } else if (startDate == null && endDate != null) {
        _flashEnabled = currentDate.isBefore(endOfDay!) || currentDate.isAtSameMomentAs(endOfDay);
      } else if (startDate != null && endDate != null) {
        _flashEnabled = currentDate.isAfter(startDate) && currentDate.isBefore(endOfDay!) ||
            currentDate.isAtSameMomentAs(startDate) ||
            currentDate.isAtSameMomentAs(endOfDay!);
      }
      notifyListeners();
    }
  }

  bool get loaded => mosque != null && times != null && mosqueConfig != null;

  Mosque? mosque;
  Times? times;
  MosqueConfig? mosqueConfig;
  bool isEventsSet = false;
  StreamSubscription? _mosqueSubscription;
  StreamSubscription? _timesSubscription;
  StreamSubscription? _configSubscription;
  bool isDeviceRooted = false;
  bool isToggleScreenActivated = false;
  int minuteBefore = 0;
  int minuteAfter = 0;
  bool isIshaFajrOnly = false;

  /// get current home url
  String buildUrl(String languageCode) {
    // if (mosqueId != null) return 'https://mawaqit.net/$languageCode/id/$mosqueId?view=desktop';
    // if (mosqueSlug != null) return 'https://mawaqit.net/$languageCode/$mosqueSlug?view=desktop';
    return 'https://mawaqit.net/$languageCode/id/${mosque?.id}?view=desktop';
  }

  static const String _minuteBeforeKey = 'selectedMinuteBefore';
  static const String _minuteAfterKey = 'selectedMinuteAfter';

  static Future<int> getMinuteBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minuteBeforeKey) ?? 10;
  }

  static Future<int> getMinuteAfter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minuteAfterKey) ?? 10;
  }

  static Future<bool> getisIshaFajr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
  }

  static Future<bool> checkRoot() async {
    try {
      final result = await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel).invokeMethod(
        TurnOnOffTvConstant.kCheckRoot,
      );
      return result;
    } catch (e, stack) {
      logger.e(e, stackTrace: stack);
      return false;
    }
  }

  Future<void> init() async {
    await Api.init();
    await loadFromLocale();
    listenToConnectivity();
    isDeviceRooted = await checkRoot();
    isToggleScreenActivated = await ToggleScreenFeature.getToggleFeatureState();
    isEventsSet = await ToggleScreenFeature.checkEventsScheduled();
    minuteBefore = await getMinuteBefore();
    minuteAfter = await getMinuteAfter();
    isIshaFajrOnly = await getisIshaFajr();
    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<void> setMosqueUUid(String uuid) async {
    try {
      await fetchMosque(uuid);
      await ToggleScreenFeature.saveScheduledEventsToLocale();

      _saveToLocale();
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _saveToLocale() async {
    logger.d("Saving into local");
    // await sharedPref.save('mosqueId', mosqueId);
    await sharedPref.save('mosqueUUId', mosqueUUID);
    // sharedPref.save('mosqueSlug', mosqueSlug);
  }

  static Future<String?> loadLocalUUID() async {
    final sharedPref = SharedPref();
    return await sharedPref.read('mosqueUUId');
  }

  Future<void> loadFromLocale() async {
    mosqueUUID = await sharedPref.read('mosqueUUId');
    if (mosqueUUID != null) {
      await fetchMosque(mosqueUUID!);
    }
  }

  /// this method responsible for
  /// - fetching mosque, times, config
  /// - request audio manager to precache voices
  /// - request mawaqit cache to precache images after first load
  /// - handle errors of response
  /// It will return a future that will be completed when all data is fetched and cached
  Future<void> fetchMosque(String uuid) async {
    _mosqueSubscription?.cancel();
    _timesSubscription?.cancel();
    _configSubscription?.cancel();

    /// if getting item returns an error
    onItemError(e, stack) async {
      logger.e(e, stackTrace: stack);
      bool hasCachedMosque = await sharedPref.read(MosqueManagerConstant.khasCachedMosque) ?? false;
      if (!hasCachedMosque) {
        mosque = null;
        notifyListeners();
      }
      throw e;
    }

    /// cache date before complete the [completer]
    Future<void> completeFuture() async {
      try {
        await Future.wait([
          AudioManager().precacheVoices(mosqueConfig!),
          preCacheImages(),
        ]);
      } catch (e, stack) {
        debugPrintStack(label: e.toString(), stackTrace: stack);
      }
    }

    final mosqueStream = Api.getMosqueStream(uuid).asBroadcastStream();
    final timesStream = Api.getMosqueTimesStream(uuid).asBroadcastStream();
    final configStream = Api.getMosqueConfigStream(uuid).asBroadcastStream();

    _mosqueSubscription = mosqueStream.listen(
      (e) async {
        mosque = e;
        await sharedPref.save(MosqueManagerConstant.khasCachedMosque, true);
        _updateFlashEnabled();
        notifyListeners();
      },
      onError: onItemError,
    );

    _timesSubscription = timesStream.listen(
      (e) {
        times = e;
        final today = useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();
        if (isDeviceRooted) {
          if (isToggleScreenActivated) {
            ToggleScreenFeature.getLastEventDate().then((lastEventDate) async {
              if (lastEventDate != null && lastEventDate.day != today.day) {
                isEventsSet = false; // Reset the flag if it's a new day
                await ToggleScreenFeature.cancelAllScheduledTimers();
                ToggleScreenFeature.toggleFeatureState(false);
                ToggleScreenFeature.checkEventsScheduled().then((_) {
                  if (!isEventsSet) {
                    ToggleScreenFeature.scheduleToggleScreen(
                      isIshaFajrOnly,
                      e.dayTimesStrings(today, salahOnly: false),
                      minuteBefore,
                      minuteAfter,
                    );
                    ToggleScreenFeature.toggleFeatureState(true);
                    ToggleScreenFeature.setLastEventDate(today);
                    isEventsSet = true;
                  }
                });
              }
            });
          }
        }

        notifyListeners();
      },
      onError: onItemError,
    );

    _configSubscription = configStream.listen(
      (e) {
        mosqueConfig = e;
        notifyListeners();
      },
      onError: onItemError,
    );

    /// wait for all streams to complete
    await Future.wait([
      mosqueStream.first.logPerformance('mosque'),
      timesStream.first.logPerformance('times'),
      configStream.first.logPerformance('config'),
    ]).logPerformance('Mosque data loader');
    await completeFuture();

    loadWeather(mosque!);

    mosqueUUID = uuid;
  }

  Future<Mosque> searchMosqueWithId(String mosqueId) => Api.searchMosqueWithId(mosqueId);

  Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async => Api.searchMosques(mosque, page: page);

//todo handle page and get more
  Future<List<Mosque>> searchWithGps() async {
    final position = await getCurrentLocation().catchError((e) => throw GpsError());

    final url = Uri.parse("$mawaqitApi/mosque/search?lat=${position.latitude}&lon=${position.longitude}");
    Map<String, String> requestHeaders = {
      // "Api-Access-Token": mawaqitApiToken,
    };
    final response = await http.get(url, headers: requestHeaders);
    // print(response.body);
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body);
      List<Mosque> mosques = [];

      for (var item in results) {
        try {
          mosques.add(Mosque.fromMap(item));
        } catch (e, stack) {
          debugPrintStack(label: e.toString(), stackTrace: stack);
        }
      }

      return mosques;
    } else {
      print(response.body);
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch mosque');
    }
  }

  Future<Position> getCurrentLocation() async {
    var enabled = await GeolocatorPlatform.instance.isLocationServiceEnabled().timeout(Duration(seconds: 5));

    if (!enabled) {
      enabled = await GeolocatorPlatform.instance.openLocationSettings();
    }
    if (!enabled) throw GpsError();

    final permission = await GeolocatorPlatform.instance.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) throw GpsError();

    return await GeolocatorPlatform.instance.getCurrentPosition();
  }

  /// handle pre caching for images
  /// Qr, mosque image, mosque logo, announcement image
  Future<void> preCacheImages() async {
    final images = [
      mosque?.image,
      mosque?.logo,
      mosque?.interiorPicture,
      mosque?.exteriorPicture,
      mosqueConfig?.motifUrl,
      kFooterQrLink,
      ...mosque?.announcements.map((e) => e.image).where((element) => element != null) ?? <String>[],
    ].where((e) => e != null).cast<String>();

    /// some images isn't existing anymore so we will ignore errors
    final futures = images.map((e) => MawaqitImageCache.cacheImage(e).catchError((e) {})).toList();
    await Future.wait(futures);
  }
}

/// user for invalid mosque id-slug
class InvalidMosqueId implements Exception {}

class GpsError implements Exception {}
