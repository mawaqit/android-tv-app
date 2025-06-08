import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../../main.dart';
import '../../const/constants.dart';
import '../../helpers/AppDate.dart';
import '../../services/mosque_manager.dart';
import 'app_update_state.dart';

class AppUpdateNotifier extends AsyncNotifier<AppUpdateState> {
  Timer? _updateTimer;

  @override
  Future<AppUpdateState> build() async {
    ref.onDispose(() {
      _updateTimer?.cancel();
    });
    return AppUpdateState.initial();
  }

  /// [startUpdateScheduler] Starts the app update scheduler based on the prayer times provided by the [MosqueManager].
  ///
  /// This method calculates the duration until 30 minutes after the Maghrib prayer time and schedules
  /// the app update check to run at that time. It cancels any previously scheduled update timer. Also it will run on Friday
  ///
  /// The [mosque] parameter is the [MosqueManager] instance that provides the prayer times.
  /// The [languageCode] parameter is the language code used for retrieving the app update information.
  ///
  /// Note: This method assumes that the prayer times are available and valid.
  void startUpdateScheduler(MosqueManager mosque, String languageCode, BuildContext context) {
    final now = AppDateTime.now();
    if (!context.mounted) {
      return;
    }
    // Check if today is Friday
    if (now.weekday == DateTime.friday) {
      final duration = _calculateDurationUntilThirtyMinutesAfterMaghrib(mosque, now);
      if (_updateTimer != null) _updateTimer!.cancel();
      _updateTimer = Timer(duration, () async {
        final today = mosque.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();
        final prays = mosque.times?.dayTimesStrings(today);
        await _startScheduleUpdate(
          languageCode: languageCode,
          prayerTimeList: prays ?? [],
          context: context,
        );
      });
    } else {
      log('AppUpdateNotifier: startUpdateScheduler: Today is not Friday. Skipping update scheduler.');
    }
  }

