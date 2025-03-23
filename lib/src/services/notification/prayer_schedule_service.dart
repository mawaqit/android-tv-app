import 'dart:async';
import 'dart:convert';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/mosqueConfig.dart';
import '../../models/times.dart';
import '../../helpers/AppDate.dart';
import 'package:synchronized/synchronized.dart';

class PrayerScheduleService {
  static const String PRAYER_TASK_TAG = "prayer_task";
  static const String PREF_SCHEDULED_TIMES = "scheduled_prayer_times";
  static const String PREF_ADHAN_LINKS = "prayer_adhan_links";
  static final Lock _lock = Lock();

  /// Loads scheduled times from SharedPreferences
  static Future<Set<DateTime>> _loadScheduledTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> timeStrings =
        prefs.getStringList(PREF_SCHEDULED_TIMES) ?? [];

    return timeStrings.map((timeStr) => DateTime.parse(timeStr)).toSet();
  }

  /// Saves scheduled times to SharedPreferences
  static Future<void> _saveScheduledTimes(Set<DateTime> times) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> timeStrings =
        times.map((time) => time.toIso8601String()).toList();

    await prefs.setStringList(PREF_SCHEDULED_TIMES, timeStrings);
  }

  /// Loads previous Adhan links from SharedPreferences
  static Future<Map<DateTime, String>> _loadAdhanLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String json = prefs.getString(PREF_ADHAN_LINKS) ?? '{}';

    Map<String, dynamic> rawMap = jsonDecode(json);
    Map<DateTime, String> result = {};

    rawMap.forEach((key, value) {
      result[DateTime.parse(key)] = value.toString();
    });

    return result;
  }

  /// Saves Adhan links to SharedPreferences
  static Future<void> _saveAdhanLinks(Map<DateTime, String> links) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, String> stringMap = {};
    links.forEach((key, value) {
      stringMap[key.toIso8601String()] = value;
    });

    await prefs.setString(PREF_ADHAN_LINKS, jsonEncode(stringMap));
  }

  /// Schedules prayer tasks for multiple days
  static Future<void> schedulePrayerTasks(
    Times times,
    MosqueConfig? mosqueConfig,
    bool isAdhanVoiceEnabled,
    int salahIndex,
    FlutterBackgroundService service, {
    int numberOfDays = 7,
  }) async {
    if (!await service.isRunning()) return;

    final now = AppDateTime.now();

    // Load persisted data
    Set<DateTime> scheduledTimes = await _loadScheduledTimes();
    Map<DateTime, String> previousAdhanLinks = await _loadAdhanLinks();

    // Schedule for the specified number of days
    for (int dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
      // Calculate the date for the current iteration
      final targetDate = now.add(Duration(days: dayOffset));

      // Get prayer times for the target date
      final prayerTimes = times.dayTimesStrings(targetDate, salahOnly: true);

      for (var i = 0; i < prayerTimes.length; i++) {
        final entry = prayerTimes[i];
        final scheduleTime = _parseScheduleTime(entry, targetDate);

        // Skip prayers that have already passed (for today)
        if (dayOffset == 0 && scheduleTime.isBefore(now)) continue;

        final bool isFajr = (i == 0); // Assuming index 0 is Fajr
        final String currentAdhanLink =
            getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);

        if (!await _shouldSchedulePrayer(
            scheduleTime, currentAdhanLink, scheduledTimes, previousAdhanLinks))
          continue;

        final prayerConfig = _createPrayerConfig(
          entry,
          scheduleTime,
          isAdhanVoiceEnabled,
          mosqueConfig,
          isFajr,
          i,
        );

        // Generate a unique ID that includes day information
        final uniqueId =
            "${PRAYER_TASK_TAG}_${targetDate.day}_${targetDate.month}_${i}_${scheduleTime.millisecondsSinceEpoch}";

        await _schedulePrayerWithWorkManager(prayerConfig, scheduleTime,
            uniqueId: uniqueId, scheduledTimes: scheduledTimes);

        // Update previous Adhan links
        previousAdhanLinks[scheduleTime] = currentAdhanLink;
        await _saveAdhanLinks(previousAdhanLinks);
      }
    }
  }

  static DateTime _parseScheduleTime(String entry, DateTime date) {
    final timeParts = entry.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  static Future<bool> _shouldSchedulePrayer(
      DateTime scheduleTime,
      String currentAdhanLink,
      Set<DateTime> scheduledTimes,
      Map<DateTime, String> previousAdhanLinks) async {
    return await _lock.synchronized(() {
      final delay = scheduleTime.difference(AppDateTime.now());

      // Always schedule if the time is in the future
      if (delay.isNegative) return false;

      // Check if already scheduled and if the Adhan link has changed
      final bool alreadyScheduled = scheduledTimes.contains(scheduleTime);
      final String? previousAdhanLink = previousAdhanLinks[scheduleTime];

      // If the prayer was already scheduled but the Adhan link has changed,
      // we should reschedule it
      if (alreadyScheduled && previousAdhanLink != null && previousAdhanLink != currentAdhanLink) {
        // Remove from scheduled times to allow rescheduling
        scheduledTimes.remove(scheduleTime);
        return true;
      }

      // Schedule if not already scheduled
      return !alreadyScheduled;
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
      'salahName': getSalahName(index),
      'day': scheduleTime.day,
      'month': scheduleTime.month,
      'year': scheduleTime.year,
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
    DateTime scheduleTime, {
    String? uniqueId,
    required Set<DateTime> scheduledTimes,
  }) async {
    final taskId =
        uniqueId ?? "${PRAYER_TASK_TAG}_${scheduleTime.millisecondsSinceEpoch}";
    final delay = scheduleTime.difference(AppDateTime.now());

    await WorkManagerService.cancelTask(taskId);

    await WorkManagerService.registerPrayerTask(
      taskId,
      config,
      delay,
    );

    // Debug information
    print("=== PRAYER TASK SCHEDULED ===");
    print("Task ID: $taskId");
    print("Schedule Time: ${scheduleTime.toString()}");
    print("Current Time: ${AppDateTime.now().toString()}");
    print("Delay: ${delay.inMinutes} minutes (${delay.inSeconds} seconds)");
    print("Config: $config");

    // Update the set and save it
    scheduledTimes.add(scheduleTime);
    await _saveScheduledTimes(scheduledTimes);
  }

  /// Clears all scheduled prayers from persistence
  static Future<void> clearAllScheduledPrayers() async {
    await _lock.synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PREF_SCHEDULED_TIMES);
      await prefs.remove(PREF_ADHAN_LINKS);
    });
  }
}
