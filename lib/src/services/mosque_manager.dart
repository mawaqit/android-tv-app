import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mixins/weather_mixin.dart';

import 'mixins/audio_mixin.dart';
import 'mixins/connectivity_mixin.dart';

final mawaqitApi = "https://mawaqit.net/api/2.0";

const kAfterAdhanHadithDuration = Duration(minutes: 1);
const kAdhanBeforeFajrDuration = Duration(minutes: 10);

const kAzkarDuration = const Duration(seconds: 140);

class MosqueManager extends ChangeNotifier
    with WeatherMixin, AudioMixin, MosqueHelpersMixin, NetworkConnectivity {
  final sharedPref = SharedPref();

  // String? mosqueId;
  String? mosqueUUID;

  bool get loaded => mosque != null && times != null && mosqueConfig != null;

  Mosque? mosque;
  Times? times;
  MosqueConfig? mosqueConfig;

  StreamSubscription? _mosqueSubscription;
  StreamSubscription? _timesSubscription;
  StreamSubscription? _configSubscription;

  HomeActiveWorkflow workflow = HomeActiveWorkflow.normal;

  /// get current home url
  String buildUrl(String languageCode) {
    // if (mosqueId != null) return 'https://mawaqit.net/$languageCode/id/$mosqueId?view=desktop';
    // if (mosqueSlug != null) return 'https://mawaqit.net/$languageCode/$mosqueSlug?view=desktop';
    return 'https://mawaqit.net/$languageCode/id/${mosque?.id}?view=desktop';
  }

  Future<void> init() async {
    await Api.init();
    await loadFromLocale();
    // subscribeToTime();
    listenToConnectivity();

    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<void> setMosqueUUid(String uuid) async {
    try {
      await fetchMosque(uuid);
      calculateActiveWorkflow();

      _saveToLocale();
      // print("mosque url${mosque?.url}");
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _saveToLocale() async {
    // await sharedPref.save('mosqueId', mosqueId);
    await sharedPref.save('mosqueUUId', mosqueUUID);
    // sharedPref.save('mosqueSlug', mosqueSlug);
  }

  Future<void> loadFromLocale() async {
    // mosqueId = await sharedPref.read('mosqueId');
    mosqueUUID = await sharedPref.read('mosqueUUId');
    if (mosqueUUID != null) {
      await fetchMosque(mosqueUUID!);
      calculateActiveWorkflow();
    }
  }

  Future<void> fetchMosque(String uuid) async {
    final completer = Completer();

    _mosqueSubscription?.cancel();
    _timesSubscription?.cancel();
    _configSubscription?.cancel();

    bool isDone() =>
        times != null &&
        mosqueConfig != null &&
        mosque != null &&
        !completer.isCompleted;

    /// if getting item returns an error
    onItemError(e, d) {}

    _mosqueSubscription = Api.getMosqueStream(uuid).listen((event) {
      mosque = event;
      loadWeather(mosque!);
      notifyListeners();

      if (isDone()) completer.complete();
    }, onError: (e, stack) {
      debugPrintStack(stackTrace: stack, label: e.toString());
      if (!completer.isCompleted) completer.completeError(e, stack);

      mosque = null;
      notifyListeners();
    });

    _timesSubscription = Api.getMosqueTimesStream(uuid).listen((event) {
      times = event;
      notifyListeners();

      if (isDone()) completer.complete();
    }, onError: (e, stack) {
      debugPrintStack(stackTrace: stack, label: e.toString());
      if (!completer.isCompleted) completer.completeError(e, stack);

      times = null;
      notifyListeners();
    });

    _configSubscription = Api.getMosqueConfigStream(uuid).listen((event) {
      mosqueConfig = event;
      notifyListeners();

      if (isDone()) completer.complete();
    }, onError: (e, stack) {
      debugPrintStack(stackTrace: stack, label: e.toString());
      if (!completer.isCompleted) completer.completeError(e, stack);

      mosqueConfig = null;
      notifyListeners();
    });

    mosqueUUID = uuid;

    return completer.future;
  }

  Future<Mosque> searchMosqueWithId(String mosqueId) => Api.searchMosqueWithId(mosqueId);

  Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async =>
      Api.searchMosques(mosque, page: page);

//todo handle page and get more
  Future<List<Mosque>> searchWithGps() async {
    final position =
        await getCurrentLocation().catchError((e) => throw GpsError());

    final url = Uri.parse(
        "$mawaqitApi/mosque/search?lat=${position.latitude}&lon=${position.longitude}");
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
    var enabled = await GeolocatorPlatform.instance
        .isLocationServiceEnabled()
        .timeout(Duration(seconds: 5));

    if (!enabled) {
      enabled = await GeolocatorPlatform.instance.openLocationSettings();
    }
    if (!enabled) throw GpsError();

    final permission = await GeolocatorPlatform.instance.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) throw GpsError();

    return await GeolocatorPlatform.instance.getCurrentPosition();
  }
}

/// user for invalid mosque id-slug
class InvalidMosqueId implements Exception {}

class GpsError implements Exception {}
