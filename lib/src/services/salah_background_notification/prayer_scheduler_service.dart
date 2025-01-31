import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/salah_background_notification/adhan_audio_service.dart';

class PrayerSchedulerService {
  static final Set<DateTime> _scheduledTimes = {};

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

  static Future<void> schedulePrayerTasks(
    Times times,
    MosqueConfig? mosqueConfig,
    bool isAdhanVoiceEnabled,
    int salahIndex,
  ) async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;

    final prayerTimes = times.dayTimesStrings(AppDateTime.now(), salahOnly: true);
    final now = AppDateTime.now();

    for (var i = 0; i < prayerTimes.length; i++) {
      final entry = prayerTimes[i];
      final scheduleTime = _parseScheduleTime(entry, now);

      if (!_shouldSchedulePrayer(scheduleTime)) continue;

      final prayerConfig = _createPrayerConfig(
        entry,
        scheduleTime,
        isAdhanVoiceEnabled,
        mosqueConfig,
        salahIndex == 0,
        i,
      );

      _schedulePrayerTimer(service, prayerConfig, scheduleTime);
    }
  }

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

  static bool _shouldSchedulePrayer(DateTime scheduleTime) {
    if (_scheduledTimes.contains(scheduleTime)) return false;
    final delay = scheduleTime.difference(AppDateTime.now());
    return !delay.isNegative;
  }

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
      final url = AdhanAudioService.getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);
      if (url.contains('bip')) {
        adhanFromAssets = true;
        adhanAsset = R.ASSETS_VOICES_ADHAN_BIP_MP3;
      } else {
        adhanAsset = url;
      }
    }
    final notificationFormat = S.current.prayerTimeNotification("{{salah}}", "{{time}}");
    return {
      'prayer': entry,
      'time': scheduleTime.toString(),
      'shouldPlayAdhan': shouldPlayAdhan,
      'adhanAsset': adhanAsset,
      'adhanFromAssets': adhanFromAssets,
      'salahName': getSalahName(index),
      'notificationFormat': notificationFormat
    };
  }

  static void _schedulePrayerTimer(
    FlutterBackgroundService service,
    Map<String, dynamic> config,
    DateTime scheduleTime,
  ) {
    final delay = scheduleTime.difference(AppDateTime.now());
    Timer(delay, () => service.invoke('prayerTime', config));
    _scheduledTimes.add(scheduleTime);
  }
}
