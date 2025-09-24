import 'dart:async';
import 'dart:convert';
import 'package:mawaqit/main.dart';
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
  static const String PREF_TASK_IDS = "prayer_task_ids"; // New constant for storing task IDs
  static final Lock _lock = Lock();

  /// Loads scheduled times from SharedPreferences
  static Future<Set<DateTime>> _loadScheduledTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> timeStrings = prefs.getStringList(PREF_SCHEDULED_TIMES) ?? [];

    return timeStrings.map((timeStr) => DateTime.parse(timeStr)).toSet();
  }

  /// Saves scheduled times to SharedPreferences
  static Future<void> _saveScheduledTimes(Set<DateTime> times) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> timeStrings = times.map((time) => time.toIso8601String()).toList();

    await prefs.setStringList(PREF_SCHEDULED_TIMES, timeStrings);
  }

  /// Loads task IDs mapped to their scheduled times
  static Future<Map<String, String>> _loadTaskIds() async {
    final prefs = await SharedPreferences.getInstance();
    final String json = prefs.getString(PREF_TASK_IDS) ?? '{}';

    Map<String, dynamic> rawMap = jsonDecode(json);
    Map<String, String> result = {};

    rawMap.forEach((key, value) {
      result[key] = value.toString();
    });

    return result;
  }

  /// Saves task IDs mapped to their scheduled times
  static Future<void> _saveTaskIds(Map<String, String> taskIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PREF_TASK_IDS, jsonEncode(taskIds));
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
    if (!await service.isRunning()) {
      logger.w('Background Service Not Running - Scheduling Aborted');
      return;
    }

    final now = AppDateTime.now();

    // Load persisted data
    Set<DateTime> scheduledTimes = await _loadScheduledTimes();
    Map<DateTime, String> previousAdhanLinks = await _loadAdhanLinks();
    Map<String, String> taskIds = await _loadTaskIds();

    // First check if any prayers need rescheduling
    bool needsRescheduling = false;

    // First pass: check which prayers need rescheduling
    for (int dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final prayerTimes = times.dayTimesStrings(targetDate, salahOnly: true);

      for (var i = 0; i < prayerTimes.length; i++) {
        final entry = prayerTimes[i];
        final scheduleTime = _parseScheduleTime(entry, targetDate);

        // Skip prayers that have already passed (for today)
        if (dayOffset == 0 && scheduleTime.isBefore(now)) {
          continue;
        }

        final bool isFajr = (i == 0);
        final String currentAdhanLink = getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);

        // Check if this prayer was scheduled with a different Adhan link
        if (scheduledTimes.contains(scheduleTime) &&
            previousAdhanLinks[scheduleTime] != null &&
            previousAdhanLinks[scheduleTime] != currentAdhanLink) {
          needsRescheduling = true;
          break;
        }
      }
      if (needsRescheduling) break;
    }

    // If any prayer needs rescheduling, cancel all previous prayers at once
    if (needsRescheduling) {
      logger.i('Detected configuration changes - rescheduling all prayers');
      await _cancelAllPreviouslyScheduledPrayers();
      scheduledTimes.clear();
      previousAdhanLinks.clear();
      taskIds.clear();
    }

    // Tracking for logging
    int totalPrayerTimesScheduled = 0;
    int skippedPrayerTimes = 0;
    List<Map<String, dynamic>> scheduledPrayerDetails = [];

    // Second pass: schedule prayers
    for (int dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
      // Calculate the date for the current iteration
      final targetDate = now.add(Duration(days: dayOffset));

      // Get prayer times for the target date
      final prayerTimes = times.dayTimesStrings(targetDate, salahOnly: true);

      for (var i = 0; i < prayerTimes.length; i++) {
        final entry = prayerTimes[i];
        final scheduleTime = _parseScheduleTime(entry, targetDate);

        // Skip prayers that have already passed (for today)
        if (dayOffset == 0 && scheduleTime.isBefore(now)) {
          skippedPrayerTimes++;
          continue;
        }

        final bool isFajr = (i == 0); // Assuming index 0 is Fajr
        final String currentAdhanLink = getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);

        final delay = scheduleTime.difference(now);
        // Skip if the time is in the past
        if (delay.isNegative) {
          skippedPrayerTimes++;
          continue;
        }

        // Skip if already scheduled
        if (scheduledTimes.contains(scheduleTime)) {
          skippedPrayerTimes++;
          continue;
        }

        final prayerConfig = _createPrayerConfig(
          entry,
          scheduleTime,
          isAdhanVoiceEnabled,
          mosqueConfig,
          isFajr,
          i,
        );

        // Generate a unique ID that includes day information and prayer index
        final uniqueId =
            "${PRAYER_TASK_TAG}_${targetDate.day}_${targetDate.month}_${i}_${scheduleTime.millisecondsSinceEpoch}";

        try {
          await _schedulePrayerWithWorkManager(prayerConfig, scheduleTime,
              uniqueId: uniqueId, scheduledTimes: scheduledTimes, taskIds: taskIds);

          // Track scheduled prayer details
          scheduledPrayerDetails.add({
            'uniqueId': uniqueId,
            'prayerName': getSalahName(i),
            'scheduleTime': scheduleTime.toIso8601String(),
            'adhanLink': currentAdhanLink,
          });

          totalPrayerTimesScheduled++;

          // Update previous Adhan links
          previousAdhanLinks[scheduleTime] = currentAdhanLink;
          await _saveAdhanLinks(previousAdhanLinks);
        } catch (e, stackTrace) {
          logger.e('Failed to Schedule Prayer', error: e, stackTrace: stackTrace);
        }
      }
    }

    // Summary logging only
    logger.i('Prayer Scheduling Completed: $totalPrayerTimesScheduled scheduled, $skippedPrayerTimes skipped');
  }

  static Future<void> _cancelAllPreviouslyScheduledPrayers() async {
    try {
      logger.i('🗑️ Starting cancellation of all previously scheduled prayers');

      // Load task IDs to ensure we're cancelling with the exact same IDs
      Map<String, String> taskIds = await _loadTaskIds();

      logger.d('Found ${taskIds.length} previously scheduled prayer task IDs');

      // Track successful and failed cancellations
      int successfulCancellations = 0;
      int failedCancellations = 0;

      // Cancel each task by its stored ID
      for (var entry in taskIds.entries) {
        final timeKey = entry.key;
        final taskId = entry.value;

        try {
          logger.v('Attempting to cancel task: $taskId (Scheduled for: $timeKey)');
          await WorkManagerService.cancelTask(taskId);
          successfulCancellations++;
        } catch (cancelError) {
          logger.w('Failed to cancel task ID: $taskId for time: $timeKey', error: cancelError);
          failedCancellations++;
        }
      }

      // Log cancellation summary
      logger.i({
        ' Cancellation Summary:'
            'Total Attempts': taskIds.length,
        'Successful Cancellations': successfulCancellations,
        'Failed Cancellations': failedCancellations,
      });

      // Clear the stored scheduled times and Adhan links
      await clearAllScheduledPrayers();

      logger.i('✅ All previously scheduled prayers cleared');
    } catch (e, stackTrace) {
      logger.e('❌ Error during cancellation of previous prayer tasks', error: e, stackTrace: stackTrace);
      rethrow;
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
    try {
      final names = {
        0: S.current.fajr,
        1: S.current.duhr,
        2: S.current.asr,
        3: S.current.maghrib,
        4: S.current.isha,
      };
      return names[index] ?? '';
    } catch (e) {
      final fallbackNames = {
        0: 'Fajr',
        1: 'Dhuhr',
        2: 'Asr',
        3: 'Maghrib',
        4: 'Isha',
      };
      return fallbackNames[index] ?? '';
    }
  }

  static String getAdhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    String baseLink = "$kStaticFilesUrl/audio/adhan-afassy.mp3";

    if (mosqueConfig?.adhanVoice?.isNotEmpty ?? false) {
      baseLink = "$kStaticFilesUrl/audio/${mosqueConfig!.adhanVoice!}.mp3";
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
    required Map<String, String> taskIds,
  }) async {
    final taskId = uniqueId ?? "${PRAYER_TASK_TAG}_${scheduleTime.millisecondsSinceEpoch}";
    final delay = scheduleTime.difference(AppDateTime.now());

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

    // Store the task ID mapped to schedule time for future cancellation
    taskIds[scheduleTime.toIso8601String()] = taskId;
    await _saveTaskIds(taskIds);
  }

  /// Clears all scheduled prayers from persistence
  static Future<void> clearAllScheduledPrayers() async {
    await _lock.synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PREF_SCHEDULED_TIMES);
      await prefs.remove(PREF_ADHAN_LINKS);
      await prefs.remove(PREF_TASK_IDS);
    });
  }
}
