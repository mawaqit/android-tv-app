import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/times.dart';

final mawaqitApi = "https://mawaqit.net/api/2.0";

class MosqueManager extends ChangeNotifier {
  final sharedPref = SharedPref();

  // String? mosqueId;
  String? mosqueUUID;

  Mosque? mosque;
  Times? times;

  final today = DateTime.now();

  List<String> iqamas() {
    return times!.iqamaCalendar[mosqueDate().month - 1][mosqueDate().day.toString()];
  }

  /// get the actual iqamaa time
  List<TimeOfDay> iqamasTimes() {
    final iqamas = this.iqamas();

    return [
      for (var i = 0; i < 5; i++) iqamas[i].toTimeOfDay() ?? iqamas[i].toTimeOffset(times!.times[i])!,
    ];
  }

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextIqamaIndex() {
    final now = TimeOfDay.fromDateTime(mosqueDate());
    final t = iqamasTimes();

    for (var i = 0; i < 5; i++) {
      final first = t[(i - 1) % 5];
      final second = t[i];

      if (now.between(first, second)) {
        return i;
      }
    }

    return -1;
  }

  String nextIqamaTime() => iqamas()[nextIqamaIndex()];

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextSalahIndex() {
    final t = times!.times.map((e) => e.toTimeOfDay()).toList();
    final now = TimeOfDay.fromDateTime(mosqueDate());

    for (var i = 0; i < times!.times.length; i++) {
      final first = t[(i - 1) % times!.times.length];
      final second = t[i];

      if (first == null || second == null) continue;

      if (now.between(first, second)) {
        return i;
      }
    }

    return -1;
  }

  String nextSalahTime() => times!.times[nextSalahIndex()];

  String get imsak {
    try {
      int minutes = int.parse(times!.times.first.split(':').first) * 60 +
          int.parse(times!.times.first.split(':').last) -
          times!.imsakNbMinBeforeFajr;

      return DateFormat('HH:mm').format(DateTime(200, 1, 1, minutes ~/ 60, minutes % 60));
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      return '';
    }
  }

  /// used to test time
  DateTime mosqueDate() => DateTime.now().add(Duration(hours: 1, minutes: 25));

  List get todayTimes => times!.times;

  List get todayIqama => times!.iqamaCalendar[today.month - 1][today.day.toString()];

  bool loading = false;

  /// get current home url
  String buildUrl(String languageCode) {
    // if (mosqueId != null) return 'https://mawaqit.net/$languageCode/id/$mosqueId?view=desktop';
    // if (mosqueSlug != null) return 'https://mawaqit.net/$languageCode/$mosqueSlug?view=desktop';

    return mosque!.url ?? '';

    return '';
  }

  Future<void> init() async {
    await Api.init();
    await loadFromLocale();
    notifyListeners();
  }

  salahName(int index) {
    return [
      S.current.fajr,
      S.current.duhr,
      S.current.asr,
      S.current.maghrib,
      S.current.isha,
    ][index];
  }

  // // /// update mosque id in the app and shared preference
  // Future<String> setMosqueId(String id) async {
  //   var url = 'https://mawaqit.net/en/id/$id?view=desktop';
  //
  //   var value = await http.get(Uri.parse(url));
  //   await fetchMosque();
  //
  //   if (value.statusCode != 200) {
  //     throw InvalidMosqueId();
  //   } else {
  //     AnalyticsWrapper.changeMosque(id);
  //
  //     mosqueId = id;
  //
  //     // mosqueSlug = null;
  //
  //     _saveToLocale();
  //
  //     notifyListeners();
  //     return mosqueId!;
  //   }
  // }

  /// update mosque id in the app and shared preference
  Future<void> setMosqueUUid(String uuid) async {
    try {
      mosque = await Api.getMosque(uuid);
      times = await Api.getMosqueTimes(uuid);

      // mosqueId = mosque!.id.toString();
      mosqueUUID = mosque!.uuid!;

      _saveToLocale();
    } catch (e) {}
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
    }
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
