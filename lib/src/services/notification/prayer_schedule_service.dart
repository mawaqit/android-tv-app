import 'dart:async';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import '../../models/mosqueConfig.dart';
import '../../models/times.dart';
import '../../helpers/AppDate.dart';
import 'package:synchronized/synchronized.dart';

class PrayerScheduleService {
  static const String PRAYER_TASK_TAG = "prayer_task";
  static final Set<DateTime> _scheduledTimes = {};
  static final Lock _lock = Lock();

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

      if (!await _shouldSchedulePrayer(scheduleTime)) continue;

      final prayerConfig = _createPrayerConfig(
        entry,
        scheduleTime,
        isAdhanVoiceEnabled,
        mosqueConfig,
        salahIndex == 0,
        i,
      );

      await _schedulePrayerWithWorkManager(prayerConfig, scheduleTime);
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

  static Future<bool> _shouldSchedulePrayer(DateTime scheduleTime) async {
    return await _lock.synchronized(() {
      if (_scheduledTimes.contains(scheduleTime)) return false;
      final delay = scheduleTime.difference(AppDateTime.now());
      return !delay.isNegative;
    });
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

  static Future<void> _schedulePrayerWithWorkManager(
    Map<String, dynamic> config,
    DateTime scheduleTime,
  ) async {
    final uniqueId = "${PRAYER_TASK_TAG}_${scheduleTime.millisecondsSinceEpoch}";
    final delay = scheduleTime.difference(AppDateTime.now());

    await WorkManagerService.registerPrayerTask(
      uniqueId,
      config,
      delay,
    );

    await _lock.synchronized(() {
      _scheduledTimes.add(scheduleTime);
    });
  }
}
