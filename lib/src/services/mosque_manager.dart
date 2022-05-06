import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/mosque.dart';

final mawaqitApi = "https://mawaqit.net/api/2.0";

class MosqueManager extends ChangeNotifier {
  final sharedPref = SharedPref();

  String? mosqueId;
  String? mosqueSlug;

  /// get current home url
  String buildUrl(String languageCode) {
    if (mosqueId != null) return 'https://mawaqit.net/$languageCode/id/$mosqueId?view=desktop';
    if (mosqueSlug != null) return 'https://mawaqit.net/$languageCode/$mosqueSlug?view=desktop';

    return '';
  }

  Future<void> init() async {
    await loadFromLocale();
    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<String> setMosqueId(String id) async {
    var url = 'https://mawaqit.net/en/id/$id?view=desktop';

    var value = await http.get(Uri.parse(url));

    if (value.statusCode != 200) {
      throw InvalidMosqueId();
    } else {
      AnalyticsWrapper.changeMosque(id);

      mosqueId = id;
      mosqueSlug = null;

      _saveToLocale();

      notifyListeners();
      return mosqueId!;
    }
  }

  /// update mosque id in the app and shared preference
  Future<String> setMosqueSlug(String slug) async {
    var url = 'https://mawaqit.net/en/$slug?view=desktop';

    var value = await http.get(Uri.parse(url));

    if (value.statusCode != 200) {
      throw InvalidMosqueId();
    } else {
      AnalyticsWrapper.changeMosque(slug);

      mosqueId = null;
      mosqueSlug = slug;

      _saveToLocale();
      notifyListeners();

      return slug;
    }
  }

  void _saveToLocale() {
    sharedPref.save('mosqueId', mosqueId);
    sharedPref.save('mosqueSlug', mosqueSlug);
  }

  Future<void> loadFromLocale() async {
    mosqueId = await sharedPref.read('mosqueId');
    mosqueSlug = await sharedPref.read('mosqueSlug');
  }

  Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async {
    final url = Uri.parse("$mawaqitApi/mosque/search?word=$mosque&page=$page");

    final response = await http.get(url);
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

/// cant access gps
class GpsError implements Exception {}
