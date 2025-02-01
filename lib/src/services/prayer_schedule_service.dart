import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import '../models/mosqueConfig.dart';
import '../models/times.dart';
import '../helpers/AppDate.dart';
import 'package:synchronized/synchronized.dart';

class PrayerScheduleService {
  /// Shared set of scheduled prayer times.
  static final Set<DateTime> _scheduledTimes = {};

  /// Lock for synchronizing access to [_scheduledTimes].
  static final Lock _lock = Lock();

  /// Schedules prayer tasks for the day.
  static Future<void> schedulePrayerTasks(
    Times times,
    MosqueConfig? mosqueConfig,
    bool isAdhanVoiceEnabled,
    int salahIndex,
    FlutterBackgroundService service,
  ) async {
    if (!await service.isRunning()) return;

    final prayerTimes = times.dayTimesStrings(AppDateTime.now(), salahOnly: true);
    final now = AppDateTime.now();

    for (var i = 0; i < prayerTimes.length; i++) {
      final entry = prayerTimes[i];
      final scheduleTime = _parseScheduleTime(entry, now);

      // Check within a lock whether the prayer time should be scheduled.
      if (!await _shouldSchedulePrayer(scheduleTime)) continue;

      final prayerConfig = _createPrayerConfig(
        entry,
        scheduleTime,
        isAdhanVoiceEnabled,
        mosqueConfig,
        salahIndex == 0,
        i,
      );

      await _schedulePrayerTimer(service, prayerConfig, scheduleTime);
    }
  }

  /// Converts a prayer time string (e.g. "05:30") into a DateTime object for today.
  static DateTime _parseScheduleTime(String entry, DateTime now) {
    final timeParts = entry.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  /// Determines whether a prayer should be scheduled.
  ///
  /// This method is wrapped in a lock to ensure that [_scheduledTimes]
  /// is not concurrently modified.
  static Future<bool> _shouldSchedulePrayer(DateTime scheduleTime) async {
    return await _lock.synchronized(() {
      if (_scheduledTimes.contains(scheduleTime)) return false;
      final delay = scheduleTime.difference(AppDateTime.now());
      return !delay.isNegative;
    });
  }

  /// Creates the configuration map for a prayer notification.
  static Map<String, dynamic> _createPrayerConfig(
    String entry,
    DateTime scheduleTime,
    bool isAdhanVoiceEnabled,
    MosqueConfig? mosqueConfig,
    bool isFajr,
    int index,
  ) {
    String adhanAsset = "";
    bool adhanFromAssets = false;
    bool shouldPlayAdhan = false;

    if (isAdhanVoiceEnabled) {
      shouldPlayAdhan = true;
      final url = getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);
      if (url.contains('bip')) {
        adhanFromAssets = true;
        adhanAsset = R.ASSETS_VOICES_ADHAN_BIP_MP3;
      } else {
        adhanAsset = url;
      }
    }

    return {
      'prayer': entry,
      'time': scheduleTime.toString(),
      'shouldPlayAdhan': shouldPlayAdhan,
      'adhanAsset': adhanAsset,
      'adhanFromAssets': adhanFromAssets,
      'salahName': getSalahName(index)
    };
  }

  /// Returns the name of the salah based on its index.
  static String getSalahName(int index) {
    final names = {
      0: S.current.fajr,
      1: S.current.duhr,
      2: S.current.asr,
      3: S.current.maghrib,
      4: S.current.isha,
    };
    return names[index] ?? '';
  }

  /// Retrieves the Adhan link based on the mosque configuration.
  static String getAdhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    String baseLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";

    if (mosqueConfig?.adhanVoice?.isNotEmpty ?? false) {
      baseLink = "$kStaticFilesUrl/mp3/${mosqueConfig!.adhanVoice!}.mp3";
    }

    if (useFajrAdhan && !baseLink.contains('bip')) {
      baseLink = baseLink.replaceAll('.mp3', '-fajr.mp3');
    }

    return baseLink;
  }

  /// Schedules a timer that will invoke the prayer notification at the right time,
  /// and records the scheduled time in a synchronized manner.
  static Future<void> _schedulePrayerTimer(
    FlutterBackgroundService service,
    Map<String, dynamic> config,
    DateTime scheduleTime,
  ) async {
    final delay = scheduleTime.difference(AppDateTime.now());
    Timer(delay, () async {
      service.invoke('prayerTime', config);
    });
    // Safely add the scheduled time to the set.
    await _lock.synchronized(() {
      _scheduledTimes.add(scheduleTime);
    });
  }
}
