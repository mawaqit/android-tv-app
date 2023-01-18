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

final mawaqitApi = "https://mawaqit.net/api/2.0";

const kAfterAdhanHadithDuration = Duration(minutes: 1);
const kAdhanBeforeFajrDuration = Duration(minutes: 10);

const kAzkarDuration = const Duration(minutes: 2);

class MosqueManager extends ChangeNotifier with WeatherMixin, AudioMixin, MosqueHelpersMixin {
  final sharedPref = SharedPref();

  // String? mosqueId;
  String? mosqueUUID;

  Mosque? mosque;
  Times? times;
  MosqueConfig? mosqueConfig;

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
    Future.delayed(Duration(milliseconds: 500)).then((value) => calculateActiveWorkflow());

    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<void> setMosqueUUid(String uuid) async {
    try {
      mosque = await Api.getMosque(uuid);
      times = await Api.getMosqueTimes(uuid);
      mosqueConfig = await Api.getMosqueConfig(uuid);
      await loadWeather(mosque!);

      // mosqueId = mosque!.id.toString();
      mosqueUUID = mosque!.uuid!;

      _saveToLocale();
      notifyListeners();
      print("mosque url${mosque?.url}");
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
    if (mosqueUUID != null) await fetchMosque();
  }

  fetchMosque() async {
    if (mosqueUUID != null) {
      mosque = await Api.getMosque(mosqueUUID!);
      times = await Api.getMosqueTimes(mosqueUUID!);
      mosqueConfig = await Api.getMosqueConfig(mosqueUUID!);

      // get weather data
      await loadWeather(mosque!);
    }
  }

  Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async => Api.searchMosques(mosque, page: page);

//todo handle page and get more
  Future<List<Mosque>> searchWithGps() async {
    final position = await getCurrentLocation().catchError((e) => throw GpsError());

    final url = Uri.parse("$mawaqitApi/mosque/search?lat=${position.latitude}&lon=${position.longitude}");
    Map<String, String> requestHeaders = {
      // "Api-Access-Token": mawaqitApiToken,
    };
    final response = await http.get(url, headers: requestHeaders);
    print(response.body);
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
    // return Position(
    //   longitude: -1.3565692,
    //   latitude: 34.8659187,
    //   timestamp: null,
    //   accuracy: 1,
    //   altitude: 31.0,
    //   heading: 0,
    //   speed: 0,
    //   speedAccuracy: 0,
    // );
    var enabled = await GeolocatorPlatform.instance.isLocationServiceEnabled().timeout(Duration(seconds: 5));

    if (!enabled) {
      enabled = await GeolocatorPlatform.instance.openLocationSettings();
    }
    if (!enabled) throw GpsError();

    final permission = await GeolocatorPlatform.instance.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) throw GpsError();

    return await GeolocatorPlatform.instance.getCurrentPosition();
  }
}

/// user for invalid mosque id-slug
class InvalidMosqueId implements Exception {}

class GpsError implements Exception {}