  /// [startScheduleUpdate] Initiates the process to check for app updates and updates the state accordingly. This method takes a `languageCode`
  ///
  /// to customize messages for the user and a list of `prayerTimeList` to determine the time of the prays to display update prompts.
  Future<void> _startScheduleUpdate({
    required String languageCode,
    required List<String> prayerTimeList,
    required BuildContext context,
  }) async {
    state = AsyncLoading();
    final shared = await ref.read(sharedPreferencesProvider.future);
    state = await AsyncValue.guard(() async {
      final isAutoUpdateCheckingEnabled = shared.getBool(CacheKey.kAutoUpdateChecking) ?? true;
      final isDismissed = shared.getBool(CacheKey.kIsUpdateDismissed) ?? false;

      if (!isAutoUpdateCheckingEnabled) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isAutoUpdateChecking: false,
        );
      }

      final upgrader = Upgrader(
        messages: UpgraderMessages(
          code: languageCode,
        ),
      );
      await upgrader.initialize(); // Prepares the Upgrader package for use.
      String? releaseNotes = upgrader.releaseNotes; // Retrieves release notes, if available.
      String message =
          upgrader.body(upgrader.determineMessages(context)); // Constructs a message for the update prompt.
      final isUpdateAvailable = upgrader.isUpdateAvailable(); // Checks if an update is available.

      final lastDismissedVersion = shared.getString(CacheKey.kUpdateDismissedVersion) ?? '0.0.0';

      logger.d(
          'AppUpdateNotifier: isDismissed: $isDismissed, isUpdateAvailable: $isUpdateAvailable, lastDismissedVersion: $lastDismissedVersion, message $message ');

      if (isDismissed &&
          isUpdateAvailable &&
          lastDismissedVersion != '0.0.0' &&
          lastDismissedVersion == upgrader.currentAppStoreVersion) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          isUpdateDismissed: true,
        );
      }

      final isDisplayUpdate =
          await _shouldDisplayUpdate(prayerTimeList); // Determines if the update prompt should be displayed.

      log('AppUpdateNotifier: isDisplayUpdate: $isDisplayUpdate, isUpdateAvailable: $isUpdateAvailable');

      if (isDisplayUpdate && isUpdateAvailable) {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.updateAvailable,
          message: message,
          releaseNote: releaseNotes ?? '',
        );
      } else {
        return state.value!.copyWith(
          appUpdateStatus: AppUpdateStatus.noUpdate,
          message: '',
          releaseNote: '',
        );
      }
    });
  }

  /// [dismissUpdate] Dismisses the update prompt and updates the state to indicate the prompt has been dismissed.
  Future<void> dismissUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final shared = await ref.read(sharedPreferencesProvider.future);
      await shared.setBool(CacheKey.kIsUpdateDismissed, true);

      final upgrader = Upgrader();
      await upgrader.initialize();

      await shared.setInt(CacheKey.kLastPopupDisplay, AppDateTime.now().millisecondsSinceEpoch);
      final latestAppStoreVersion = upgrader.currentAppStoreVersion;
      logger.d('AppUpdateNotifier: dismissUpdate: $latestAppStoreVersion');
      await shared.setString(CacheKey.kUpdateDismissedVersion, latestAppStoreVersion ?? '0.0.0');
      return state.value!.copyWith(appUpdateStatus: AppUpdateStatus.noUpdate, isUpdateDismissed: true);
    });
  }

  /// [openStore] Opens the store page for the app to facilitate updating. This method updates the state to indicate the store page is open.
  Future<void> openStore() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      OpenStore.instance.open(
        androidAppBundleId: kGooglePlayId,
      );
      return state.value!.copyWith(appUpdateStatus: AppUpdateStatus.openStore);
    });
  }

  /// [toggleAutoUpdateChecking] Toggles the auto-update checking feature on or off. This method updates the state to reflect the new setting.`
  Future<void> toggleAutoUpdateChecking() async {
    state = AsyncLoading();
    logger.d('AppUpdateNotifier: start toggleAutoUpdateChecking before');
    state = await AsyncValue.guard(() async {
      logger.d('AppUpdateNotifier: start toggleAutoUpdateChecking');
      final shared = await ref.read(sharedPreferencesProvider.future);
      final isAutoUpdateCheckingEnabled = shared.getBool(CacheKey.kAutoUpdateChecking) ?? true;
      await shared.setBool(CacheKey.kAutoUpdateChecking, !isAutoUpdateCheckingEnabled);
      logger.d('AppUpdateNotifier: change toggleAutoUpdateChecking into ${!isAutoUpdateCheckingEnabled}');
      return state.value!.copyWith(isAutoUpdateChecking: !isAutoUpdateCheckingEnabled);
    });
  }

  /// [_calculateDurationUntilThirtyMinutesAfterMaghrib] Calculates the duration between the current time and 30 minutes after the Maghrib prayer time.
  ///
  /// [mosque] The MosqueManager instance containing the prayer times.
  /// [currentDateTime] The current DateTime object.
  /// Returns the duration between the current time and 30 minutes after the Maghrib prayer time.
  Duration _calculateDurationUntilThirtyMinutesAfterMaghrib(MosqueManager mosque, DateTime currentDateTime) {
    final timeList = mosque.times?.dayTimesStrings(currentDateTime);
    final DateFormat formatter = DateFormat.Hm();
    final DateTime maghribTimeToday = formatter.parse(timeList![3]);
    log('AppUpdateNotifier: startUpdateScheduler: maghribTimeToday: $maghribTimeToday');
    final DateTime maghribDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      maghribTimeToday.hour,
      maghribTimeToday.minute,
    );

    final DateTime thirtyMinutesAfterMaghrib = maghribDateTime.add(Duration(minutes: 30));
    final duration = thirtyMinutesAfterMaghrib.difference(currentDateTime);
    log('AppUpdateNotifier: startUpdateScheduler: now: $currentDateTime');
    log('AppUpdateNotifier: startUpdateScheduler: duration: $duration');

    return duration;
  }

  /// [_shouldDisplayUpdate] Determines whether the update prompt should be displayed based on prayer times and the last time the prompt was shown.
  Future<bool> _shouldDisplayUpdate(List<String> prayerTimeList) async {
    final sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    final DateTime now = AppDateTime.now();
    final lastPopupDisplay =
        sharedPreferences.getInt(CacheKey.kLastPopupDisplay) ?? 0; // gets the time of the last update prompt
    final oneWeekAgo =
        now.subtract(Duration(days: 7)).millisecondsSinceEpoch; // Calculates the timestamp for one week ago.

    final DateFormat formatter = DateFormat.Hm();

    // Convert prayer times to DateTime objects for today
    final DateTime maghribTimeToday = formatter.parse(prayerTimeList[3]);
    final DateTime ishaTimeToday = formatter.parse(prayerTimeList[4]);
    final DateTime maghribDateTime =
        DateTime(now.year, now.month, now.day, maghribTimeToday.hour, maghribTimeToday.minute);
    final DateTime ishaDateTime = DateTime(now.year, now.month, now.day, ishaTimeToday.hour, ishaTimeToday.minute);

    // Compare only the current time's hour and minute with maghrib and isha times
    final isBetweenTwoPrays = now.isAfter(maghribDateTime) && now.isBefore(ishaDateTime);
    // Check if the last popup display was more than a week ago
    final bool isAfterOneWeek = lastPopupDisplay < oneWeekAgo;

    logger.d('AppUpdateNotifier: isBetweenTwoPrays: $isBetweenTwoPrays, isAfterOneWeek: $isAfterOneWeek');
    return isBetweenTwoPrays && isAfterOneWeek;
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);
